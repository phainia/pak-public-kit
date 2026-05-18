local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_TaskTabIcon2_C = _G.NRCViewBase:Extend("UMG_TaskTabIcon2_C")

function UMG_TaskTabIcon2_C:OnConstruct()
  self:PlayAnimation(self.normal)
end

function UMG_TaskTabIcon2_C:OnActive()
end

function UMG_TaskTabIcon2_C:OnDeactive()
end

function UMG_TaskTabIcon2_C:OnAddEventListener()
end

function UMG_TaskTabIcon2_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local CurSelectTabIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectTaskTabIndex)
  if CurSelectTabIndex ~= TaskEnum.TaskTab.Legendary then
    self:DispatchEvent(TaskModuleEvent.ChangeTaskTab, TaskEnum.TaskTab.Legendary)
    self:PlayAnimation(self.change1)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_TaskTabIcon1_C:OnTouchEnded")
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_TaskTabIcon2_C:RemoveSelected(_CurItemType)
  if _CurItemType == TaskEnum.TaskTab.Legendary then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

return UMG_TaskTabIcon2_C
