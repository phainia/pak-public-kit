require("UnLuaEx")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local TaskModuleCmd = require("NewRoco.Modules.Core.Task.TaskModuleCmd")
local BlackScreenModule = NRCModuleBase:Extend("BlackScreenModule")

function BlackScreenModule:OnActive()
  _G.NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.CLOSE_BLACK_SCREEN, self.OnCloseBlackScreen)
  _G.NRCEventCenter:RegisterEvent(self.name, self, NRCGlobalEvent.OPEN_BLACK_SCREEN, self.OnOpenBlackScreen)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = "GlobalBlack"
  registerData.panelPath = "/Game/NewRoco/Modules/System/BlackScreen/Res/UMG_GlobalBlack"
  registerData.panelLayer = _G.Enum.UILayerType.UI_LAYER_GLOBAL_BLACK
  registerData.enablePcEsc = false
  self:RegisterPanel(registerData)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, NRCGlobalEvent.OPEN_WHITE_SCREEN, self.OnOpenWhiteScreen)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, NRCGlobalEvent.CLOSE_WHITE_SCREEN, self.OnCloseWhiteScreen)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, NPCModuleEvent.On_NPC_Create, self.OnNPCEnter)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, SceneEvent.OnTeleportNotify, self.OnTeleportStart)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnTeleportEnd)
  _G.NRCEventCenter:RegisterEvent("BlackScreenModule", self, TaskModuleEvent.OnTaskUpdated, self.OnTaskUpdated)
  local MainPanelData = _G.NRCPanelRegisterData()
  MainPanelData.panelName = "GlobalWhite"
  MainPanelData.panelPath = "/Game/NewRoco/Modules/System/BlackScreen/Res/UMG_GlobalWhite"
  MainPanelData.panelLayer = _G.Enum.UILayerType.UI_LAYER_GLOBAL_BLACK
  MainPanelData.enablePcEsc = false
  self:RegisterPanel(MainPanelData)
  self:PreloadPanel()
  self.WaitEnterNPCDict = {}
  self.WaitLeaveNPCDict = {}
  self.WaitBattleDict = {}
  self.WaitAutoDialogueDict = {}
  self.WaitSequenceDict = {}
  self.WaitVideoDict = {}
  self.WaitTeleportDict = {}
  self.WaitNPCMaxDist = 5000.0
  self.MaxGlobalBlackTime = _G.DataConfigManager:GetTaskGlobalConfig("task_black_screen_floors", true)
  self.MaxGlobalBlackTime = self.MaxGlobalBlackTime and self.MaxGlobalBlackTime.num or 5.0
  self.MaxGlobalBlackTimeTeleport = _G.DataConfigManager:GetTaskGlobalConfig("task_black_screen_floors_trans", true)
  self.MaxGlobalBlackTimeTeleport = self.MaxGlobalBlackTimeTeleport and self.MaxGlobalBlackTimeTeleport.num or 15.0
  self.TasksNeedBlackScreens = {70111001}
end

function BlackScreenModule:PreloadPanel()
  if not self:HasPanel("GlobalBlack") then
    self:OpenPanel("GlobalBlack", self, self.OnGlobalBlackPreloaded)
  end
  if not self:HasPanel("GlobalWhite") then
    self:OpenPanel("GlobalWhite", self, self.OnGlobalWhitePreloaded)
  end
end

function BlackScreenModule:OnGlobalBlackPreloaded()
  Log.Info("BlackScreenModule:OnGlobalBlackPreloaded")
  self:DisablePanel("GlobalBlack")
  if self.bPendingOpenBlack then
    self:OnOpenBlackScreen(false, nil, nil)
  end
end

function BlackScreenModule:OnGlobalWhitePreloaded()
  Log.Info("BlackScreenModule:OnGlobalWhitePreloaded")
  self:DisablePanel("GlobalWhite")
  if self.bPendingOpenWhite then
    self:OnOpenWhiteScreen(false, nil, nil)
  end
end

function BlackScreenModule:OnOpenBlackScreen(bFade, Caller, Callback)
  Log.Info("BlackScreenModule:OnOpenBlackScreen")
  if self.MaxGlobalBlackTimerHandle then
    _G.DelayManager:CancelDelayById(self.MaxGlobalBlackTimerHandle)
    self.MaxGlobalBlackTimerHandle = nil
  end
  if nil == bFade then
    bFade = true
  end
  local HasPanel, _ = self:HasPanel("GlobalBlack")
  if not HasPanel then
    Log.Warning("BlackScreenModule:OnOpenBlackScreen fail, global black panel not opened, pending open black but fire callback right now")
    if Callback and Caller then
      Callback(Caller)
    end
    self.bPendingOpenBlack = true
    return
  end
  local panel = self:GetPanel("GlobalBlack")
  if not panel then
    Log.Error("BlackScreenModule:OnOpenBlackScreen, Cannot find global black panel")
    return
  end
  panel:PlayStartAnimation(Caller, Callback, bFade)
end

function BlackScreenModule:OnCloseBlackScreen(bDoFadeOut, Caller, Callback)
  Log.Info("BlackScreenModule:OnCloseBlackScreen")
  if self.MaxGlobalBlackTimerHandle then
    _G.DelayManager:CancelDelayById(self.MaxGlobalBlackTimerHandle)
    self.MaxGlobalBlackTimerHandle = nil
  end
  self:ClearGlobalBlackReason()
  self.bPendingOpenBlack = false
  bDoFadeOut = nil == bDoFadeOut and true or bDoFadeOut
  local HasPanel, _ = self:HasPanel("GlobalBlack")
  if not HasPanel then
    Log.Warning("BlackScreenModule:OnCloseBlackScreen, global black panel not opened, fire callback right now")
    if Callback and Caller then
      Callback(Caller)
    end
    return
  end
  local panel = self:GetPanel("GlobalBlack")
  if not panel then
    Log.Error("BlackScreenModule:OnCloseBlackScreen, Cannot find global black panel")
    return
  end
  panel:PlayEndAnimation(Caller, Callback, bDoFadeOut)
end

function BlackScreenModule:OnOpenWhiteScreen(bFade, Caller, Callback)
  Log.Info("BlackScreenModule:OnOpenWhiteScreen")
  local HasPanel, _ = self:HasPanel("GlobalWhite")
  if not HasPanel then
    Log.Warning("BlackScreenModule:OnOpenWhiteScreen fail, global white panel not opened, pending open white but fire callback right now")
    if Callback and Caller then
      Callback(Caller)
    end
    self.bPendingOpenWhite = true
    return
  end
  local panel = self:GetPanel("GlobalWhite")
  if not panel then
    Log.Error("BlackScreenModule:OnOpenWhiteScreen, Cannot find global white panel")
    return
  end
  panel:PlayStartAnimation(Caller, Callback, bFade)
end

function BlackScreenModule:OnCloseWhiteScreen(bDoFadeOut, Caller, Callback)
  Log.Info("BlackScreenModule:OnCloseWhiteScreen")
  self.bPendingOpenWhite = false
  local HasPanel, _ = self:HasPanel("GlobalWhite")
  if not HasPanel then
    Log.Warning("BlackScreenModule:OnCloseWhiteScreen, global white panel not opened, fire callback right now")
    if Callback and Caller then
      Callback(Caller)
    end
    return
  end
  local panel = self:GetPanel("GlobalWhite")
  if not panel then
    Log.Error("BlackScreenModule:OnCloseWhiteScreen, Cannot find global white panel")
    return
  end
  panel:PlayEndAnimation(Caller, Callback, bDoFadeOut)
end

function BlackScreenModule:OnLogin()
  Log.Warning("\230\150\173\231\186\191\233\135\141\232\191\158\228\186\134\239\188\140\230\136\145\228\187\172\230\184\133\231\144\134\230\142\137\233\187\145\231\153\189\229\177\143\231\156\139\231\156\139")
  self:OnCloseBlackScreen(false)
  self:OnCloseWhiteScreen(false)
end

function BlackScreenModule:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OPEN_BLACK_SCREEN, self.OnOpenBlackScreen)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.CLOSE_BLACK_SCREEN, self.OnCloseBlackScreen)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OPEN_WHITE_SCREEN, self.OnOpenWhiteScreen)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.CLOSE_WHITE_SCREEN, self.OnCloseWhiteScreen)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Create, self.OnNPCEnter)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnTeleportNotify, self.OnTeleportStart)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnTeleportEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.OnTaskUpdated, self.OnTaskUpdated)
end

function BlackScreenModule:OnCmdOpenGlobalBlackScreenIfNeed(TaskID, bFade, Caller, Callback, Params)
  Log.InfoFormat("BlackScreenModule:OnCmdOpenGlobalBlackScreenIfNeed, try open global transition black, bFade = %s, taskid = %d", bFade and "True" or "False", TaskID)
  local bNeedOpen = self:CheckIfNeedTransitionBlack(TaskID, Params) or -100 == TaskID
  if bNeedOpen then
    Log.InfoFormat("BlackScreenModule:OnCmdOpenGlobalBlackScreenIfNeed, open global transition black success!")
    self:DumpCurBlackReason()
    self:OnOpenBlackScreen(bFade, Caller, Callback)
    local MaxTime = Params and Params.Teleport and self.MaxGlobalBlackTimeTeleport or self.MaxGlobalBlackTime
    self.MaxGlobalBlackTimerHandle = _G.DelayManager:DelaySeconds(MaxTime, self.OnMaxGlobalBlackTimeOut, self)
    return true
  end
  Log.InfoFormat("BlackScreenModule:OnCmdOpenGlobalBlackScreenIfNeed, open global transition black fail!")
  return false
end

function BlackScreenModule:OnCmdTryCloseGlobalBlackScreenIfAny(ReasonObj, bFade)
  Log.InfoFormat("BlackScreenModule:OnCmdTryCloseGlobalBlackScreenIfAny, bFade = %s", bFade and "True" or "False")
  Log.Dump(ReasonObj, 10, "BlackScreenModule:TryClose")
  if nil == bFade then
    bFade = true
  end
  self:UpdateGlobalBlackReason(ReasonObj)
  local isOpened, _ = self:HasPanel("GlobalBlack")
  if not isOpened then
    return false
  end
  if self:CanCloseGlobalBlack() then
    Log.InfoFormat("BlackScreenModule:OnCmdTryCloseGlobalBlackScreenIfAny, Close Successfully!")
    self:OnCloseBlackScreen(nil, nil, bFade)
    return true
  end
  return false
end

function BlackScreenModule:OnCmdIsGlobalBlackScreenOn()
  return self:IsPanelEnabled("GlobalBlack")
end

function BlackScreenModule:OnMaxGlobalBlackTimeOut()
  Log.Warning("BlackScreenModule:OnMaxGlobalBlackTimeOut, close global transition black on max time out.")
  self.MaxGlobalBlackTimerHandle = nil
  self:OnCloseBlackScreen()
end

function BlackScreenModule:OnNPCEnter(npc)
  Log.Debug("BlackScreenModule:OnNPCEnter ", npc.config.id)
  local ID = npc.config.id
  if self.WaitEnterNPCDict[ID] then
    self.WaitEnterNPCDict[ID] = nil
    self:OnCmdTryCloseGlobalBlackScreenIfAny()
  end
end

function BlackScreenModule:OnNPCLeave(npc)
  Log.Debug("BlackScreenModule:OnNPCLeave ", npc.config.id)
  local ID = npc.config.id
  if self.WaitLeaveNPCDict[ID] then
    self.WaitLeaveNPCDict[ID] = nil
    self:OnCmdTryCloseGlobalBlackScreenIfAny()
  end
end

function BlackScreenModule:UpdateWaitNPCDictFromActionList(TaskActionList)
  local bRet = false
  for _, action in ipairs(TaskActionList) do
    if action.type == Enum.TaskStateChangeActionType.TSCAT_CLOSE_NPC_CONTENT then
      for _, NPCContentID in ipairs(action.data1) do
        bRet = self:UpdateWaitNPCDictFromNpcContent(NPCContentID, false, true) or bRet
      end
    end
    if action.type == Enum.TaskStateChangeActionType.TSCAT_OPEN_NPC_CONTENT then
      for _, NPCContentID in ipairs(action.data1) do
        bRet = self:UpdateWaitNPCDictFromNpcContent(NPCContentID, true, false) or bRet
        local NPCContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(NPCContentID)
        if NPCContentConf then
          local NPCID = NPCContentConf.npc_id
          local NPCConf = _G.DataConfigManager:GetNpcConf(NPCID)
          if NPCConf and NPCConf.option_id then
            for _, NPCOptionID in ipairs(NPCConf.option_id) do
              bRet = self:UpdateWaitNPCOption(NPCContentID, NPCOptionID) or bRet
            end
          end
        end
      end
    end
    if action.type == Enum.TaskStateChangeActionType.TSCAT_OPEN_CONTENT_OPT and #action.data1 > 0 then
      local NPCContentID = action.data1[1]
      for _, NPCOptionID in ipairs(action.data2) do
        bRet = self:UpdateWaitNPCOption(NPCContentID, NPCOptionID) or bRet
      end
    end
  end
  return bRet
end

function BlackScreenModule:IsNPCContentInRange(NPCContentID, Radius)
  local SceneResId, Pos = self:GetSceneResIdAndPosByNpcContent(NPCContentID)
  if self:CheckScenePosNearPlayer(SceneResId, Pos, Radius) then
    return true
  end
  return false
end

function BlackScreenModule:UpdateWaitNPCDictFromNpcContent(NpcContentID, bWaitCreate, bWaitLeave)
  if not bWaitCreate and not bWaitLeave then
    return
  end
  local NpcContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(NpcContentID)
  if NpcContentConf then
    local NpcConf = _G.DataConfigManager:GetNpcConf(NpcContentConf.npc_id)
    local NpcModelConf = _G.DataConfigManager:GetModelConf(NpcConf and NpcConf.model_conf)
    if NpcModelConf and string.find(NpcModelConf.path, "BP_NPCAppear") then
      return false
    end
    local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshID, NpcContentID)
    if npc and bWaitCreate then
      Log.DebugFormat("BlackScreenModule, do not need to wait npc %d in npc content %d create as it is created already!", NpcContentConf.npc_id, NpcContentID)
      return false
    end
    if not npc and bWaitLeave then
      Log.DebugFormat("BlackScreenModule, do not need to wait npc %d in npc content %d leave as it is not currently created!", NpcContentConf.npc_id, NpcContentID)
      return false
    end
    if self:IsNPCContentInRange(NpcContentID, self.WaitNPCMaxDist) then
      if bWaitCreate then
        self.WaitEnterNPCDict[NpcContentConf.npc_id] = true
      end
      if bWaitLeave then
        self.WaitLeaveNPCDict[NpcContentConf.npc_id] = true
      end
      return true
    end
  end
  return false
end

function BlackScreenModule:UpdateWaitNPCOption(NPCContentID, NPCOptionID)
  local NPCOptionConf = _G.DataConfigManager:GetNpcOptionConf(NPCOptionID, true)
  if NPCOptionConf and NPCOptionConf.action.action_type == Enum.ActionType.ACT_DIALOG and (NPCOptionConf.npc_interact_type == Enum.InteractType.IT_AUTO or NPCOptionConf.npc_interact_type == Enum.InteractType.IT_AUTOMANUAL) and self:IsNPCContentInRange(NPCContentID, NPCOptionConf.option_radius) then
    local DialogueID = tonumber(NPCOptionConf.action.action_param1)
    self.WaitAutoDialogueDict[DialogueID] = true
    return true
  end
  return false
end

function BlackScreenModule:GetSceneResIdAndPosByNpcContent(NpcContentID)
  local sceneId = 10003
  local pos
  local npc_refresh = _G.DataConfigManager:GetNpcRefreshContentConf(NpcContentID)
  if npc_refresh then
    local refresh_param = npc_refresh.refresh_param or 0
    if npc_refresh.refresh_type == Enum.RefreshType.RFT_AREA then
      local area_conf = _G.DataConfigManager:GetAreaConf(refresh_param, true)
      if area_conf then
        sceneId = area_conf.scene_res_id or sceneId
        pos = UE4.FVector(area_conf.center_xyz[1], area_conf.center_xyz[2], area_conf.center_xyz[3])
      end
    elseif npc_refresh.refresh_type == Enum.RefreshType.RFT_NPC or npc_refresh.refresh_type == Enum.RefreshType.RFT_RELY then
      sceneId, pos = self:GetSceneResIdAndPosByNpcContent(refresh_param)
    elseif npc_refresh.refresh_type == Enum.RefreshType.RFT_BYTAGID or npc_refresh.refresh_type == Enum.RefreshType.RFT_BYTAG then
      local scene_conf = _G.DataConfigManager:GetSceneObjectConf(refresh_param, true)
      if scene_conf then
        sceneId = self:GetSceneResIdByPos(scene_conf.position_xyz[1], scene_conf.position_xyz[2])
        pos = UE4.FVector(scene_conf.position_xyz[1], scene_conf.position_xyz[2], scene_conf.position_xyz[3])
      end
    else
      sceneId = npc_refresh.refresh_type == Enum.RefreshType.RFT_BONUS and SceneUtils.GetSceneResId() or sceneId
    end
  end
  return sceneId, pos
end

function BlackScreenModule:CheckScenePosNearPlayer(SceneResID, Pos, Radius)
  if not SceneResID and not Pos then
    return false
  end
  if SceneResID and SceneUtils.GetSceneResId() ~= SceneResID then
    return false
  end
  if Pos then
    local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if LocalPlayer then
      local PlayerPos = LocalPlayer:GetActorLocation()
      local PlayerDist = PlayerPos:Dist(Pos)
      if Radius < PlayerDist then
        return false
      end
    end
  end
  return true
end

function BlackScreenModule:GetSceneResIdByPos(posX, posY)
  if posX >= -1000000.0 and posX <= -600000.0 and posY >= -1000000.0 and posY <= -600000.0 then
    return 10018
  end
  return 10003
end

function BlackScreenModule:CheckIfNeedTransitionBlack(TaskID, Params)
  if TaskID <= 0 then
    return false
  end
  local TaskConf = _G.DataConfigManager:GetTaskConf(TaskID)
  if not TaskConf then
    return false
  end
  if TaskConf.task_structure_type == ProtoEnum.TaskStructureType.TSTT_NONE then
    return false
  end
  local OptionID = Params and Params.OptionID
  if TaskConf.task_condition and #TaskConf.task_condition > 1 then
    local TaskInfo = _G.NRCModuleManager:DoCmd(TaskModuleCmd.getTaskByID, TaskID)
    if TaskInfo and TaskInfo.task_target_list then
      for index, task_condition in ipairs(TaskConf.task_condition) do
        task_target = index <= #TaskInfo.task_target_list and TaskInfo.task_target_list[index] or 0
        if task_target <= 0 then
          if task_condition.type == Enum.TaskKeyType.TKT_STATE_OPTION then
            local ConditionOptionID = task_condition.data1[1]
            if ConditionOptionID ~= OptionID then
              return false
            end
          else
            return false
          end
        end
      end
    end
  end
  local bRet = false
  bRet = self:UpdateWaitNPCDictFromActionList(TaskConf.finish_action) or bRet
  if TaskConf.next_task_type == Enum.NextTaskType.NEXT_TASK_ALL or 0 == TaskConf.next_task_type then
    for _, NextTaskID in ipairs(TaskConf.next_task) do
      local NextTaskConf = _G.DataConfigManager:GetTaskConf(NextTaskID)
      bRet = self:UpdateWaitNPCDictFromActionList(NextTaskConf.accept_action) or bRet
      bRet = self:CheckIfTaskContainsBattle(NextTaskConf) or bRet
      bRet = self:CheckIfTaskContainsSequence(NextTaskConf) or bRet
      bRet = self:CheckIfTaskContainsTeleport(NextTaskConf) or bRet
    end
  end
  return bRet
end

function BlackScreenModule:CheckIfTaskContainsBattle(TaskConf)
  if not TaskConf then
    return false
  end
  local bRet = false
  for _, condition in ipairs(TaskConf.task_condition) do
    if condition.type == Enum.TaskKeyType.TKT_STATE_OPTION then
      for _, option_id in ipairs(condition.data1) do
        local OptionConf = _G.DataConfigManager:GetNpcOptionConf(option_id)
        if OptionConf and OptionConf.action.action_type == Enum.ActionType.ACT_BATTLE then
          local BattleID = tonumber(OptionConf.action.action_param2)
          local BattleConf = _G.DataConfigManager:GetBattleConf(BattleID)
          if BattleConf and table.contains(BattleConf.task_battle_performance_control, Enum.TaskBattlePerformanceControl.TBPC_ENTER_BLACK) then
            self.WaitBattleDict[BattleID] = true
            bRet = true
          end
        end
      end
    end
  end
  return bRet
end

function BlackScreenModule:CheckIfTaskContainsSequence(TaskConf)
  if not TaskConf then
    return false
  end
  local bRet = false
  for _, action in ipairs(TaskConf.accept_action) do
    if action.type == Enum.TaskStateChangeActionType.TSCAT_ADD_SEQUENCE then
      local SequenceID = tonumber(action.data1[1])
      self.WaitSequenceDict[SequenceID] = true
      bRet = true
    elseif action.type == Enum.TaskStateChangeActionType.TSCAT_ADD_MP4 then
      local MaleVideoID = tonumber(action.data1[1])
      local FemaleVideoID = tonumber(action.data1[2])
      if MaleVideoID and FemaleVideoID then
        self.WaitVideoDict[MaleVideoID] = {MaleVideoID, FemaleVideoID}
        self.WaitVideoDict[FemaleVideoID] = {MaleVideoID, FemaleVideoID}
        bRet = true
      end
    end
  end
  return bRet
end

function BlackScreenModule:CheckIfTaskContainsTeleport(TaskConf)
  if not TaskConf then
    return false
  end
  local bRet = false
  if TaskConf.task_structure_type == Enum.TaskStructureType.TSTT_TELEPORT then
    for _, condition in ipairs(TaskConf.task_condition) do
      if condition.type == Enum.TaskKeyType.TKT_REACH_POINT then
        local SceneResID = #condition.data1 > 0 and tonumber(condition.data1[1])
        if SceneResID then
          self.WaitTeleportDict[SceneResID] = true
          bRet = true
        end
      end
    end
  end
  return bRet
end

function BlackScreenModule:UpdateGlobalBlackReason(ReasonObj)
  if not ReasonObj then
    return
  end
  if ReasonObj.BattleID then
    self.WaitBattleDict[ReasonObj.BattleID] = nil
  end
  if ReasonObj.DialogueID then
    self.WaitAutoDialogueDict[ReasonObj.DialogueID] = nil
  end
  if ReasonObj.Teleport then
    self.WaitTeleportDict[ReasonObj.Teleport] = nil
  end
end

function BlackScreenModule:CanCloseGlobalBlack()
  if table.len(self.WaitEnterNPCDict) > 0 then
    return false
  end
  if table.len(self.WaitLeaveNPCDict) > 0 then
    return false
  end
  if table.len(self.WaitBattleDict) > 0 then
    return false
  end
  if table.len(self.WaitAutoDialogueDict) > 0 then
    return false
  end
  if table.len(self.WaitVideoDict) > 0 then
    return false
  end
  if table.len(self.WaitSequenceDict) > 0 then
    return false
  end
  if table.len(self.WaitTeleportDict) > 0 then
    return false
  end
  return true
end

function BlackScreenModule:ClearGlobalBlackReason()
  table.clear(self.WaitEnterNPCDict)
  table.clear(self.WaitLeaveNPCDict)
  table.clear(self.WaitBattleDict)
  table.clear(self.WaitAutoDialogueDict)
  table.clear(self.WaitSequenceDict)
  table.clear(self.WaitVideoDict)
  table.clear(self.WaitTeleportDict)
end

function BlackScreenModule:DumpCurBlackReason()
  Log.Dump(self.WaitEnterNPCDict, 10, "BlackScreenModule.WaitEnterNPCDict")
  Log.Dump(self.WaitLeaveNPCDict, 10, "BlackScreenModule.WaitLeaveNPCDict")
  Log.Dump(self.WaitBattleDict, 10, "BlackScreenModule.WaitBattleDict")
  Log.Dump(self.WaitAutoDialogueDict, 10, "BlackScreenModule.WaitAutoDialogueDict")
  Log.Dump(self.WaitSequenceDict, 10, "BlackScreenModule.WaitSequenceDict")
  Log.Dump(self.WaitVideoDict, 10, "BlackScreenModule.WaitVideoDict")
  Log.Dump(self.WaitTeleportDict, 10, "BlackScreenModule.WaitTeleportDict")
end

function BlackScreenModule:OnTeleportStart(notify)
  NRCModuleManager:DoCmd(BlackScreenModuleCmd.TryCloseGlobalBlackScreenIfAny, {
    Teleport = notify.to_scene_cfg_id
  }, false)
end

function BlackScreenModule:OnTeleportEnd()
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  local TaskModule = _G.NRCModuleManager:GetModule("TaskModule")
  if SceneModule and SceneModule.ZoneSceneTeleportNotify and TaskModule and TaskModule.TeleportingTask then
    local TeleportSceneResID = TaskModule.TeleportingTask.Config.task_special_structure_area[1]
    if TeleportSceneResID == SceneModule.ZoneSceneTeleportNotify.from_scene_cfg_id then
      local TaskID = TaskModule.TeleportingTask.Config.id
      local bIsSkip = false
      bIsSkip = _G.NRCModuleManager:DoCmd(TaskModuleCmd.IsSkipTask, TaskID)
      if not bIsSkip then
        NRCModuleManager:DoCmd(BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, TaskID, false, nil, nil, {
          Teleport = True
        })
      else
        Log.Debug("BlackScreenModule:OnTeleportEnd, bIsSkip ", TaskID)
      end
    end
  end
  if TaskModule and TaskModule.TeleportingTask then
    TaskModule:ClearTeleportingTask(TaskModule.TeleportingTask)
  end
end

function BlackScreenModule:OnTaskUpdated(info)
  if info and info.id and _G.NRCModuleManager:DoCmd(_G.LoadingUIModuleCmd.HasAnyLoadingUI) and table.contains(self.TasksNeedBlackScreens, info.id) and info.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
    Log.InfoFormat("BlackScreenModule:OnTaskUpdated, %d", info.id)
    NRCModuleManager:DoCmd(BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, -100, false)
    table.removeValue(self.TasksNeedBlackScreens, info.id)
  end
end

return BlackScreenModule
