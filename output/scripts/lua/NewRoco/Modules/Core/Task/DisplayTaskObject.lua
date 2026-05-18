local Class = _G.MakeSimpleClass
local DisplayTaskTypeEnum = require("NewRoco.Modules.Core.Task.DisplayTaskTypeEnum")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local EventDispatcher = require("Common.EventDispatcher")
local DisplayTaskObject = Class("DisplayTaskObject")
EventDispatcher.BindClass(DisplayTaskObject)
DisplayTaskObject:SetMemberCount(8)

function DisplayTaskObject:Ctor(Module, TaskType, ID)
  EventDispatcher():Attach(self)
  self.ID = ID
  self.Type = TaskType
  self.Module = Module
  if self.Type == DisplayTaskTypeEnum.SUB_TASK then
    self.Config = _G.DataConfigManager:GetSubTaskConf(ID)
  elseif self.Type == DisplayTaskTypeEnum.NEW_TASK then
    self.Task = self.Module.data.TaskMap[self.ID]
    self.Config = self.Task.Config
  end
  self.ShouldShow = true
  self.isTrack = false
end

function DisplayTaskObject:ConsumeShow()
  if not self.ShouldShow then
    return
  end
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.ConsumeSubTaskIDs)
  Log.Debug("Task show is consumed...")
  self.ShouldShow = false
end

function DisplayTaskObject:ConsumeRemove()
  Log.Debug("Task complete is consumed...")
end

function DisplayTaskObject:TaskTitle()
  return ""
end

function DisplayTaskObject:ShouldDisplay()
  return true
end

function DisplayTaskObject:GetMainText()
  if self.Type == DisplayTaskTypeEnum.SUB_TASK then
    return string.format(LuaText.sub_task_letter_source, self.Config.task_source_des2)
  elseif self.Type == DisplayTaskTypeEnum.NEW_TASK then
    if self.Task.Config.message_id > 0 and not string.IsNilOrEmpty(self.Task.Config.receive_des) then
      return self.Task.Config.receive_des
    else
      return LuaText.task_tracking_new
    end
  elseif self.Type == DisplayTaskTypeEnum.ON_GOING_TASK then
    return LuaText.task_tracking_undone
  elseif self.Type == DisplayTaskTypeEnum.ACCEPTABLE_TASK then
    return LuaText.task_tracking_acceptable
  elseif self.Type == DisplayTaskTypeEnum.NO_TRACKING_TASK then
    if _G.DataModelMgr.PlayerDataModel:IsVisitState() and not _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
      return LuaText.task_tracking_visit_text
    end
    return LuaText.task_tracking_null
  end
end

function DisplayTaskObject:GetCountdownText()
  if self.Type == DisplayTaskTypeEnum.SUB_TASK then
    return LuaText.displaytaskobject_1
  elseif self.Type == DisplayTaskTypeEnum.NEW_TASK then
    if self.Task and self.Task:IsNewTask() then
      return LuaText.displaytaskobject_1
    else
      return ""
    end
  elseif self.Type == DisplayTaskTypeEnum.ON_GOING_TASK then
    return LuaText.task_tracking_info
  elseif self.Type == DisplayTaskTypeEnum.ACCEPTABLE_TASK then
    return LuaText.task_tracking_info
  else
    return ""
  end
end

function DisplayTaskObject:GetCountdown()
  if self.Type == DisplayTaskTypeEnum.SUB_TASK then
    return 10
  elseif self.Type == DisplayTaskTypeEnum.NEW_TASK then
    if self.Task and self.Task:IsNewTask() then
      return 10
    else
      return 0
    end
  elseif self.Type == DisplayTaskTypeEnum.ON_GOING_TASK then
    return 0
  elseif self.Type == DisplayTaskTypeEnum.ACCEPTABLE_TASK then
    return 0
  else
    return 0
  end
end

function DisplayTaskObject:ExecuteGoAction()
  if self.Type == DisplayTaskTypeEnum.SUB_TASK then
    if self:GetTaskClickLimit() then
      return
    end
    _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenTaskPanel)
  elseif self.Type == DisplayTaskTypeEnum.NEW_TASK then
    if self.Task then
      if self:GetTaskClickLimit() then
        return
      end
      self.Task:ConsumeNewTask()
    end
    _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.SelectTrackTask, self.ID)
  elseif self.Type == DisplayTaskTypeEnum.ON_GOING_TASK then
    if self:GetTaskClickLimit() then
      return
    end
    _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenTaskPanel)
  elseif self.Type == DisplayTaskTypeEnum.ACCEPTABLE_TASK then
    if self:GetTaskClickLimit() then
      return
    end
    _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap)
  elseif self.Type == DisplayTaskTypeEnum.NO_TRACKING_TASK and _G.DataModelMgr.PlayerDataModel:IsVisitState() and not _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
    local Context = DialogContext()
    Context:SetTitle(LuaText.umg_plane_teamitem_1):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_plane_teamitem_2, LuaText.umg_plane_teamitem_3):SetMode(DialogContext.Mode.OK_CANCEL)
    Context:SetContent(LuaText.task_tracking_visitorquit):SetCallbackOkOnly(self, self.VisitorQuit)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function DisplayTaskObject:OwnerQuit()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdZoneDisbandVisitReq)
end

function DisplayTaskObject:VisitorQuit()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.CmdZoneExitVisitReq)
end

function DisplayTaskObject:MarkTrackersSynced()
end

function DisplayTaskObject:IsNewTask()
  if not self.Task then
    return false
  end
  return self.Task:IsNewTask()
end

function DisplayTaskObject:ConsumeNewTask()
  if not self.Task then
    return
  end
  self.Task:ConsumeNewTask()
end

function DisplayTaskObject:GetTaskClickLimit()
  local isSelectBtn = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "MainUIModule", "LobbyMain")
  if isSelectBtn then
    return true
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "LobbyMain").TASKITEM
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "MainUIModule", "LobbyMain", touchReasonType)
  return false
end

function DisplayTaskObject:HasAnyTargetInDifferentSceneGroup()
  return false
end

return DisplayTaskObject
