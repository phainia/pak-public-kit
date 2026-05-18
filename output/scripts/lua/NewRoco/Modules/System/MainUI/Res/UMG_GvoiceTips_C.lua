local UMG_GvoiceTips_C = _G.NRCPanelBase:Extend("UMG_GvoiceTips_C")

function UMG_GvoiceTips_C:OnActive(tips)
  self.Text_Tips:SetText(tips)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_GvoiceTips_C:OnEnable()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  Log.Debug("UMG_GvoiceTips_C:OnEnable")
end

function UMG_GvoiceTips_C:OnDeactive()
end

function UMG_GvoiceTips_C:ShowTips(bShow, tips)
  Log.Debug("UMG_GvoiceTips_C:ShowTips", bShow)
  if bShow then
    self.Text_Tips:SetText(tips)
    self:SetVisibility(UE4.ESlateVisibility.selfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_GvoiceTips_C:OnAddEventListener()
end

return UMG_GvoiceTips_C
