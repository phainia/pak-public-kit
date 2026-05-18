local UMG_Nourish_GoodAndBad_C = _G.NRCViewBase:Extend("UMG_Nourish_GoodAndBad_C")

function UMG_Nourish_GoodAndBad_C:OnConstruct()
end

function UMG_Nourish_GoodAndBad_C:Init(AdvantageType, DisadvantageType)
  self.AdvantageType = AdvantageType
  self.DisadvantageType = DisadvantageType
  if DisadvantageType and #DisadvantageType >= 0 and AdvantageType and #AdvantageType >= 0 then
    self.Spacer:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if (not DisadvantageType or #DisadvantageType <= 0) and (not AdvantageType or #AdvantageType <= 0) then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if not DisadvantageType or #DisadvantageType <= 0 then
    self.NRCImageLieshi:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCTextlieshi:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DisadvantageList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Spacer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImageLieshi:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCTextlieshi:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DisadvantageList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if not AdvantageType or #AdvantageType <= 0 then
    self.NRCImageyoushi:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCTextyoushi:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AdvantageList:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Spacer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImageyoushi:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCTextyoushi:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AdvantageList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.AdvantageList:InitGridView(AdvantageType)
  self.DisadvantageList:InitGridView(DisadvantageType)
end

return UMG_Nourish_GoodAndBad_C
