local UMG_Appearance_TabCross_C = _G.NRCViewBase:Extend("UMG_Appearance_TabCross_C")

function UMG_Appearance_TabCross_C:OnConstruct()
  self.data = self.module:GetData("AppearanceModuleData")
  self:OnAddEventListener()
end

function UMG_Appearance_TabCross_C:OnActive()
end

function UMG_Appearance_TabCross_C:OnDeactive()
end

function UMG_Appearance_TabCross_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Hats, self.OnBtnHatsClicked)
  self:AddButtonListener(self.Btn_Glasses, self.OnBtnGlassesClicked)
  self:AddButtonListener(self.Btn_Earrings, self.OnBtnEarringsClicked)
  self:AddButtonListener(self.Btn_Rings, self.OnBtnRingsClicked)
  self:AddButtonListener(self.Btn_Bags, self.OnBtnBagsClicked)
  self:AddButtonListener(self.Btn_Socks, self.OnBtnSocksClicked)
  self:AddButtonListener(self.Btn_Shoes, self.OnBtnShoesClicked)
end

function UMG_Appearance_TabCross_C:OnDestruct()
end

function UMG_Appearance_TabCross_C:OnBtnHatsClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_HATS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_HATS)
  self:PlayAnimation(self.Btn_Hats_A)
end

function UMG_Appearance_TabCross_C:OnBtnGlassesClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_GLASSES
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_GLASSES)
  self:PlayAnimation(self.Btn_Glasses_A)
end

function UMG_Appearance_TabCross_C:OnBtnMasksClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_MASKES
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_MASKES)
  self:PlayAnimation(self.Btn_Masks_A)
end

function UMG_Appearance_TabCross_C:OnBtnEarringsClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_EARRINGS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_EARRINGS)
  self:PlayAnimation(self.Btn_Earrings_A)
end

function UMG_Appearance_TabCross_C:OnBtnRingsClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_RINGS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_RINGS)
  self:PlayAnimation(self.Btn_Rings_A)
end

function UMG_Appearance_TabCross_C:OnBtnBagsClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_BAGS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_BAGS)
  self:PlayAnimation(self.Btn_Bags_A)
end

function UMG_Appearance_TabCross_C:OnBtnSocksClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_SOCKS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_SOCKS)
  self:PlayAnimation(self.Btn_Socks_A)
end

function UMG_Appearance_TabCross_C:OnBtnShoesClicked()
  self:UnChooseAnimation()
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_SHOES
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_SHOES)
  self:PlayAnimation(self.Btn_Shoes_A)
end

function UMG_Appearance_TabCross_C:UnChooseAnimation(_IsPlaySound)
  if self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_HATS then
    self:PlayAnimationReverse(self.Btn_Hats_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_GLASSES then
    self:PlayAnimationReverse(self.Btn_Glasses_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_MASKES then
    self:PlayAnimationReverse(self.Btn_Masks_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_EARRINGS then
    self:PlayAnimationReverse(self.Btn_Earrings_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_RINGS then
    self:PlayAnimationReverse(self.Btn_Rings_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_BAGS then
    self:PlayAnimationReverse(self.Btn_Bags_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_SOCKS then
    self:PlayAnimationReverse(self.Btn_Socks_A)
  elseif self.data.curAppearChooseSubType == _G.Enum.FashionLabelType.FLT_SHOES then
    self:PlayAnimationReverse(self.Btn_Shoes_A)
  end
  if false ~= _IsPlaySound then
    _G.NRCAudioManager:PlaySound2DAuto(1060, "UMG_Appearance_TabVertical_C:OnBtnSuitClicked")
  end
end

function UMG_Appearance_TabCross_C:SetSwitcher()
  if self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_XIEWA then
    self.Switcher:SetActiveWidgetIndex(1)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_SHIPIN then
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

return UMG_Appearance_TabCross_C
