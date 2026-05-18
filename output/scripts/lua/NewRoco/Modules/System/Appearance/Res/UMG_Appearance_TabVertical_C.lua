local UMG_Appearance_TabVertical_C = _G.NRCViewBase:Extend("UMG_Appearance_TabVertical_C")

function UMG_Appearance_TabVertical_C:OnConstruct()
  self.data = self.module:GetData("AppearanceModuleData")
  self:OnAddEventListener()
end

function UMG_Appearance_TabVertical_C:OnActive()
  local tabConfTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.FASHION_TAB_CONF)
  local tabConfDatas = tabConfTable:GetAllDatas()
  local showTable = {}
  for k, v in pairs(tabConfDatas) do
    if v.rank_value and v.rank_value > 0 then
      table.insert(showTable, {
        Order = v.rank_value,
        Type = v.use_FashionLabelType,
        Icon = v.icon
      })
    end
  end
end

function UMG_Appearance_TabVertical_C:OnDeactive()
end

function UMG_Appearance_TabVertical_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Suit, self.OnBtnSuitClicked)
  self:AddButtonListener(self.Btn_Coat, self.OnBtnCoatClicked)
  self:AddButtonListener(self.Btn_Trousers, self.OnBtnTrousersClicked)
  self:AddButtonListener(self.Btn_Body, self.OnBtnBodyClicked)
  self:AddButtonListener(self.Btn_Shoes, self.OnBtnShoesClicked)
  self:AddButtonListener(self.Btn_Ornament, self.OnBtnOrnamentClicked)
end

function UMG_Appearance_TabVertical_C:OnDestruct()
end

function UMG_Appearance_TabVertical_C:OnBtnSuitClicked(_IsPlaySound)
  self:UnChooseAnimation(_IsPlaySound)
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_SUIT
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_SUIT)
  self:PlayAnimation(self.Btn_Suit_A)
end

function UMG_Appearance_TabVertical_C:OnBtnCoatClicked()
  self:UnChooseAnimation()
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_TOPS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_TOPS)
  self:PlayAnimation(self.Btn_Coat_A)
end

function UMG_Appearance_TabVertical_C:OnBtnTrousersClicked()
  self:UnChooseAnimation()
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_BOTTOMS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_BOTTOMS)
  self:PlayAnimation(self.Btn_Trousers_A)
end

function UMG_Appearance_TabVertical_C:OnBtnBodyClicked()
  self:UnChooseAnimation()
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_DRESSES
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_DRESSES)
  self:PlayAnimation(self.Btn_Body_A)
end

function UMG_Appearance_TabVertical_C:OnBtnShoesClicked()
  self:UnChooseAnimation()
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_XIEWA
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_SOCKS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_XIEWA)
  self:PlayAnimation(self.Btn_Shoes_A)
end

function UMG_Appearance_TabVertical_C:OnBtnOrnamentClicked()
  self:UnChooseAnimation()
  self.module:ClearCrossTabAnim()
  self.data.curAppearChooseType = _G.Enum.FashionLabelType.FLT_SHIPIN
  self.data.curAppearChooseSubType = _G.Enum.FashionLabelType.FLT_HATS
  self.module:OnCmdChangeAppearanceChooseType(_G.Enum.FashionLabelType.FLT_SHIPIN)
  self:PlayAnimation(self.Btn_Ornament_A)
end

function UMG_Appearance_TabVertical_C:UnChooseAnimation(_IsPlaySound)
  if self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_SUIT then
    self:PlayAnimation(self.Btn_Suit_A_Out)
    self:StopAnimation(self.Btn_Suit_A)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_TOPS then
    self:PlayAnimation(self.Btn_Coat_A_Out)
    self:StopAnimation(self.Btn_Coat_A)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_BOTTOMS then
    self:PlayAnimation(self.Btn_Trousers_A_Out)
    self:StopAnimation(self.Btn_Trousers_A)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_DRESSES then
    self:PlayAnimation(self.Btn_Body_A_Out)
    self:StopAnimation(self.Btn_Body_A)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_XIEWA then
    self:PlayAnimation(self.Btn_Shoes_A_Out)
    self:StopAnimation(self.Btn_Shoes_A)
  elseif self.data.curAppearChooseType == _G.Enum.FashionLabelType.FLT_SHIPIN then
    self:PlayAnimation(self.Btn_Ornament_A_Out)
    self:StopAnimation(self.Btn_Ornament_A)
  end
  if false ~= _IsPlaySound then
    _G.NRCAudioManager:PlaySound2DAuto(1060, "UMG_Appearance_TabVertical_C:OnBtnSuitClicked")
  end
end

return UMG_Appearance_TabVertical_C
