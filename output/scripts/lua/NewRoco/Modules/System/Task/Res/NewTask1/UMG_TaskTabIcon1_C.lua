local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_TaskTabIcon1_C = _G.NRCViewBase:Extend("UMG_TaskTabIcon1_C")

function UMG_TaskTabIcon1_C:OnConstruct()
  self:PlayAnimation(self.normal)
end

function UMG_TaskTabIcon1_C:OnActive()
end

function UMG_TaskTabIcon1_C:OnDeactive()
end

function UMG_TaskTabIcon1_C:OnAddEventListener()
end

function UMG_TaskTabIcon1_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local CurSelectTabIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectTaskTabIndex)
  if CurSelectTabIndex ~= TaskEnum.TaskTab.journey then
    self:DispatchEvent(TaskModuleEvent.ChangeTaskTab, TaskEnum.TaskTab.journey)
    self:PlayAnimation(self.change1)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_TaskTabIcon1_C:OnTouchEnded")
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_TaskTabIcon1_C:RemoveSelected(_CurItemType)
  if _CurItemType == TaskEnum.TaskTab.journey then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

return UMG_TaskTabIcon1_C
