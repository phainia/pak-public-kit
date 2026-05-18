local UMG_Travel_GoodAndBad_C = _G.NRCPanelBase:Extend("UMG_Travel_GoodAndBad_C")

function UMG_Travel_GoodAndBad_C:OnActive(goodDatas, badDatas)
  self.List_1:InitGridView(goodDatas)
  self.List:InitGridView(badDatas)
  if nil == badDatas or 0 == #badDatas then
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImage_76:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.List:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Travel_GoodAndBad_C:OnDeactive()
end

function UMG_Travel_GoodAndBad_C:OnAddEventListener()
end

return UMG_Travel_GoodAndBad_C
