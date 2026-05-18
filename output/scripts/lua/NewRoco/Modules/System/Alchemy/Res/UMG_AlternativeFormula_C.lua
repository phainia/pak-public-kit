local UMG_AlternativeFormula_C = _G.NRCPanelBase:Extend("UMG_AlternativeFormula_C")

function UMG_AlternativeFormula_C:OnConstruct()
  self:SetChildViews(self.Popup2)
end

function UMG_AlternativeFormula_C:OnDestruct()
end

function UMG_AlternativeFormula_C:OnActive(exchangeItems, selectIndex)
  self:OnAddEventListener()
  self.FirstSelect = true
  self.selectIndex = selectIndex
  self.NRCScrollView_68:InitList(exchangeItems)
  for i = 1, self.NRCScrollView_68:GetItemCount() do
    local item = self.NRCScrollView_68:GetItemByIndex(i - 1)
    item:SetParent(self)
  end
  self.NRCScrollView_68:SelectItemByIndex(selectIndex)
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
end

function UMG_AlternativeFormula_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("exchange_formula").msg
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnConfirm
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.Popup2:SetPanelInfo(CommonPopUpData)
end

function UMG_AlternativeFormula_C:OnDeactive()
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_AlternateMaterial_C:OnConfirm")
end

function UMG_AlternativeFormula_C:OnAddEventListener()
end

function UMG_AlternativeFormula_C:OnCancel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnSelectFormula)
  self:OnClose()
end

function UMG_AlternativeFormula_C:OnConfirm()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.UpdateMaterialItems, self.exchangeId, 1)
  _G.NRCEventCenter:DispatchEvent(_G.AlchemyModuleEvent.AlchemyItemChanged, self.exchangeId, -1, self.index)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnSelectFormula, self.exchangeId)
  self:OnClose()
end

function UMG_AlternativeFormula_C:SetSelectExchangeId(exchangeId, index)
  if self.FirstSelect then
    self.FirstSelect = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_AlternateMaterial_C:OnCancel")
  end
  self.exchangeId = exchangeId
  self.index = index
end

function UMG_AlternativeFormula_C:OnClose()
  self:LoadAnimation(2)
end

function UMG_AlternativeFormula_C:OnAnimationFinished(Animation)
  if self:GetAnimByIndex(2) == Animation then
    self:DoClose()
  end
end

return UMG_AlternativeFormula_C
