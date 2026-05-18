local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local TaskCompassUIData = Base:Extend("TaskCompassUIData")

function TaskCompassUIData:InitData(Info, ViewField)
  Base.ResetData(self)
  self.CurrentTask = nil
  self:SetPos(Info.Position)
  self.TaskAngleLimit = ViewField
  self.HasArrived = Info.HasArrived or false
  self.TaskIconPath = TaskUtils.GetTaskStateIcon(Info.TaskObject)
  self.CurState = CompassUIData.MapAreaState.TASK
  self:SetIsBig(true)
  self:SetCurrentTask(Info.TaskObject)
end

function TaskCompassUIData:SetCurrentTask(Item)
  if Item == self.CurrentTask then
    return
  end
  if self.CurrentTask then
    self.CurrentTask:RemoveEventListener(self, TaskModuleEvent.ON_UPDATE_TRACK, self.OnTaskTrackUpdate)
  end
  self.CurrentTask = Item
  if self.CurrentTask then
    self.CurrentTask:AddEventListener(self, TaskModuleEvent.ON_UPDATE_TRACK, self.OnTaskTrackUpdate)
  end
end

function TaskCompassUIData:OnTaskTrackUpdate()
  local NewIcon = TaskUtils.GetTaskStateIcon(self.CurrentTask)
  if NewIcon == self.TaskIconPath then
    return
  end
  self.TaskIconPath = NewIcon
  self:SetIcon()
end

function TaskCompassUIData:UpdateData(Info)
  self:SetCurrentTask(Info.TaskObject)
  self:SetPos(Info.Position)
  self.HasArrived = Info.HasArrived or false
  self:OnTaskTrackUpdate()
end

function TaskCompassUIData:SetIcon()
  if self.CompWidget then
    self.CompWidget:SetIcon(self.TaskIconPath)
  end
end

function TaskCompassUIData:OnDestruct()
  self:SetCurrentTask(nil)
  Base.OnDestruct(self)
end

return TaskCompassUIData
