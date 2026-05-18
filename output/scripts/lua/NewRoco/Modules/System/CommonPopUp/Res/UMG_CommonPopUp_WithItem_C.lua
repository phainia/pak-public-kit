local UMG_CommonPopUp_WithItem_C = _G.NRCPanelBase:Extend("UMG_CommonPopUp_WithItem_C")

function UMG_CommonPopUp_WithItem_C:OnConstruct()
  self.CommonPopUpData = nil
  self:OnAddEventListener()
end

function UMG_CommonPopUp_WithItem_C:OnDestruct()
end

function UMG_CommonPopUp_WithItem_C:OnActive(_param)
  self.CommonPopUpData = _param
  self.PopUp4:SetPanelInfo(_param)
  self:SetItems(_param.ItemList)
  local itemData = _param.ItemList[1]
  local itemConf = _G.DataConfigManager:GetBagItemConf(itemData.itemId)
  if itemConf then
    self.PopUp4:SetRightBtnIconInfo(itemConf.icon, itemData.ConsumeNum)
  end
  if itemData.BagNum >= itemData.ConsumeNum then
    self.PopUp4.Btn_Right.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE0FF"))
  else
    self.PopUp4.Btn_Right.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("AF3D3EFF"))
  end
  if itemData.titleText then
    self.PopUp4:SetTitleTextInfo(itemData.titleText)
  end
  if itemData.rightBtnCountdown and itemData.rightBtnCountdown > 0 then
    self.PopUp4:SetRightBtnCountdown(itemData.rightBtnCountdown)
    self.PopUp4:SetRightBtnTitleTextAndIconShow(false)
  end
end

function UMG_CommonPopUp_WithItem_C:OnDeactive()
end

function UMG_CommonPopUp_WithItem_C:SetItems(itemList)
  self.ItemList:InitGridView(itemList)
end

function UMG_CommonPopUp_WithItem_C:OnAddEventListener()
  self:AddButtonListener(self.PopUp4.Btn_Left.btnLevelUp, self.OnClickBtnLeft)
  self:AddButtonListener(self.PopUp4.btnClose.btnClose, self.OnClickBtnClose)
  self:AddButtonListener(self.PopUp4.Btn_Right.btnLevelUp, self.OnClickBtnRight)
end

function UMG_CommonPopUp_WithItem_C:OnClickBtnLeft()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_CommonPopUp_WithItem_C:OnClickBtnLeft")
  self:DoClose()
end

function UMG_CommonPopUp_WithItem_C:OnClickBtnClose()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_CommonPopUp_WithItem_C:OnClickBtnClose")
  self:DoClose()
end

function UMG_CommonPopUp_WithItem_C:OnClickBtnRight()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_CommonPopUp_WithItem_C:OnClickBtnClose")
  if self.CommonPopUpData and self.CommonPopUpData.Call and self.CommonPopUpData.Btn_RightHandler then
    self.CommonPopUpData.Btn_RightHandler(self.CommonPopUpData.Call)
  end
  self:DoClose()
end

return UMG_CommonPopUp_WithItem_C
