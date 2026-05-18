local TeachingManualModuleEvent = require("NewRoco.Modules.System.TeachingManual.TeachingManualModuleEvent")
local UMG_TeachingManual_IconAni_2_C = _G.NRCViewBase:Extend("UMG_TeachingManual_IconAni_2_C")

function UMG_TeachingManual_IconAni_2_C:OnConstruct()
  self:PlayAnimation(self.normal)
end

function UMG_TeachingManual_IconAni_2_C:OnActive()
end

function UMG_TeachingManual_IconAni_2_C:OnDeactive()
  self:CancelDelay()
end

function UMG_TeachingManual_IconAni_2_C:OnAddEventListener()
end

function UMG_TeachingManual_IconAni_2_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local SelectTeachManualIndex = _G.NRCModeManager:DoCmd(TeachingManualModuleCmd.GetSelectTeachManualIndex)
  Log.Debug(SelectTeachManualIndex, "UMG_TeachingManual_IconAni_2_C:OnTouchEnded")
  if SelectTeachManualIndex ~= _G.Enum.TeachGuideType.TGT_FIGHT then
    self:SelectItem()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_TeachingManual_IconAni_2_C:SelectItem()
  self:DispatchEvent(TeachingManualModuleEvent.SelectTeachManualTab, _G.Enum.TeachGuideType.TGT_FIGHT)
  self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.IsPlayLoop = true
  self:PlayAnimation(self.change1)
end

function UMG_TeachingManual_IconAni_2_C:RemoveSelected(_CurTeachType)
  self.IsPlayLoop = false
  self:CancelDelay()
  if _CurTeachType == _G.Enum.TeachGuideType.TGT_FIGHT then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:CancelDelay()
  end
end

function UMG_TeachingManual_IconAni_2_C:OnAnimationFinished(Animation)
  if Animation == self.change2 then
    self.NRCImage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif Animation == self.change1 then
    self:DelaySeconds(3, self.PlayLoop, self)
  elseif Animation == self.select_loop then
    self:DelaySeconds(8, self.PlayLoop, self)
  end
end

function UMG_TeachingManual_IconAni_2_C:PlayLoop()
  if not self.IsPlayLoop then
    return
  end
  self:PlayAnimation(self.select_loop)
  self:CancelDelay()
end

return UMG_TeachingManual_IconAni_2_C
