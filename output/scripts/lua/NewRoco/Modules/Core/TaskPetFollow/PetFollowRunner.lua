local Class = _G.MakeSimpleClass
local ResQueue = require("NewRoco.Utils.ResQueue")
local EQSQueryType = require("NewRoco.Modules.Core.NPC.EQSQueryType")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local PetInteractionComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetInteractionComponent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local PetFollowRunner = Class("PetFollowRunner")

function PetFollowRunner:Ctor(Module, Gid, FirstTaskID)
  self.Module = Module
  self.Gid = Gid
  self.FirstTaskID = FirstTaskID
  self.BindTaskIDs = {}
  if FirstTaskID then
    self.BindTaskIDs[FirstTaskID] = true
  else
    Log.Warning("PetFollowRunner:Ctor FirstTaskID is nil")
  end
  self.Session = nil
  self.bChaos = false
  self:TrySetPetMainTemplateLock()
  self:CheckMutation()
end

function PetFollowRunner:CheckMutation()
  local PetData = self:GetPetData()
  if not PetData then
    return
  end
  if PetData.mutation_type and 0 ~= PetData.mutation_type & _G.Enum.MutationDiffType.MDT_CHAOS_THREE then
    self.bChaos = true
  end
end

function PetFollowRunner:AddBindTask(TaskID)
  if self.BindTaskIDs[TaskID] then
    return
  end
  self.BindTaskIDs[TaskID] = true
end

function PetFollowRunner:GetPetData()
  return _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.Gid)
end

function PetFollowRunner:TrySummonPet()
  if not self:PreSummonCheck(self:GetPetData()) then
    return
  end
  if _G.NRCModuleManager:GetModule("SceneModule").triggerEnterScene then
    local OnEnterSceneFinished
    
    function OnEnterSceneFinished()
      _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAckEnd, OnEnterSceneFinished)
      self:StartFollow(false)
    end
    
    _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.OnEnterSceneFinishNtyAckEnd, OnEnterSceneFinished)
    return
  end
  self:StartFollow(false)
end

function PetFollowRunner:OnStartFollow()
  local Tip = string.format(_G.DataConfigManager:GetLocalizationConf("follower_pet_appear").msg, self.Session:GetPetName())
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Tip)
  if self.Register then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetPetThrowBlockForReason, true, self.Gid, _G.MainUIModuleEnum.AbilityBtnBlockReason.TaskPetFollow)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetPetRideBlockForReason, true, self.Gid, _G.MainUIModuleEnum.AbilityBtnBlockReason.TaskPetFollow)
  self:TrySetPetMainTemplateLock()
  _G.NRCEventCenter:RegisterEvent(self.name, self, BattleEvent.BattleOver, self.OnBattleOver)
  _G.NRCEventCenter:RegisterEvent(self.name, self, PetUIModuleEvent.OnRefreshEvoPetModel, self.OnPetLevelUp)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_START, self.OnReconnect)
  if self.bChaos then
    _G.NRCEventCenter:RegisterEvent(self.name, self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.OnPetPurify)
  end
  self.Register = true
end

function PetFollowRunner:OnStopFollow()
  local Tip = string.format(_G.DataConfigManager:GetLocalizationConf("follower_pet_backtoball").msg, self.Session:GetPetName())
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Tip)
  if not self.Register then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetPetThrowBlockForReason, false, self.Gid, _G.MainUIModuleEnum.AbilityBtnBlockReason.TaskPetFollow)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetPetRideBlockForReason, false, self.Gid, _G.MainUIModuleEnum.AbilityBtnBlockReason.TaskPetFollow)
  self:TrySetPetMainTemplateLock()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.BattleOver, self.OnBattleOver)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_START, self.OnReconnect)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.OnRefreshEvoPetModel, self.OnPetLevelUp)
  if self.bChaos then
    _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.OnPetPurify)
  end
  self.Register = false
end

function PetFollowRunner:TrySetPetMainTemplateLock()
  local PetData = self:GetPetData()
  if not PetData then
    return
  end
  local bLock = 0 ~= PetData.pet_status_flags & _G.ProtoEnum.PetStatusFlag.TASK_TOGETHER_IN_PROGRESS or 0 ~= PetData.pet_status_flags & _G.ProtoEnum.PetStatusFlag.TASK_TOGETHER_MARKING
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetMainPetTemplateLock, bLock, self.Gid)
end

function PetFollowRunner:RecyclePet(bWithoutPerform, bFake)
  if not self.Session then
    Log.Warning("[PetFollowModule] No Session When RecyclePet")
    self:TrySetPetMainTemplateLock()
    return
  end
  self.Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
  if bWithoutPerform then
    self.Session:RecycleDirect()
  else
    self.Session:ForceRecycle()
  end
  if not bFake then
    self:OnStopFollow()
    self.Session = nil
  end
end

function PetFollowRunner:OnReconnect()
  self:RecyclePet(true, false)
end

function PetFollowRunner:OnPetLevelUp(PetData)
  if PetData.gid ~= self.Gid then
    return
  end
  self:RefreshSummonPet()
end

function PetFollowRunner:OnPetPurify(ChangeItem)
  if ChangeItem and ChangeItem.pet_data and ChangeItem.pet_data.gid == self.Gid then
    local PetData = self:GetPetData()
    if PetData and PetData.mutation_type and 0 == PetData.mutation_type & _G.Enum.MutationDiffType.MDT_CHAOS_THREE then
      self:RefreshSummonPet()
      self.bChaos = false
      _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.GoodChangeTypeEnum.GT_PET, self.OnPetPurify)
    end
  end
end

function PetFollowRunner:RefreshSummonPet()
  a.task(function()
    self:RecyclePet(true, true)
    a.wait(au.NextTick())
    self:StartFollow()
  end)()
end

function PetFollowRunner:OnBattleOver()
  self:RefreshSummonPet()
end

function PetFollowRunner:StartFollow(bWithoutPerform)
  local Session = self:GetThrowSession(self:GetPetData())
  Session:SetStatus(ThrowSessionStatusEnum.PreReleasing)
  self.Session = Session
  local LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Throw_Pet)
  if not bWithoutPerform then
    LoadQueue:InsertClass("Jump", "/Game/ArtRes/Effects/G6Skill/Yuancheng/CallOut_Suc")
  end
  LoadQueue:InsertPet("Pet", self.Session)
  local TempEQSQuerier = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(UE.AActor)
  TempEQSQuerier:AddComponentByClass(UE.USceneComponent, false, UE.FTransform(), false)
  TempEQSQuerier:Abs_K2_SetActorLocation_WithoutHit(self:GetDesirePos())
  LoadQueue.EQSQuerier = TempEQSQuerier
  LoadQueue:InsertStandRelease("EQS", EQSQueryType.StandRelease, self:GetPetData(), TempEQSQuerier, 10, 200)
  LoadQueue:StartLoad(self, self.OnAllResReady)
end

function PetFollowRunner:PreSummonCheck(PetData)
  local Session = ThrowSession.GetWithGID(PetData.gid)
  if Session then
    if Session.Status ~= ThrowSessionStatusEnum.Interacting and Session.Status ~= ThrowSessionStatusEnum.CriticalInteracting or Session.NPC:IsLogicStatus(_G.Enum.SpaceActorLogicStatus.SALS_WAITING_COMBINE_INTERACT) then
      goto lbl_58
    else
      Log.Debug("[PetFollowModule] \231\178\190\231\129\181\228\189\141\228\186\142\228\186\164\228\186\146\228\184\173, \231\173\137\229\190\133\228\186\164\228\186\146\229\174\140\230\136\144")
      do
        local InteractionComp = Session.NPC:GetComponent(PetInteractionComponent)
        if InteractionComp then
          do
            local ActionInstance = InteractionComp.interactionSpecialAction or InteractionComp.interactionNormalAction
            if ActionInstance then
              ActionInstance:AddEventListener(self, PetActionEvent.OnFinish, self.WaitPetInteraction)
              self.WaitingPetServerID = Session.NPC:GetServerId()
              self.WaitingPetData = PetData
              self.WaitingSession = Session
              return false
            else
            end
          end
        else
        end
      end
      goto lbl_58
      goto lbl_58
    end
    ::lbl_58::
    Log.Debug("[PetFollowModule] \231\178\190\231\129\181\229\156\168\229\191\153\229\149\138, \228\189\134\230\152\175\229\134\141\229\191\153\228\185\159\229\191\133\233\161\187\229\144\172\228\187\142\230\136\145\228\187\172\231\154\132\229\143\172\229\148\164!")
    local OnNpcRecycleFinished
    
    function OnNpcRecycleFinished()
      Session:RemoveEventListener(self, ThrowSessionEvent.OnNpcRecycleFinished, OnNpcRecycleFinished)
      self:StartFollow(false)
    end
    
    Session:AddEventListener(self, ThrowSessionEvent.OnNpcRecycleFinished, OnNpcRecycleFinished)
    Session:ForceRecycle()
    return false
  else
    local statusId = ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL
    local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local CustomParam = Player and Player.statComponent and Player.statusComponent:GetCustomParams(statusId)
    local RideParams = CustomParam and CustomParam.ride_param
    if RideParams and next(RideParams) and RideParams.pet_gid and RideParams.owner_id == Player:GetServerId() and RideParams.pet_gid == self.Gid then
      Player:StopRide()
    end
  end
  return true
end

function PetFollowRunner:CheckStandPlane(Target, Center)
  return false
end

function PetFollowRunner:GetDesirePos()
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not LocalPlayer then
    local Pos = _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.scene_info.pt.pos
    return UE.FVector(Pos.x, Pos.y, Pos.z)
  end
  local PlayerPos = LocalPlayer:GetActorLocation()
  local LeftDirection = -LocalPlayer:GetRightVector()
  local Rotation = UE.FRotator(0, 15, 0)
  local DesiredPosDirection = Rotation:RotateVector(LeftDirection)
  return PlayerPos + DesiredPosDirection * 250
end

function PetFollowRunner:WaitPetInteraction(Action, _, Pet)
  if self.WaitingPetServerID == Pet:GetServerId() then
    local OnNpcRecycleFinished
    
    function OnNpcRecycleFinished()
      self.WaitingSession:RemoveEventListener(self, ThrowSessionEvent.OnNpcRecycleFinished, OnNpcRecycleFinished)
      self:StartFollow(false)
      self.WaitingPetData = nil
      self.WaitingPetServerID = nil
      self.WaitingSession = nil
    end
    
    self.WaitingSession:AddEventListener(self, ThrowSessionEvent.OnNpcRecycleFinished, OnNpcRecycleFinished)
    self.WaitingSession:ForceRecycle()
  else
    self.WaitingPetData = nil
    self.WaitingPetServerID = nil
    self.WaitingSession = nil
  end
  Action:RemoveEventListener(self, PetActionEvent.OnFinish, self.WaitPetInteraction)
end

function PetFollowRunner:OnAllResReady(Queue, Success)
  Queue.EQSQuerier:K2_DestroyActor()
  Queue.EQSQuerier = nil
  if not Success then
    Queue:Release()
    self:StartFollowFailed()
    return
  end
  local Pet = Queue:Get("Pet")
  local PetView = Pet and Pet.viewObj
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local DesiredPos = LocalPlayer:GetActorLocation()
  local EQSResult = Queue:GetResObject("EQS")
  if EQSResult then
    DesiredPos = EQSResult.AbsoluteLocations[1]
    DesiredPos = ThrowUtils:TweakStandLocation(DesiredPos, Pet, self:GetPetData())
  end
  PetView:SetActorLocation(DesiredPos)
  if PetView.HeadWidget then
    PetView:InitWidgetComponent(PetView.HeadWidget)
  end
  self.Session:SetStatus(ThrowSessionStatusEnum.CriticalInteracting)
  local LoadedSkill = Queue:Get("Jump")
  if not LoadedSkill then
    SceneUtils.LookAt(Pet, LocalPlayer)
    Pet:SetHeadLookAtActor(LocalPlayer.viewObj, true)
    Pet:FaceTo(LocalPlayer)
    Pet:SetVisibleForCallOutReason(true)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.ADD_THROW_SESSION_PET, self.Session)
    self.Session.canBeRecycle = false
    if Pet.AIComponent then
      Pet.AIComponent:ForceLockForReason(false, true, _G.AIDefines.LockReason.INTERACT)
      self:ResetAIGroupID(Pet)
    end
    self:OnStartFollow()
  else
    local MedalType
    local _, WearMedal = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetMedalListAndWearMedalByPetGid, self.Gid)
    if WearMedal and WearMedal.medal_data then
      local medal_conf = _G.DataConfigManager:GetMedalConf(WearMedal.medal_data.conf_id, true)
      if medal_conf then
        MedalType = medal_conf.fx_res
      end
    end
    local SkillComp = PetView.RocoSkill
    local JumpSkill = SkillComp:FindOrAddSkillObj(LoadedSkill)
    JumpSkill:SetAdditions("Pet", Pet)
    JumpSkill:SetCaster(PetView)
    local Blackboard = JumpSkill.Blackboard
    if MedalType then
      Blackboard:SetValueAsString(MedalType, MedalType)
    end
    JumpSkill:RegisterEventCallback("ActivateFailed", self, self.StartFollowFailed)
    JumpSkill:RegisterEventCallback("Interrupt", self, self.OnSummonComplete)
    JumpSkill:RegisterEventCallback("End", self, self.OnSummonComplete)
    JumpSkill:RegisterEventCallback("PreEnd", self, self.OnSummonComplete)
    JumpSkill:RegisterEventCallback("PreEndAnim", self, self.OnSummonComplete)
    JumpSkill:RegisterEventCallback("ShowPet", self, self.ShowPet)
    local Result = SkillComp:LoadAndPlaySkill(JumpSkill)
    if Result ~= UE.ESkillStartResult.Success then
      Log.Error("[PetFollowModule] Play Skill Failed")
      self:StartFollowFailed()
    end
  end
  Queue:Release()
end

function PetFollowRunner:StartFollowFailed()
  Log.Error("[PetFollowModule] Start Follow Failed")
  self.Module:TryRecyclePet(self.Gid)
end

function PetFollowRunner:ShowPet(_, SkillObject)
  local Pet = SkillObject:GetAddition("Pet")
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  SceneUtils.LookAt(Pet, LocalPlayer)
  Pet:SetHeadLookAtActor(LocalPlayer.viewObj, true)
  Pet:FaceTo(LocalPlayer)
  Pet:SetVisibleForCallOutReason(true)
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.ADD_THROW_SESSION_PET, self.Session)
  self.Session.canBeRecycle = false
end

function PetFollowRunner:OnSummonComplete(_, SkillObject)
  local Pet = SkillObject:GetAddition("Pet")
  if not Pet or not UE.UObject.IsValid(Pet.viewObj) then
    Log.Warning("[PetFollowModule] \231\186\179\229\176\188, \230\138\128\232\131\189\231\187\147\230\157\159\231\178\190\231\129\181\230\178\161\228\186\134\239\188\129")
    return
  end
  if Pet.AIComponent then
    Pet.AIComponent:ForceLockForReason(false, true, _G.AIDefines.LockReason.INTERACT)
    self:ResetAIGroupID(Pet)
  end
  self:OnStartFollow()
end

function PetFollowRunner:GetThrowSession(PetData)
  local Session = ThrowSession.GetWithGID(PetData.gid)
  if Session then
    return Session, false
  end
  Session = ThrowSession.CreatePet(PetData)
  return Session, true
end

function PetFollowRunner:ResetAIGroupID(Pet)
  Pet.serverData.ai_info.ai_override_perform_group_id = 24
  Pet.AIComponent:UpdateDataFromConfig()
end

return PetFollowRunner
