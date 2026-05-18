local UMG_Npc_GoodAndBad_C = _G.NRCPanelBase:Extend("UMG_Npc_GoodAndBad_C")

function UMG_Npc_GoodAndBad_C:OnActive(goodDatas, badDatas)
  self.List_1:InitGridView(goodDatas)
  self.List:InitGridView(badDatas)
  if nil == badDatas or 0 == #badDatas then
    self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_61:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Npc_GoodAndBad_C:OnDeactive()
end

function UMG_Npc_GoodAndBad_C:OnAddEventListener()
end

return UMG_Npc_GoodAndBad_C
