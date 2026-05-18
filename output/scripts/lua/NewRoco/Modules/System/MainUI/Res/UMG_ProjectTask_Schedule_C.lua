local UMG_ProjectTask_Schedule_C = _G.NRCViewBase:Extend("UMG_ProjectTask_Schedule_C")

function UMG_ProjectTask_Schedule_C:OnConstruct()
end

function UMG_ProjectTask_Schedule_C:OnDestruct()
end

function UMG_ProjectTask_Schedule_C:SetIndex(index, maxIndex)
  if index == maxIndex then
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Below:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Below_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 0 ~= index % 2 then
    self.Up:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Up_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Below:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Below_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Below:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Below_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ProjectTask_Schedule_C:SetShowHide(isShow)
  self:SetVisibility(isShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_ProjectTask_Schedule_C:SetCompleteStatus(isCompleted, isLastOne)
  self.Switcher:SetActiveWidgetIndex(isCompleted and 1 or 0)
  self.Switcher1:SetActiveWidgetIndex(not (not isCompleted or isLastOne) and 1 or 0)
end

function UMG_ProjectTask_Schedule_C:PlayProgressAnimation()
  self:StopAllAnimations()
  self:PlayAnimation(self.Get)
end

return UMG_ProjectTask_Schedule_C
