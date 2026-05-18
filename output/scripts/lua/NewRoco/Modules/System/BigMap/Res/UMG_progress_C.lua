local UMG_progress_C = _G.NRCViewBase:Extend("UMG_progress_C")

function UMG_progress_C:OnActive()
end

function UMG_progress_C:OnDeactive()
end

function UMG_progress_C:showAni(_pos, StartTime, EndTime)
  if StartTime and EndTime then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local FillAmount = StartTime / EndTime
    self.CircleFillImage_77:SetFillAmount(FillAmount)
  end
end

function UMG_progress_C:showEndAni()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_progress_C:OnAddEventListener()
end

return UMG_progress_C
