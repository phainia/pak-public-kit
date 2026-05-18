local ResQueue = require("NewRoco.Utils.ResQueue")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local SummonPetComponent = Base:Extend("SummonPetComponent")

function SummonPetComponent:Ctor()
  Base.Ctor(self)
  self.SummonCallbackOwner = nil
  self.SummonCallbackFunc = nil
  self.RecallCallbackOwner = nil
  self.RecallCallbackFunc = nil
  self.CurrentSession = nil
  self.LoadQueue = nil
  self.SyncQueue = nil
end

function SummonPetComponent:DeAttach()
  self.SummonCallbackOwner = nil
  self.SummonCallbackFunc = nil
  self.RecallCallbackOwner = nil
  self.RecallCallbackFunc = nil
  self.CurrentSession = nil
end

function SummonPetComponent:SummonWithGID(GID, Location, CallbackOwner, CallbackFunc)
  if not GID then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(GID)
  if not PetData then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if self.CurrentSession and (self.CurrentSession.Status == ThrowSessionStatusEnum.PreReleasing or self.CurrentSession.Status == ThrowSessionStatusEnum.Releasing) then
    Log.Debug("\229\137\141\228\184\128\228\184\170\231\178\190\231\129\181\230\173\163\229\156\168\229\143\172\229\148\164\228\184\173\239\188\140\230\139\146\231\187\157\230\142\137\230\150\176\231\154\132\229\143\172\229\148\164\231\148\179\232\175\183", self.CurrentSession.Status)
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  local Session, NewlyCreated = self:GetThrowSession(PetData)
  Session:SetSeqID(0)
  Session:SetStatus(ThrowSessionStatusEnum.PreReleasing)
  if not NewlyCreated then
    self:CallFunction(CallbackOwner, CallbackFunc, true)
    return
  end
  self.SummonCallbackOwner = CallbackOwner
  self.SummonCallbackFunc = CallbackFunc
  self.CurrentSession = Session
  if self.LoadQueue then
    self.LoadQueue:Release()
  else
    self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, PriorityEnum.Active_Throw_Unmount)
  end
  self.LoadQueue:InsertClass("Jump", "/Game/ArtRes/Effects/G6Skill/Yuancheng/CallOut_Suc")
  self.LoadQueue:InsertPet("Pet", Session)
  if Location then
    self.Location = Location
  else
    self.LoadQueue:InsertSenseRelease("EQS", PetData)
  end
  self.LoadQueue:StartLoad(self, self.OnPetReady)
end

function SummonPetComponent:OnPetReady(Queue, Success)
  local Session = self.CurrentSession
  if not Session then
    self:CleanupSession()
    return
  end
  local Pet = Queue:Get("Pet")
  if not Success then
    self:CleanupSession()
    return
  end
  local PetView = Pet and Pet.viewObj
  if not PetView or not UE.UObject.IsValid(PetView) then
    self:CleanupSession()
    return
  end
  local Location = self.Location
  local EQSResult = Queue:GetResObject("EQS")
  if EQSResult then
    Location = EQSResult.AbsoluteLocations[1]
  end
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.ADD_THROW_SESSION_PET, Session)
  Session:SetStatus(ThrowSessionStatusEnum.Releasing)
  local CopyLocation = ThrowUtils:TweakStandLocation(Location, Pet, Session.petData)
  Pet:SetActorLocation(CopyLocation)
  SceneUtils.LookAt(Pet, self.owner)
  Pet:SetHeadLookAtActor(self.owner.viewObj, true)
  if PetView.CharacterMovement then
    PetView.CharacterMovement:Deactivate()
  end
  if self.SyncQueue then
    self.SyncQueue:Release()
  else
    self.SyncQueue = ResQueue(10, ResQueue.RunMode.Sequential)
  end
  self.SyncQueue:InsertSyncPet("Sync", Pet)
  self.SyncQueue:StartLoad(self, self.PostSyncPet)
end

function SummonPetComponent:PostSyncPet(Queue, Success)
  local SyncPet = Queue:GetResObject("Sync")
  local Session = SyncPet.Session
  local PetGId
  if Session then
    PetGId = Session:GetGID()
  end
  local MedalType
  if PetGId then
    local _, WearMedal = _G.DataModelMgr.PlayerDataModel:GetMedalListAndWearMedalByPetGid(PetGId)
    if WearMedal then
      local medal_conf = _G.DataConfigManager:GetMedalConf(WearMedal.conf_id, true)
      if medal_conf then
        MedalType = medal_conf.fx_res
      end
    end
  end
  local Pet = SyncPet.Pet
  if not Pet then
    self:CleanupSession()
    Log.Error("\229\143\172\229\148\164\231\178\190\231\129\181\231\154\132\231\178\190\231\129\181\230\178\161\228\186\134\227\128\130\227\128\130\227\128\130")
    return
  end
  local PetView = Pet.viewObj
  if not UE.UObject.IsValid(PetView) then
    self:CleanupSession()
    Log.Error("\229\143\172\229\148\164\231\178\190\231\129\181\231\154\132\231\178\190\231\129\181\230\168\161\229\158\139\228\184\162\228\186\134\227\128\130\227\128\130\227\128\130")
    return
  end
  local SkillComp = PetView.RocoSkill
  local JumpSkill = SkillComp:FindOrAddSkillObj(self.LoadQueue:Get("Jump"))
  if not UE.UObject.IsValid(JumpSkill) then
    self:CleanupSession()
    Log.Error("\229\143\172\229\148\164\231\178\190\231\129\181\232\142\183\229\190\151\231\154\132\230\138\128\232\131\189\228\184\141\229\173\152\229\156\168\227\128\130\227\128\130\227\128\130")
    return
  end
  JumpSkill:SetAdditions("pet", Pet)
  JumpSkill:SetAdditions("session", Session)
  JumpSkill:SetCaster(PetView)
  local Blackboard = JumpSkill.Blackboard
  if MedalType then
    Blackboard:SetValueAsString(MedalType, MedalType)
  end
  JumpSkill:RegisterEventCallback("Interrupt", self, self.OnSummonComplete)
  JumpSkill:RegisterEventCallback("End", self, self.OnSummonComplete)
  JumpSkill:RegisterEventCallback("PreEnd", self, self.OnSummonComplete)
  JumpSkill:RegisterEventCallback("PreEndAnim", self, self.OnSummonComplete)
  JumpSkill:RegisterEventCallback("ShowPet", self, self.ShowPet)
  JumpSkill:RegisterEventCallback("HideBall", self, self.ShowPet)
  local Result = SkillComp:LoadAndPlaySkill(JumpSkill)
  if Result ~= UE.ESkillStartResult.Success then
    self:CleanupSession()
    Log.Error("Summon Pet Play Skill Failed")
  end
end

function SummonPetComponent:CleanupSession()
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
  if self.SyncQueue then
    self.SyncQueue:Release()
  end
  self:FireSummonCallback(false)
  self:ShowTips("pet_eco_reject")
  if self.CurrentSession then
    self.CurrentSession:SendRecycleReq(_G.ProtoEnum.RecycleThrowPetReason.RTPR_None)
    self.CurrentSession:SetIsValid(false)
    self.CurrentSession:RecycleAllRes()
  end
  Log.Debug("Summon Session Done", self.CurrentSession)
  self.CurrentSession = nil
end

function SummonPetComponent:ShowPet(Name, SkillObject)
  local pet = SkillObject:GetAddition("pet")
  if pet and pet.viewObj then
    pet:SetVisibleForCallOutReason(true)
  end
end

function SummonPetComponent:OnSummonComplete(Name, Skill)
  local pet = Skill:GetAddition("pet")
  if not pet then
    Log.Error("SummonPetComponent:OnSummonComplete with no pet")
    self:CleanupSession()
    return
  end
  if pet.AIComponent then
    pet.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.INTERACT)
    pet.AIComponent:OnDistanceOptimize(0, 1, 0, 0)
  end
  if pet.PetHUDComponent then
    pet.PetHUDComponent:ForceUpdate()
  end
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
  if self.SyncQueue then
    self.SyncQueue:Release()
  end
  local Session = Skill:GetAddition("session")
  Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
  self:FireSummonCallback(true)
  Log.Debug("Summon Session Done", self.CurrentSession)
  self.CurrentSession = nil
end

function SummonPetComponent:Recall(GID, Perform, CallbackOwner, CallbackFunc)
  local Session = ThrowSession.GetWithGID(GID)
  if not Session then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if Session.Status == ThrowSessionStatusEnum.Interacting then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if Session.Status == ThrowSessionStatusEnum.Releasing then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if Session.Status == ThrowSessionStatusEnum.WaitBeginDrop then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if Session.Status == ThrowSessionStatusEnum.WaitEnter then
    self:CallFunction(CallbackOwner, CallbackFunc, false)
    return
  end
  if Perform then
    Session:Recycle()
  else
    Session:RecycleDirect()
  end
  self:CallFunction(CallbackOwner, CallbackFunc, true)
end

function SummonPetComponent:GetThrowSession(PetData)
  local Session = ThrowSession.GetWithGID(PetData.gid)
  if Session then
    return Session, false
  end
  Session = ThrowSession.CreatePet(PetData)
  return Session, true
end

function SummonPetComponent:FireSummonCallback(Success)
  local Owner = self.SummonCallbackOwner
  local Func = self.SummonCallbackFunc
  self.SummonCallbackFunc = nil
  self.SummonCallbackOwner = nil
  self:CallFunction(Owner, Func, Success)
end

function SummonPetComponent:FireRecallCallback(Success)
  local Owner = self.RecallCallbackOwner
  local Func = self.RecallCallbackFunc
  self.RecallCallbackOwner = nil
  self.RecallCallbackFunc = nil
  self:CallFunction(Owner, Func, Success)
end

function SummonPetComponent:CallFunction(Owner, Func, ...)
  if not Func then
    return
  end
  if Owner then
    Func(Owner, ...)
  else
    Func(...)
  end
end

function SummonPetComponent:ShowTips(TipsID)
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText[TipsID])
end

return SummonPetComponent
