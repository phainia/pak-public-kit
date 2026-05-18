local ResQueue = require("NewRoco.Utils.ResQueue")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PerceptionTriggerComponent = require("NewRoco.Modules.Core.Scene.Component.Collision.PerceptionTriggerComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local Base = ActorComponent
local DistTooFar = 100.0
local PetSensingStatusEnum = {
  IDLE = 1,
  PRE_SENSING = 2,
  SENSING = 3,
  PENDING_STOP = 4,
  WAITING_END = 5
}
local PetSensingComponent = Base:Extend("PetSensingComponent")

function PetSensingComponent:Ctor()
  Base.Ctor(self)
  self.StartSkillCallbackOwner = nil
  self.StartSkillCallbackFunc = nil
  self.StopSkillCallbackOwner = nil
  self.StopSkillCallbackFunc = nil
  self.CurrentSkill = nil
  self.ClosestTarget = nil
  self.SensingRange = 25000000
  self.Session = nil
  self.NewlyCreated = false
  self.PetSensingStatus = PetSensingStatusEnum.IDLE
  self.serverCreateFinished = false
  self.clientCreateFinished = false
  self.createSucceed = true
end

function PetSensingComponent:SetPetSensingStatus(Status)
  Log.Trace("PetSensingComponent:SetPetSensingStatus", table.getKeyName(PetSensingStatusEnum, self.PetSensingStatus), table.getKeyName(PetSensingStatusEnum, Status))
  self.PetSensingStatus = Status
end

function PetSensingComponent:UpdateData(ServerData, isReconnect)
  if not isReconnect or self.PetSensingStatus == PetSensingStatusEnum.IDLE or self.PetSensingStatus == PetSensingStatusEnum.WAITING_END or self.PetSensingStatus == PetSensingStatusEnum.SENSING then
  else
    self:ServerCreateFailed()
  end
end

function PetSensingComponent:PlayPerceptionSkill(ScenePet, CallbackOwner, CallbackFunc)
  if self.PetSensingStatus ~= PetSensingStatusEnum.IDLE then
    Log.Debug("\230\132\159\231\159\165\230\181\129\231\168\139\228\184\173\239\188\140\231\166\129\230\173\162\233\135\141\229\164\141\230\132\159\231\159\165", self.PetSensingStatus)
    if CallbackFunc then
      CallbackFunc(CallbackOwner, false)
    end
    return
  end
  local PetGID = ScenePet.gid
  if not self:PreparePet(PetGID) then
    Log.Error("\233\128\137\228\184\173\231\154\132\231\178\190\231\129\181\230\178\161\230\156\137\230\132\159\231\159\165\231\155\184\229\133\179\231\154\132\233\133\141\231\189\174", PetGID)
    if CallbackFunc then
      CallbackFunc(CallbackOwner, false)
    end
    return
  end
  if self.CurrentSkill then
    local Player = self:GetPlayer()
    local PlayerView = Player.viewObj
    local PlayerSkillComp = PlayerView.RocoSkill
    PlayerSkillComp:CancelSkill(self.CurrentSkill, UE4.ESkillActionResult.SkillActionResultInterrupted)
    Log.Error("\230\132\159\231\159\165\230\181\129\231\168\139\229\135\186\233\151\174\233\162\152\228\186\134\239\188\129\228\184\141\229\186\148\232\175\165\229\156\168Idle\231\138\182\230\128\129\228\189\134\230\152\175\230\138\128\232\131\189\229\129\156\228\184\141\228\186\134")
  end
  self:SetPetSensingStatus(PetSensingStatusEnum.PRE_SENSING)
  self.WasTooFar = false
  self.StartSkillCallbackOwner = CallbackOwner
  self.StartSkillCallbackFunc = CallbackFunc
  table.clear(self.ColoredActors)
  self.ClosestTarget = nil
  local Player = self:GetPlayer()
  local Session = self:HasSession()
  if Session and Session.Status ~= ThrowSessionStatusEnum.PostInteract then
    self:StartSkillFinish(false)
    return
  end
  if self.LoadQueue then
    self.LoadQueue:Release()
  else
    self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, PriorityEnum.Active_Throw_Sense)
  end
  self.Session, self.NewlyCreated = self:AcquireSession()
  self.Session:SetStatus(ThrowSessionStatusEnum.CriticalInteracting)
  self.Session:ForceSetCanBeRecycle(false)
  local Pet = self.Session and self.Session:HasPet() and self.Session.NPC
  local PetTooFar = true
  if Pet then
    PetTooFar = Pet:DistanceTo(Player, false, true) > DistTooFar
  end
  if PetTooFar then
    self.LoadQueue:InsertSenseRelease("EQS", self.PetData)
    self.LoadQueue:InsertClass("Jump", "/Game/ArtRes/Effects/G6Skill/SceneEffect/Perception/G6_Scene_Perception_Open")
  else
    self.LoadQueue:InsertClass("Jump", "/Game/ArtRes/Effects/G6Skill/SceneEffect/Perception/G6_Scene_Perception_Open2")
  end
  if self.NewlyCreated then
    self.LoadQueue:InsertPet("Pet", self.Session)
  end
  self.LoadQueue:StartLoad(self, self.PlayShowPetSkill)
end

function PetSensingComponent:PlayShowPetSkill(Queue, Success)
  local Pet = Queue:Get("Pet")
  if not Success then
    if Pet then
      Pet:Destroy()
    end
    self:StartSkillFinish(false)
    self:ShowTips("pet_eco_reject")
    self:ClearTempSession()
    return
  end
  local EQSObject = Queue:GetResObject("EQS")
  local Location
  if EQSObject then
    Location = EQSObject.AbsoluteLocations[1]
  end
  Pet = Pet or self.Session.NPC
  local Player = self:GetPlayer()
  if not Pet or not Player then
    self:StartSkillFinish(false)
    self:ShowTips("pet_eco_reject")
    self:ClearTempSession()
    return
  end
  Pet:SetVisibleForCallOutReason(false)
  if Location then
    Location = ThrowUtils:TweakStandLocation(Location, Pet, self.PetData)
    Pet:SetActorLocation(Location)
    Pet:SetActorScale3D(_G.FVectorOne)
    DialogueUtils.LookAt(Pet, Player)
  end
  local Comp = Pet and Pet.PetStatusComponent
  if Comp then
    Comp:SetStatus(PetStatusType.None)
    if Comp.bInteractingWithSwitch then
      Pet.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.INTERACT)
      Comp.bInteractingWithSwitch = false
    end
  end
  if self.SyncQueue then
    self.SyncQueue:Release()
  else
    self.SyncQueue = ResQueue(10, ResQueue.RunMode.Sequential)
  end
  if self.NewlyCreated then
    self.SyncQueue:InsertSyncPet("Sync", Pet)
  elseif Pet then
    Pet:ReportPosition()
  end
  self.SyncQueue:StartLoad(self, self.PostSyncPet)
end

function PetSensingComponent:PostSyncPet(Queue, Success)
  local Session = self.Session
  local Pet = Session and Session.NPC or nil
  local View = Pet.viewObj
  if not Success then
    Log.Warning("\230\138\128\232\131\189\230\137\167\232\161\140\229\164\177\232\180\165", Pet.serverData.pet_info.gid)
  elseif not Pet then
    Log.Error("\229\174\160\231\137\169\229\175\185\232\177\161\228\184\141\229\173\152\229\156\168")
  elseif not View then
    Log.Error("\229\174\160\231\137\169\232\167\134\229\155\190\230\156\170\229\138\160\232\189\189")
  end
  if not (Success and Pet) or not View then
    self:StartSkillFinish(false)
    self:ShowTips("pet_eco_reject")
    self:ClearTempSession()
    return
  end
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.ADD_THROW_SESSION_PET, self.Session)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.ON_THROW_PET_CREATED, View)
  local Player = self:GetPlayer()
  local PlayerView = Player.viewObj
  local PetGId = Pet.serverData.pet_info.gid
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
  local SkillComp = PlayerView.RocoSkill
  local JumpSkill = SkillComp:FindOrAddSkillObj(self.LoadQueue:Get("Jump"))
  local Blackboard = JumpSkill.Blackboard
  if MedalType then
    Blackboard:SetValueAsString(MedalType, MedalType)
  end
  JumpSkill:SetPassive(true)
  JumpSkill:SetCaster(PlayerView)
  JumpSkill:SetTargets({View})
  JumpSkill:SetAdditions("Pet", Pet)
  JumpSkill:SetDynamicData({
    BallPath = BattleUtils.GetPetBallPath(self.PetData)
  })
  JumpSkill:RegisterEventCallback("Show", self, self.OnPetShow)
  JumpSkill:RegisterEventCallback("Jump", self, self.OnPetJump)
  JumpSkill:RegisterEventCallback("Unlock", self, self.OnUnlockRecycle)
  JumpSkill:RegisterEventCallback("Interrupt", self, self.RemovePet)
  JumpSkill:RegisterEventCallback("Recycle", self, self.RecyclePet)
  JumpSkill:RegisterEventCallback("End", self, self.RemovePet)
  Session.SenseSkill = JumpSkill
  local Blackboard = JumpSkill.Blackboard
  Blackboard:SetValueAsInt("Continue", -1)
  local Result = SkillComp:LoadAndPlaySkill(JumpSkill)
  if Result == UE.ESkillStartResult.Success then
    self.CurrentSkill = JumpSkill
    local perceptionTriggerComponent = Pet:EnsureComponent(PerceptionTriggerComponent)
    perceptionTriggerComponent:StartPerception(self.PetGID, nil, "PetSensingComponent")
    self:StartSkillFinish(true)
  else
    self:StartSkillFinish(false)
    self:ShowTips("pet_eco_reject")
    self:ClearTempSession()
  end
end

function PetSensingComponent:ClearTempSession()
  if self.NewlyCreated then
    self.NewlyCreated = false
    if self.Session then
      self.Session:ClearPet()
      self.Session:SetStatus(ThrowSessionStatusEnum.Destroyed)
    end
  elseif self.Session then
    self.Session:ForceSetCanBeRecycle(true)
    self.Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
  end
  self.Session = nil
end

function PetSensingComponent:StartSkillFinish(Success)
  local Func = self.StartSkillCallbackFunc
  local Owner = self.StartSkillCallbackOwner
  self.StartSkillCallbackFunc = nil
  self.StartSkillCallbackOwner = nil
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
  if self.SyncQueue then
    self.SyncQueue:Release()
  end
  if Success then
    if self.PetSensingStatus == PetSensingStatusEnum.PRE_SENSING then
      self:SetPetSensingStatus(PetSensingStatusEnum.SENSING)
    elseif self.PetSensingStatus == PetSensingStatusEnum.PENDING_STOP then
      self:SetPetSensingStatus(PetSensingStatusEnum.WAITING_END)
      self.CurrentSkill.Blackboard:SetValueAsInt("Continue", 0)
    end
  elseif self.PetSensingStatus == PetSensingStatusEnum.PRE_SENSING or self.PetSensingStatus == PetSensingStatusEnum.PENDING_STOP then
    self:SetPetSensingStatus(PetSensingStatusEnum.IDLE)
  else
    Log.Error("\228\184\141\229\186\148\232\175\165\229\135\186\231\142\176\232\191\153\231\167\141\230\131\133\229\134\181\239\188\140\228\184\186\228\187\128\228\185\136\228\188\154\229\133\136\230\136\144\229\138\159\228\184\128\230\172\161\229\134\141\229\164\177\232\180\165\239\188\140\232\191\153\228\184\170\229\134\133\229\174\185\233\135\141\229\164\141\228\186\134")
  end
  if Func then
    Func(Owner, Success)
  end
end

function PetSensingComponent:PreparePet(PetGID)
  self.PetGID = PetGID and PetGID or NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  self.PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetGID)
  if not self.PetData then
    return false
  end
  self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetData.base_conf_id)
  if not self.PetBaseConf then
    return false
  end
  self.SensingConf = _G.DataConfigManager:GetPetSceneAbilityGanzhi(self.PetBaseConf.id, true)
  if self.SensingConf then
    self.SensingRange = self.SensingConf.pet_ability_distance * self.SensingConf.pet_ability_distance
    return true
  else
    return false
  end
end

function PetSensingComponent:FatalError()
  Log.Error("\230\136\145\230\147\166\239\188\140\230\132\159\231\159\165\230\138\128\232\131\189\232\162\171\230\137\147\230\150\173\228\186\134\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\232\175\183\230\138\138\230\151\165\229\191\151\229\143\145\231\187\153poanshen\231\156\139\231\156\139")
end

function PetSensingComponent:OnUnlockRecycle(Name, Skill)
  if self.Session then
    self.Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
    self.Session:ForceSetCanBeRecycle(true)
  end
end

function PetSensingComponent:OnPetShow(Name, Skill)
  local Pet = Skill:GetAddition("Pet")
  if Pet then
    Pet:SetVisibleForCallOutReason(true)
  end
end

function PetSensingComponent:OnPetJump(Name, Skill)
  local Pet = Skill:GetAddition("Pet")
  if not Pet then
    Log.Error("PetSensingComponent:RecyclePet pet \229\156\168\229\155\158\230\148\182\229\137\141\230\182\136\229\164\177\229\149\166")
    return
  end
  Pet:SetVisibleForCallOutReason(true)
  local AIComp = Pet.AIComponent
  if AIComp then
    AIComp:ForceLockForReason(false, false, AIDefines.LockReason.INTERACT)
    AIComp:OnDistanceOptimize(0, 1, 0, 0)
  end
  local HUDComp = Pet.PetHUDComponent
  if HUDComp then
    HUDComp:ForceUpdate()
  end
end

function PetSensingComponent:StopPerceptionSkill(CallbackOwner, CallbackFunc, bOverriden)
  if self.PetSensingStatus == PetSensingStatusEnum.PRE_SENSING then
    self:SetPetSensingStatus(PetSensingStatusEnum.PENDING_STOP)
    self.StopSkillCallbackOwner = CallbackOwner
    self.StopSkillCallbackFunc = CallbackFunc
  elseif self.PetSensingStatus == PetSensingStatusEnum.SENSING then
    self:SetPetSensingStatus(PetSensingStatusEnum.WAITING_END)
    self.StopSkillCallbackOwner = CallbackOwner
    self.StopSkillCallbackFunc = CallbackFunc
    if self.Session and (self.Session.Status == ThrowSessionStatusEnum.Recycling or self.Session.Status == ThrowSessionStatusEnum.Destroyed) then
      if self.CurrentSkill then
        Log.Debug("\230\156\137\230\138\128\232\131\189\229\176\177\228\185\150\228\185\150\231\173\137\230\138\128\232\131\189")
        self.CurrentSkill.Blackboard:SetValueAsInt("Continue", 0)
      else
        self:RecyclePet()
        self:RemovePet()
      end
      return
    end
    local Skill = self.CurrentSkill
    if not Skill then
      self:RecyclePet()
      self:RemovePet()
      return
    end
    if not bOverriden then
      self.Session:SetStatus(ThrowSessionStatusEnum.CriticalInteracting)
      self.Session:ForceSetCanBeRecycle(false)
    end
    Skill.Blackboard:SetValueAsInt("Continue", 0)
  elseif CallbackFunc and CallbackOwner then
    CallbackFunc(CallbackOwner, false)
  end
end

function PetSensingComponent:FireStopSkillFinish(Success)
  Log.Debug("Stop Sensing...Done")
  local Func = self.StopSkillCallbackFunc
  local Owner = self.StopSkillCallbackOwner
  self.StopSkillCallbackFunc = nil
  self.StopSkillCallbackOwner = nil
  self:SetPetSensingStatus(PetSensingStatusEnum.IDLE)
  if Func then
    Func(Owner, Success)
  end
end

function PetSensingComponent:RecyclePet(Name, Skill)
  if not self.Session then
    return
  end
  local Pet = self.Session.NPC
  if Pet then
    local perceptionTriggerComponent = Pet:EnsureComponent(PerceptionTriggerComponent)
    self.ClosestTarget = perceptionTriggerComponent:GetClosest()
    perceptionTriggerComponent:StopPerception()
  end
  if not self.Session:IsRecycling() and not self.Session:IsDestroyed() then
    self.Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
    self.Session:ForceSetCanBeRecycle(true)
  end
end

function PetSensingComponent:RemovePet(Name, Skill)
  if UE.UObject.IsValid(self.CurrentSkill) then
    self.CurrentSkill.Blackboard:SetValueAsInt("Continue", 0)
  end
  if self.Session and not self.Session:IsRecycling() and not self.Session:IsDestroyed() then
    self.Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
    self.Session:ForceSetCanBeRecycle(true)
  end
  local Pet = Skill and Skill:GetAddition("Pet")
  if Pet then
    Pet:SetVisibleForCallOutReason(true)
  end
  self.Session = nil
  self.CurrentSkill = nil
  _G.DelayManager:DelayFrames(1, self.FireStopSkillFinish, self, true)
end

function PetSensingComponent:GetPlayer()
  return self.owner
end

function PetSensingComponent:HasSession()
  local Session = ThrowSession.GetWithGID(self.PetGID)
  return Session
end

function PetSensingComponent:AcquireSession()
  local Session = ThrowSession.GetWithGID(self.PetGID)
  if Session then
    if Session:IsDestroyed() or Session:IsRecycling() then
      Log.Error("\230\139\191\229\136\176\228\186\134\228\184\128\228\184\170\233\148\128\230\175\129\228\184\173\231\154\132Session\239\188\129\239\188\129", table.getKeyName(ThrowSessionStatusEnum, Session.Status))
    end
    return Session, false
  end
  Session = ThrowSession.CreatePet(self.PetData)
  Session:SetOwnerId()
  Session:SetSeqID(0)
  return Session, true
end

function PetSensingComponent:RemoveNPC(ID)
  return _G.NRCModuleManager:DoCmd(NPCModuleCmd.RemoveNPC, ID)
end

function PetSensingComponent:ShowTips(TipsID)
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.LuaText[TipsID])
end

return PetSensingComponent
