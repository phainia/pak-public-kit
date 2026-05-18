local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_MagicStampTab1_C = _G.NRCViewBase:Extend("UMG_MagicStampTab1_C")

function UMG_MagicStampTab1_C:OnConstruct()
  self:SetIsLight(false)
end

function UMG_MagicStampTab1_C:OnActive()
end

function UMG_MagicStampTab1_C:OnDeactive()
end

function UMG_MagicStampTab1_C:OnAddEventListener()
end

function UMG_MagicStampTab1_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local SelectMagicStampIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectMagicStampIndex)
  if SelectMagicStampIndex ~= TaskEnum.MagicStampTabType.Lacquer then
    self:DispatchEvent(TaskModuleEvent.ChangeMagicStamp, TaskEnum.MagicStampTabType.Lacquer)
    self:PlayAnimation(self.In)
    self:SetIsLight(true)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_TaskTabIcon1_C:OnTouchEnded")
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_MagicStampTab1_C:SetIsLight(Light)
  if Light then
    self.BgLight:SetVisibility(UE4.ESlateVisibility.Visible)
    self.icon_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.icon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BgLight:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.icon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Bg:SetVisibility(UE4.ESlateVisibility.Visible)
    self.icon_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MagicStampTab1_C:RemoveSelected(_CurItemType)
  if _CurItemType == TaskEnum.MagicStampTabType.Lacquer then
    self:StopAllAnimations()
    self:PlayAnimation(self.Out)
    self:SetIsLight(false)
  end
end

return UMG_MagicStampTab1_C
