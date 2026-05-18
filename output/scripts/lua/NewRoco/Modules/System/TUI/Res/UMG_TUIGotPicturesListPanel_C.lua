local UMG_TUIGotPicturesListPanel_C = _G.NRCPanelBase:Extend("UMG_TUIGotPicturesListPanel_C")

function UMG_TUIGotPicturesListPanel_C:OnConstruct()
  self.RunAtlas = UE4.UNRCTUIStatics.GetRuntimeLoadAtlas():ToTable()
end

function UMG_TUIGotPicturesListPanel_C:OnDestruct()
end

function UMG_TUIGotPicturesListPanel_C:OnActive(_data)
  self:SetChildViews(self.UMG_TUIGotPicturesResults_72)
  self.UMG_TUIGotPicturesResults_72:Init(self)
  self:OnAddEventListener()
end

function UMG_TUIGotPicturesListPanel_C:OnDeactive()
  self:RemoveAllButtonListener()
end

function UMG_TUIGotPicturesListPanel_C:Hide()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_TUIGotPicturesListPanel_C:Show()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_TUIGotPicturesListPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseButton, self.ClosePanel)
  self:AddButtonListener(self.HideButton, self.Hide)
  self:AddButtonListener(self.ShowButton, self.Show)
end

function UMG_TUIGotPicturesListPanel_C:ClosePanel()
  self:DoClose()
end

return UMG_TUIGotPicturesListPanel_C
