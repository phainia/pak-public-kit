local Class = _G.MakeSimpleClass
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local EventDispatcher = require("Common.EventDispatcher")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local PetActionBase = Class("PetActionBase")
local FakeSuccessSubmitResult = ProtoMessage:newZoneSceneEndThrowRsp()
FakeSuccessSubmitResult.ret_info.ret_code = 0
local FakeFailedSubmitResult = ProtoMessage:newZoneSceneEndThrowRsp()
FakeFailedSubmitResult.ret_info.ret_code = -1
EventDispatcher.BindClass(PetActionBase)
PetActionBase:SetMemberCount(12)

function PetActionBase:PreCtor()
  self.Runner = nil
  self.bIsLocalMode = false
  self.NextSubmissionMode = ActionUtils.DefaultActionSubmissionMode
  self.isMainPerformAction = true
  self.SkipSync = false
  self.ParentAction = nil
  self.disableErrorTip = false
  self.isCombineAction = false
end

function PetActionBase:Ctor(Owner, Config, Info)
  EventDispatcher():Attach(self)
  self.Owner = Owner
  self.Config = Config
  self.Info = Info
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_LOGIN, self.TryStop)
  if Owner then
    self.Owner:AddEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
  end
end

function PetActionBase:UpdateInfo(NewAction)
  self.Info = NewAction
end

function PetActionBase:OnOptionChange()
end

function PetActionBase:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionBase:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR
end

function PetActionBase:GetRangeParams()
end

function PetActionBase:GetLookAtType()
  return Enum.PetReleaseLookAt.PRLA_TARGET_NPC
end

function PetActionBase:CheckEnvironment()
  if not self.Owner then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:Owner\228\184\141\229\173\152\229\156\168")
    return false
  end
  if _G.DialogueModuleCmd and _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.HasDialogue) then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\173\163\229\156\168\229\175\185\232\175\157\228\184\173")
    return false
  end
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player.PlayerThrowInteractionComponent and Player.PlayerThrowInteractionComponent:IsPlaying() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\173\163\229\156\168\229\135\134\229\164\135\232\191\155\229\133\165\230\136\152\230\150\151")
    return false
  end
  if _G.BattleManager:IsInBattle() then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\230\136\152\230\150\151\228\184\173\231\166\129\230\173\162\228\186\164\228\186\146")
    return false
  elseif _G.BattleManager.isSendWaiting then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\232\191\155\229\133\165\230\136\152\230\150\151\232\175\183\230\177\130\229\143\145\233\128\129\228\184\173")
    return false
  end
  if self.Owner:IsDisableByOnlineModePetAction() then
    return false
  end
  local Ban, Msg = FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_PET_OPTION, false, false)
  if Ban then
    self:Log("\230\151\160\230\179\149\232\167\166\229\143\145\228\186\164\228\186\146:\228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170\231\178\190\231\129\181\228\186\164\228\186\146")
    return false
  end
  return true
end

function PetActionBase:IsEnabled()
  if not self.Owner then
    return false
  end
  if not self.Owner:IsOptionEnable(true) then
    return false
  end
  if not self:CheckEnvironment() then
    return false
  end
  return true
end

function PetActionBase:Execute(Runner)
  self.Runner = Runner
  Runner:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnRunnerLeave)
  local Owner = self:GetOwnerNPC()
  if Owner and Owner.InteractionComponent then
    Owner.InteractionComponent:TryDisableInteraction()
  end
  self:Log("Execute")
  if self.Runner:IsAThrownPet() then
    self.Runner:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.Interact)
  end
  self:SendEvent(PetActionEvent.OnExecute, self)
  self:SyncActionStart()
  self:OnExecute()
end

function PetActionBase:OnExecute()
  self:Submit()
end

function PetActionBase:Submit()
  Log.Debug("\229\144\136\229\135\187\228\186\164\228\186\146\230\151\165\229\191\151: PetActionBase:Submit", table.getKeyName(ActionUtils.ActionSubmissionMode, self.NextSubmissionMode), self.ParentAction)
  if self.bIsLocalMode or self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.Local then
    self:InternalOnSubmit(FakeSuccessSubmitResult)
    return
  end
  if not self:HasControlAuthority() then
    self:InternalOnSubmit(FakeSuccessSubmitResult)
    return
  end
  local Owner = self:GetOwnerNPC()
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.SceneNpc then
    local req = ProtoMessage:newZoneSceneNpcsInteractReq()
    req.npc_id = Owner:GetServerId()
    req.option_id = self.Owner.config.id
    req.source_npc_id = self.Runner:GetServerId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPCS_INTERACT_REQ, req, self, self.InternalOnSubmit, false, self.disableErrorTip or false)
    return
  end
  local Session = self.Runner and self.Runner.ThrowSession
  if not Session or Session:IsRecycling() or Session:IsDestroyed() then
    self:InternalOnSubmit(FakeFailedSubmitResult)
    return
  end
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.ThrowEnd then
    local req = ProtoMessage:newZoneSceneEndThrowReq()
    req.gid = self.Runner.ThrowSession:GetGID()
    req.throw_id = self.Runner.ThrowSession:GetThrowID()
    req.throw_type = ProtoEnum.ThrowType.THROW_PET
    req.throw_effect = self:GetThrowEffectType()
    req.item_conf_id = self.Runner.ThrowSession:GetItemID() or 0
    table.insert(req.throw_target_npc_infos, self.Owner:GetThrowTargetNpcInfo())
    self:EndThrowPostProcess(req)
    if self.ParentAction then
      self.ParentAction:SubmitForChild(req, self)
    else
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.InternalOnSubmit, false, self.disableErrorTip or false)
    end
  elseif self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.NextAct then
    local req = ProtoMessage:newZoneSceneNpcNextActReq()
    req.npc_id = Owner:GetServerId()
    req.option_id = self.Owner.config.id
    req.npc_pt = Owner:GetServerPoint()
    req.trig_interact_type = ProtoEnum.TrigInteractType.ENUM.ThrowPet
    req.first_act = true
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NPC_NEXT_ACT_REQ, req, self, self.InternalOnSubmit, false, self.disableErrorTip or false)
  end
end

function PetActionBase:EndThrowPostProcess(req)
end

function PetActionBase:InternalOnSubmit(rsp)
  self:Log("InternalOnSubmit")
  self:OnSubmit(rsp)
end

function PetActionBase:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  self:Finish(0 == rsp.ret_info.ret_code)
end

function PetActionBase:Finish(Success)
  self:Log("Finish", Success)
  self.NextSubmissionMode = ActionUtils.DefaultActionSubmissionMode
  if not self.Runner then
    return
  end
  if self.Runner:IsAThrownPet() and not self.isCombineAction then
    self.Runner:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.None)
  end
  self:OnFinish()
  self:SyncActionEnd()
  local TempRunner = self.Runner
  self.Runner = nil
  TempRunner:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnRunnerLeave)
  local Owner = self:GetOwnerNPC()
  if Owner and Owner.InteractionComponent then
    Owner.InteractionComponent:TryEnableInteraction()
  end
  self:SendEvent(PetActionEvent.OnFinish, self, Success, TempRunner)
end

function PetActionBase:OnFinish()
end

function PetActionBase:OnStop(reason)
end

function PetActionBase:InternalStop(reason)
  self:OnStop(reason)
  self:Finish(false)
end

function PetActionBase:Destroy()
  self:TryStop()
  EventDispatcher.Detach(self)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_LOGIN, self.TryStop)
  if self.Owner then
    self.Owner:RemoveEventListener(self, NpcOptionEvent.OptionChange, self.OnOptionChange)
    self.Owner = nil
  end
end

function PetActionBase:IsExecuting()
  return self.Runner ~= nil
end

function PetActionBase:TryStop(reason)
  if not self:IsExecuting() then
    return
  end
  self:InternalStop(reason)
end

function PetActionBase:GetRunnerView()
  if not self.Runner then
    return nil
  end
  return self.Runner.viewObj
end

function PetActionBase:GetRunnerSkillComponent()
  local View = self:GetRunnerView()
  if not View then
    return nil
  end
  local Comp = View.RocoSkill
  return Comp
end

function PetActionBase:GetOwnerNPC()
  if not self.Owner then
    return nil
  end
  return self.Owner.owner
end

function PetActionBase:GetOwnerNPCView()
  local NPC = self:GetOwnerNPC()
  return NPC and NPC.viewObj
end

function PetActionBase:SetBeforeActionSettings(PetView)
end

function PetActionBase:SetNextSubmissionMode(mode)
  self.NextSubmissionMode = mode
end

function PetActionBase:SetIsMainPerformAction(isMainPerformAction)
  self.isMainPerformAction = isMainPerformAction
end

function PetActionBase:GetIsMainPerformAction()
  return self.isMainPerformAction
end

function PetActionBase:ContinueWhenSuccess()
  return true
end

function PetActionBase:ContinueNormalInteract()
  return true
end

function PetActionBase:GetDerivedAction(PetData)
  return self
end

function PetActionBase:ConsumeOwnerActorTag()
  local Owner = self:GetOwnerNPC()
  if Owner then
    _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, Owner:GetServerId())
  else
    Log.Error("Owner\230\178\161\228\186\134...")
  end
end

function PetActionBase:OnRunnerLeave(Runner)
  if self.Runner ~= Runner then
    Log.Error("Runner\229\175\185\228\184\141\228\184\138\228\186\134", self.Runner and self.Runner:DebugNPCNameAndID() or "\229\183\178\233\148\128\230\175\129", Runner and Runner:DebugNPCNameAndID() or "\229\183\178\233\148\128\230\175\129")
    return
  end
  self:ConsumeOwnerActorTag()
end

function PetActionBase:HasControlAuthority()
  if not self.Runner then
    return false
  end
  return self.Runner:IsControlledByPlayer()
end

function PetActionBase:DontSync()
  return false
end

function PetActionBase:SetSkipSync(ShouldSkip)
  self.SkipSync = ShouldSkip
end

function PetActionBase:InternalSyncAction(Status)
  if not self.Runner then
    Log.Debug("[PetAction] Sync Failed, cant find runner")
    return
  end
  if not self.Owner then
    Log.Debug("[PetAction] Sync Failed, cant find owner")
    return
  end
  if not self.Owner.owner then
    Log.Debug("[PetAction] Sync Failed, cant find owner npc")
    return
  end
  local req = _G.ProtoMessage:newZoneClientOperationReq()
  req.operation.aim_info = nil
  req.operation.npc_action_info = nil
  local PetActionInfo = req.operation.pet_action_info
  req.operation.operator_id = self.Runner:GetServerId()
  PetActionInfo.operation_target_id = self.Owner.owner:GetServerId()
  PetActionInfo.operator_owner_id = self.Runner:GetCreatorID()
  PetActionInfo.operation_type = self.Config.action_type
  PetActionInfo.action_status = Status
  PetActionInfo.option_id = self.Owner.config.id
  PetActionInfo.conf_type = self.ConfType
  PetActionInfo.conf_id = self.ConfID
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req)
  Log.Debug("[PetAction]Sync", self.Config.action_type, self.ConfID, Status, self.Runner:GetServerId())
end

function PetActionBase:SyncActionStart()
  if not self:HasControlAuthority() then
    return
  end
  if self:DontSync() then
    return
  end
  if self.SkipSync then
    return
  end
  self:InternalSyncAction(NPCModuleEnum.ActionStatus.Begin)
end

function PetActionBase:SyncActionEnd()
  if not self:HasControlAuthority() then
    return
  end
  if self:DontSync() then
    return
  end
  if self.SkipSync then
    return
  end
  self:InternalSyncAction(NPCModuleEnum.ActionStatus.End)
end

function PetActionBase:SetSessionRecycle(canRecycle)
  local Session = self.Runner and self.Runner.ThrowSession
  if Session then
    if canRecycle then
      if Session.Status ~= ThrowSessionStatusEnum.CriticalInteracting then
        Session:SetStatus(ThrowSessionStatusEnum.Interacting)
      else
        Session:SetStatus(ThrowSessionStatusEnum.PostInteract)
      end
    else
      Session:SetStatus(ThrowSessionStatusEnum.CriticalInteracting)
    end
    Session:ForceSetCanBeRecycle(canRecycle)
  end
end

function PetActionBase:IsFakeSubmit()
  return self.bIsLocalMode or not self:HasControlAuthority() or self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.Local
end

function PetActionBase:GetDesc(Level)
  Level = Level or Log.LOG_LEVEL.ELogDebug
  if Level <= Log.GetLogLevel() then
    return "[PetAction]"
  end
  local OwnerNpc = self:GetOwnerNPC()
  local OwnerNpcInfo = OwnerNpc and OwnerNpc:DebugNPCNameAndID() or "Unknown"
  local RunnerNpc = self.Runner
  local RunnerInfo = RunnerNpc and RunnerNpc:DebugNPCNameAndID() or "Unknown"
  local OwnerConf = self.Owner and self.Owner.config
  local OwnerID = OwnerConf and OwnerConf.id or -1
  local ActionType = self.Config and self.Config.action_type or 0
  local ActionTypeName = ActionType >= 0 and table.getKeyName(Enum.ActionType, ActionType) or "Unknown"
  return string.format("[PetAction][%s]NPC=%s,Runner=%s,Option=%d,Action=%s", self.name, OwnerNpcInfo, RunnerInfo, OwnerID, ActionTypeName)
end

function PetActionBase:Log(...)
  Log.Debug(self:GetDesc(Log.LOG_LEVEL.ELogDebug), ...)
end

function PetActionBase:LogWarning(...)
  Log.Warning(self:GetDesc(Log.LOG_LEVEL.ELogWarn), ...)
end

function PetActionBase:LogError(...)
  Log.Error(self:GetDesc(Log.LOG_LEVEL.ELogError), ...)
end

return PetActionBase
