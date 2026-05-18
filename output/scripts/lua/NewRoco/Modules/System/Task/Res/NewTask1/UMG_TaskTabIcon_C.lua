local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_TaskTabIcon_C = _G.NRCViewBase:Extend("UMG_TaskTabIcon_C")

function UMG_TaskTabIcon_C:OnConstruct()
  self:PlayAnimation(self.normal)
end

function UMG_TaskTabIcon_C:OnActive()
end

function UMG_TaskTabIcon_C:OnDeactive()
end

function UMG_TaskTabIcon_C:OnAddEventListener()
end

function UMG_TaskTabIcon_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local CurSelectTabIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectTaskTabIndex)
  if CurSelectTabIndex ~= TaskEnum.TaskTab.All then
    self:DispatchEvent(TaskModuleEvent.ChangeTaskTab, TaskEnum.TaskTab.All)
    self:PlayAnimation(self.change1)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_TaskTabIcon_C:RemoveSelected(_CurItemType)
  if _CurItemType == TaskEnum.TaskTab.All then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

return UMG_TaskTabIcon_C
