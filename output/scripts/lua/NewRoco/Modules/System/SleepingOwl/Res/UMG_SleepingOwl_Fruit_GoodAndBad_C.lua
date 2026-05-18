local UMG_SleepingOwl_Fruit_GoodAndBad_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Fruit_GoodAndBad_C")

function UMG_SleepingOwl_Fruit_GoodAndBad_C:OnActive(goodDatas)
  self.goodDatas = goodDatas
  self.List_1:InitGridView(goodDatas)
  self.NRCImage_34:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCText_21:SetVisibility(UE4.ESlateVisibility.Visible)
  self.List_1:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_SleepingOwl_Fruit_GoodAndBad_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_SleepingOwl_Fruit_GoodAndBad_C:OnDeactive()
end

function UMG_SleepingOwl_Fruit_GoodAndBad_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_47, self.OpenGoodBadTips)
end

function UMG_SleepingOwl_Fruit_GoodAndBad_C:OpenGoodBadTips()
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenGoodAndBadTips, self.goodDatas)
end

return UMG_SleepingOwl_Fruit_GoodAndBad_C
