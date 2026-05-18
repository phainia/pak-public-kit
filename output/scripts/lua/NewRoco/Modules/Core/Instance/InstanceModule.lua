local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local InstanceModuleEvent = reload("NewRoco.Modules.Core.Instance.InstanceModuleEvent")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local StatusCheckerEnum = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerEnum")
local StatusCheckerGroup = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerGroup")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DungeonStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.DungeonStatusComponent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local InstanceModule = NRCModuleBase:Extend("InstanceModule")

function InstanceModule:OnConstruct()
  local EnterPanel = _G.NRCPanelRegisterData()
  EnterPanel.panelName = "InstanceModuleEnterPanel"
  EnterPanel.panelPath = "/Game/NewRoco/Modules/System/Instance/Res/UMG_EnterPanel"
  EnterPanel.panelLayer = _G.Enum.UILayerType.UI_LAYER_POPUP
  EnterPanel.isSingleTouchPanel = true
  self:RegisterPanel(EnterPanel)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_DUNGEON_DATA_NOTIFY, self.OnDungeonDataNotify)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_DUNGEON_STAGE_NOTIFY, self.OnDungeonStateNotify)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SYNC_NOTIFY, self.UpdateDungeonStatus)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.UPDATE_DATA, self.OnPlayerDataUpdated)
  self.HasBattle = _G.BattleManager:IsInBattle()
  _G.NRCEventCenter:RegisterEvent(self.name, self, TaskModuleEvent.BattleStart, self.OnEnterBattle)
  _G.NRCEventCenter:RegisterEvent(self.name, self, TaskModuleEvent.BattleOver, self.OnExitBattle)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.PostLoadMapWithWorld, self.OnLevelChanged)
  _G.NRCEventCenter:RegisterEvent(self.name, self, TipsModuleEvent.Tips_DungeonTipShowFinish, self.OnDungeonFinishedTips)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.OnTeleportNotify, self.OnTeleportStart)
  self.finishedDungeonConfID = nil
  self.StatusChecker = StatusCheckerGroup({
    StatusCheckerEnum.Scene,
    StatusCheckerEnum.Battle
  }, Log.LOG_LEVEL.ELogDebug)
  self.DungeonStates = {}
end

function InstanceModule:OnDestruct()
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_DUNGEON_DATA_NOTIFY, self.OnDungeonDataNotify)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_DUNGEON_STAGE_NOTIFY, self.OnDungeonStateNotify)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_SYNC_NOTIFY, self.UpdateDungeonStatus)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.UPDATE_DATA, self.OnPlayerDataUpdated)
  _G.NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleStart, self.OnEnterBattle)
  _G.NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleOver, self.OnExitBattle)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.PostLoadMapWithWorld, self.OnLevelChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, TipsModuleEvent.Tips_DungeonTipShowFinish, self.OnDungeonFinishedTips)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnTeleportNotify, self.OnTeleportStart)
end

function InstanceModule:OnPlayerDataUpdated()
  if self:IsInDungeon() then
    _G.FunctionBanManager:AddPlayerConditionType(Enum.PlayerConditionType.PCT_DUNGEON)
  else
    _G.FunctionBanManager:RemovePlayerConditionType(Enum.PlayerConditionType.PCT_DUNGEON)
  end
end

function InstanceModule:OnTeleportStart()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_CloseItemTips)
  self:ClosePanel("InstanceModuleEnterPanel")
end

function InstanceModule:OnDungeonDataNotify(Notify)
  self:CheckSwitchDungeonEnd()
  local CurDungeonID = DataModelMgr.PlayerDataModel:GetDungeonID()
  local DungeonStateList = Notify.dungeon_state_list
  Log.Dump(Notify, 5, "InstanceModule:OnDungeonDataNotify")
  if DungeonStateList and next(DungeonStateList) then
    for i = 1, #DungeonStateList do
      local dungeonStateInfo = DungeonStateList[i]
      local dungeonId = dungeonStateInfo.dungeon_id
      self.DungeonStates[dungeonId] = dungeonStateInfo
      if dungeonStateInfo.need_bst_finish then
        if dungeonId == CurDungeonID then
          if dungeonStateInfo.finish_stage_ids and #dungeonStateInfo.finish_stage_ids > 0 then
            self.StatusChecker:Check(self, self.ShowDungeonStateCompletedTips, dungeonId, dungeonStateInfo.finish_stage_ids[1])
          else
            self.StatusChecker:Check(self, self.ShowDungeonFinishedTips, dungeonId)
          end
        elseif dungeonStateInfo.finish_stage_ids and #dungeonStateInfo.finish_stage_ids > 0 then
          self:SendAckReceiveDungeonFinishReq(dungeonId, dungeonStateInfo.finish_stage_ids[1])
        else
          self:SendAckReceiveDungeonFinishReq(dungeonId, nil)
        end
      end
    end
  end
end

function InstanceModule:OnDungeonStateNotify(Notify)
  Log.Dump(Notify, 5, "InstanceModule:OnDungeonStateNotify")
  if Notify.stage_cfg_id and #Notify.stage_cfg_id > 0 then
    self:InsertFinishStage(Notify.dungeon_cfg_id, Notify.stage_cfg_id[1])
  end
  if Notify.dungeon_finish then
    self:OnDungeonFinished(Notify.dungeon_cfg_id)
    self.StatusChecker:Check(self, self.ShowDungeonFinishedTips, Notify.dungeon_cfg_id)
    if _G.GlobalConfig.bShouldShowRevivePointInfo then
      self:SendGetDungeonCurStageReq()
    end
  elseif Notify.stage_cfg_id and #Notify.stage_cfg_id > 0 then
    self.StatusChecker:Check(self, self.ShowDungeonStateCompletedTips, Notify.dungeon_cfg_id, Notify.stage_cfg_id[1])
    if _G.GlobalConfig.bShouldShowRevivePointInfo then
      self:SendGetDungeonCurStageReq()
    end
  else
    Log.Error("InstanceModule:OnDungeonStateNotify dungeon_finish=false, and state_cfg_id is empty.")
  end
end

function InstanceModule:InsertFinishStage(DungeonID, StageID)
  if self.DungeonStates and self.DungeonStates[DungeonID] then
    if not self.DungeonStates[DungeonID].finished_stage_ids then
      self.DungeonStates[DungeonID].finished_stage_ids = {}
    end
    table.insert(self.DungeonStates[DungeonID].finished_stage_ids, StageID)
  end
end

function InstanceModule:OnDungeonFinished(DungeonID)
  if self.DungeonStates and self.DungeonStates[DungeonID] then
    self.DungeonStates[DungeonID].dungeon_state = ProtoEnum.DungeonState.DS_DONE
  end
end

function InstanceModule:SendAckReceiveDungeonFinishReq(dungeon_cfg_id, stage_cfg_id)
  if not dungeon_cfg_id then
    Log.Error("InstanceModule:SendAckReceiveDungeonFinishReq must have a dungeon_cfg_id")
    return
  end
  local req = ProtoMessage:newZoneAckReceiveDungeonFinishReq()
  req.dungeon_cfg_id = dungeon_cfg_id
  if stage_cfg_id then
    table.insert(req.stage_cfg_ids, stage_cfg_id)
  end
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_ACK_RECEIVE_DUNGEON_FINISH_REQ, req)
  Log.Debug("InstanceModule send ZONE_ACK_RECEIVE_DUNGEON_FINISH_REQ", dungeon_cfg_id, stage_cfg_id)
end

function InstanceModule:ShowDungeonFinishedTips(dungeon_cfg_id)
  Log.Debug("InstanceModule:ShowDungeonFinishedTips", dungeon_cfg_id)
  local dungeonCfg = self:GetDungeonConf(dungeon_cfg_id)
  if dungeonCfg then
    local tip = dungeonCfg.name
    if dungeonCfg.has_finish_ui then
      if self.finishedDungeonConfID then
        return
      end
      self.finishedDungeonConfID = dungeon_cfg_id
      _G.DelayManager:DelaySeconds(2, function()
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.FromDungeonCompleted(tip))
      end)
    end
  end
end

function InstanceModule:OnDungeonFinishedTips()
  if not self.finishedDungeonConfID then
    return
  end
  self:SendAckReceiveDungeonFinishReq(self.finishedDungeonConfID, nil)
  Log.Debug("\231\161\174\228\191\157\229\137\175\230\156\172\231\187\147\230\157\159\230\146\173\230\138\165\230\146\173\230\148\190\229\174\140\230\136\144\229\134\141\228\184\138\228\188\160\230\156\141\229\138\161\229\153\168\231\187\147\230\157\159\232\175\183\230\177\130")
  self.finishedDungeonConfID = nil
end

function InstanceModule:ShowDungeonStateCompletedTips(dungeon_cfg_id, stage_cfg_id)
  if not dungeon_cfg_id or not stage_cfg_id then
    Log.Error("InstanceModule:ShowDungeonStateCompletedTips must have dungeon_cfg_id and stage_cfg_ids.")
    return
  end
  Log.Debug("InstanceModule:ShowDungeonStateCompletedTips", dungeon_cfg_id, stage_cfg_id)
  local dungeonStateCfg = self:GetDungeonStageConf(stage_cfg_id)
  if dungeonStateCfg then
    if dungeonStateCfg.has_stage_finish_ui then
      local tip = dungeonStateCfg.stage_name or "NULL CONFIG"
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.FromDungeonStateCompleted(tip))
    end
    self:SendAckReceiveDungeonFinishReq(dungeon_cfg_id, stage_cfg_id)
  end
end

function InstanceModule:OnEnterBattle()
  self.HasBattle = true
  self:UpdateDungeonStatus()
end

function InstanceModule:OnExitBattle()
  self.HasBattle = false
  self:UpdateDungeonStatus()
end

function InstanceModule:OnLevelChanged(World)
  self:UpdateDungeonStatus()
end

function InstanceModule:UpdateDungeonStatus()
  self:UpdateDungeonLight()
  self:OnPlayerDataUpdated()
end

function InstanceModule:UpdateDungeonLight()
  local Conf = SceneUtils.GetSceneResConf()
  local NeedLight = Conf and Conf.if_mainchara_light_scene
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerView = localPlayer and localPlayer.viewObj
  if not PlayerView then
    return
  end
  if NeedLight then
    if not PlayerView.SpotLightActor then
      local Klass = _G.NRCBigWorldPreloader:Get("DungeonLight")
      local SpotLightActor = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(Klass)
      if SpotLightActor then
        SpotLightActor:K2_AttachToActor(localPlayer.viewObj, nil, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative, UE4.EAttachmentRule.KeepRelative)
        PlayerView.SpotLightActor = SpotLightActor
      end
    end
  else
    PlayerView.SpotLightActor = nil
  end
end

function InstanceModule:OnActive()
  NRCEventCenter:RegisterEvent(self.moduleName, self, _G.NRCGlobalEvent.ON_RECONNECT_ENDURING, self.OnDisconnectProc)
  NRCEventCenter:RegisterEvent(self.moduleName, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
  self:UpdateDungeonStatus()
end

function InstanceModule:OnDeactive()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.UpdateDungeonStatus)
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_ENDURING, self.OnDisconnectProc)
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
end

function InstanceModule:OnDisconnectProc(errorCode, extend, extend2, extend3)
  self:Log("InstanceModule::OnDisconnectProc", errorCode, extend, extend2, extend3)
  if self.bOnLeavePanelOpened then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
  end
end

function InstanceModule:OnReconnectFinish()
  self:Log("InstanceModule::OnReconnectFinish")
  if self.bOnLeavePanelOpened then
    self:CancelLeavePanel()
  end
end

function InstanceModule:OnLeaveDungeonRsp(rsp)
  self:CheckSwitchDungeonEnd()
  _G.NRCEventCenter:DispatchEvent(InstanceModuleEvent.RefreshMainPanelTasks)
end

function InstanceModule:GetDungeonConf(Did)
  local Dconf = _G.DataConfigManager:GetDungeonConf(Did, true)
  if Dconf then
    return Dconf
  else
    Log.Debug("InstanceModule: Dungeon Not Found ", Did)
    return nil
  end
end

function InstanceModule:GetDungeonStageConf(Did)
  local Dconf = _G.DataConfigManager:GetDungeonStage(Did, true)
  if Dconf then
    return Dconf
  else
    Log.Debug("InstanceModule: Dungeon State Not Found ", Did)
    return nil
  end
end

function InstanceModule:GetCurrentDungeon()
  if _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id then
    return _G.DataModelMgr.PlayerDataModel.playerInfo.common_info.in_dungeon_id[1]
  end
  return self.CurrentDungeon
end

function InstanceModule:GetDungeonInfo(Did)
  local FoundDid = Did or self:GetCurrentDungeon()
  if self.DungeonStates and FoundDid then
    return self.DungeonStates[FoundDid]
  end
  return nil
end

function InstanceModule:IsInDungeon()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo()
  if not PlayerInfo then
    return false
  end
  local CommonInfo = PlayerInfo and PlayerInfo.common_info
  if not CommonInfo then
    return false
  end
  local DungeonIDs = CommonInfo and CommonInfo.in_dungeon_id
  if not DungeonIDs or 0 == #DungeonIDs then
    return false
  end
  return DungeonIDs[1] > 0
end

function InstanceModule:OnOpenEnterPanel(Action, InstanceID)
  Log.Debug("InstanceModule: OnOpenEnterPanel")
  self:LockPlayer()
  self:OpenPanel("InstanceModuleEnterPanel")
  if Action then
    self.CurrentAction = Action
  end
  if InstanceID then
    self.CurrentDungeon = InstanceID
  end
  self:RegisterEvent(self, InstanceModuleEvent.EnterPanelClosed, self.OnCloseEnterPanel)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_START, self.CancelEnter)
end

function InstanceModule:CmdCloseEnterPanel()
  self:ClosePanel("InstanceModuleEnterPanel")
end

function InstanceModule:CancelEnter()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_START, self.CancelEnter)
  self:ClosePanel("InstanceModuleEnterPanel")
  self:OnCloseEnterPanel("1")
end

function InstanceModule:OnOpenLeavePanel(Action)
  if self.bSwitching or self.bOnLeavePanelOpened then
    return
  end
  self.bOnLeavePanelOpened = true
  if not Action then
    _G.NRCAudioManager:PlaySound2DAuto(1067, "InstanceModule:OnOpenLeavePanel")
  end
  Log.Debug("InstanceModule: OnOpenLeavePanel")
  self:LockPlayer()
  local Nomen = ""
  local msg = ""
  local Dconf = self:GetDungeonConf(self:GetCurrentDungeon())
  if Dconf then
    Nomen = Dconf.name
    msg = string.format(LuaText.Dung_Leave_Once, Dconf.name)
  end
  OpenMessageBoxWthCaller(Nomen, msg, LuaText.instancemodule_1, LuaText.instancemodule_2, DialogContext.Mode.OK_CANCEL, self.OnCloseLeavePanel, self, nil, false, true)
  _G.NRCEventCenter:RegisterEvent(self.name, self, BattleEvent.EnterBattle, self.CancelLeavePanel)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.SceneEvent.OnPlayerDead, self.CancelLeavePanel)
  if Action then
    self.CurrentAction = Action
  end
end

function InstanceModule:CancelLeavePanel()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_CloseDialog)
  self:UnLockPlayer()
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.EnterBattle, self.CancelLeavePanel)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnPlayerDead, self.CancelLeavePanel)
  self.bOnLeavePanelOpened = false
  self.bSwitching = nil
end

function InstanceModule:OnCloseEnterPanel(Ret_Param)
  Log.Debug("InstanceModule: OnCloseEnterPanel")
  self:UnLockPlayer()
  if self.CurrentAction then
    self.CurrentAction:Finish(true, nil, Ret_Param)
  end
  if "0" == Ret_Param then
    self:OnSwitchDungeon()
  end
  self.CurrentAction = nil
  self:UnRegisterEvent(self, InstanceModuleEvent.EnterPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_START, self.CancelEnter)
end

function InstanceModule:OnCloseLeavePanel(LeaveFlag)
  self.bOnLeavePanelOpened = false
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.EnterBattle, self.CancelLeavePanel)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnPlayerDead, self.CancelLeavePanel)
  local Param1 = 0
  if self.CurrentAction then
    Param1 = self.CurrentAction.TeleportID
    self.CurrentAction:Finish()
  end
  self.CurrentAction = nil
  Log.Debug("InstanceModule: OnCloseLeavePanel ", LeaveFlag)
  self:UnLockPlayer()
  if LeaveFlag and self:CanLeave() then
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      localPlayer:StopRide(true, nil)
    end
    _G.NRCAudioManager:PlaySound2DAuto(1002, "InstanceModule:OnCloseLeavePanel")
    local Request = ProtoMessage:newZoneExitDungeonReq()
    Request.teleport_id = Param1
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_EXIT_DUNGEON_REQ, Request, self, self.OnLeaveDungeonRsp)
    self:OnSwitchDungeon()
  else
    _G.NRCAudioManager:PlaySound2DAuto(1006, "InstanceModule:OnCloseLeavePanel")
  end
end

function InstanceModule:CanLeave()
  return not _G.FunctionBanManager:GetFunctionState(_G.Enum.PlayerFunctionBanType.PFBT_UI_DUNGEON_EXIT, true, true)
end

function InstanceModule:CheckPlayerDungeonStatus(Status)
  local bInDungeon = _G.DataModelMgr.PlayerDataModel:IsInDungeon()
  if not bInDungeon then
    return
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local DungeonStatusComp = localPlayer:EnsureComponent(DungeonStatusComponent)
  return DungeonStatusComp:CheckCurDungeonStatus(Status)
end

function InstanceModule:SetPlayerDungeonStatus(bAdd, Status, Caster)
  local bInDungeon = _G.DataModelMgr.PlayerDataModel:IsInDungeon()
  if not bInDungeon then
    return
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local DungeonStatusComp = localPlayer:EnsureComponent(DungeonStatusComponent)
  DungeonStatusComp:SetDungeonStatus(bAdd, Status, Caster)
end

function InstanceModule:OnSwitchDungeon()
  if self.bSwitching then
    return
  end
  self.bSwitching = true
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.AddInputBlockMappingContext, "InstanceModule:OnSwitchDungeon")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenInputBlocker)
end

function InstanceModule:CheckSwitchDungeonEnd()
  if self.bSwitching then
    self.bSwitching = nil
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.RemoveInputBlockMappingContext, "InstanceModule:SwitchDungeonEnd")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker)
  end
end

function InstanceModule:SendGetDungeonCurStageReq()
  local req = _G.ProtoMessage:newZoneGmGetDungeonCurStageReq()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_DUNGEON_CUR_STAGE_REQ, req)
end

function InstanceModule:LockPlayer()
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, false, "DungeonLock")
  localPlayer.inputComponent:SetCameraControlEnable(self, false)
end

function InstanceModule:UnLockPlayer()
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, true, "DungeonLock")
  localPlayer.inputComponent:SetCameraControlEnable(self, true)
end

function InstanceModule:GetDungeonStageDone(StageID, DID)
  local FoundDID = DID or self:GetCurrentDungeon()
  if self.DungeonStates and FoundDID then
    local DungeonState = self.DungeonStates[FoundDID]
    if DungeonState and DungeonState.finished_stage_ids then
      for _, v in ipairs(DungeonState.finished_stage_ids) do
        if v == StageID then
          return true
        end
      end
    end
  end
  return false
end

return InstanceModule
