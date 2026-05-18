local UMG_MoneyTemplate_2_C = _G.NRCViewBase:Extend("UMG_MoneyTemplate_2_C")

function UMG_MoneyTemplate_2_C:OnConstruct()
  self.bSelectedAndTouch = false
  self.bInitialized = false
end

function UMG_MoneyTemplate_2_C:Destruct()
end

function UMG_MoneyTemplate_2_C:OnAddBtnReleased()
  if self.OnClickAddDelegate then
    self.OnClickAddDelegate(self)
  end
end

function UMG_MoneyTemplate_2_C:OnActive(_data, datalist, index)
  if not self.bInitialized then
    self.AddBtn.OnPressed:Add(self, self.OnAddBtnPress)
    self.AddBtn.OnReleased:Add(self, self.OnAddBtnReleased)
    self.bInitialized = true
  end
  if not _data then
    self.AddBtn:SetVisibility(UE.ESlateVisibility.Collapsed)
  elseif _data.currencyType == Enum.VisualItem.VI_DIAMOND then
    self.OnClickAddDelegate = self.OpenExchangeDiamond
    self.AddBtn:SetVisibility(UE.ESlateVisibility.Visible)
  elseif _data.currencyType == Enum.VisualItem.VI_COUPON then
    self.OnClickAddDelegate = self.OpenTOPUPShop
    self.AddBtn:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.AddBtn:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_MoneyTemplate_2_C:RefreshMoneyNum()
  if not self.uiData then
    return
  end
  local Num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(self.uiData.currencyId)
  if Num ~= self.uiData.num then
    self.uiData.num = Num
    self:updateItemInfo()
  end
end

function UMG_MoneyTemplate_2_C:OpenTOPUPShop()
  self:PlayAnimation(self.Up)
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenTopUpShop)
end

function UMG_MoneyTemplate_2_C:OpenExchangeDiamond()
  self:PlayAnimation(self.Up)
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenExchangeDiamond)
end

function UMG_MoneyTemplate_2_C:OnAddBtnPress()
  self:PlayAnimation(self.Add_Press)
end

function UMG_MoneyTemplate_2_C:OpenVisualItemTips()
  if self.uiData.currencyId == Enum.VisualItem.VI_COUPON then
    if _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenTopUpShop) then
      return
    end
  elseif self.uiData.currencyId == Enum.VisualItem.VI_DIAMOND then
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenExchangeDiamond)
    return
  end
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.currencyId, _G.Enum.GoodsType.GT_VITEM, false)
end

function UMG_MoneyTemplate_2_C:updateItemInfo()
  local itemType = self.uiData.currencyType
  local itemId = self.uiData.currencyId
  local itemNum = self.uiData.num
  local itemColor = self.uiData.showColor
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
  self.UMG_UIIcon:SetPath(vItemsConf.iconPath)
  self.UMG_UIIcon_big:SetPath(vItemsConf.bigIcon)
  if self.uiData.showbg then
    self.NRCImage_bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCImage_bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.uiData.bigIcon then
    self.SizeBox_uicionbig:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SizeBox_uicion:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.SizeBox_uicionbig:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_uicion:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if 0 == itemColor then
    self.SumNum:SetText(itemNum)
    self.SumNum:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CostNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CostNum:SetText(itemNum)
    self.SumNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CostNum:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MoneyTemplate_2_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self.bSelectedAndTouch = true
  self:PlayAnimation(self.Press)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_MoneyTemplate_2_C:OnMouseLeave()
  if not self.bSelectedAndTouch then
    return
  end
  self.bSelectedAndTouch = false
  self:PlayAnimation(self.Up)
end

function UMG_MoneyTemplate_2_C:OnTouchEnded(MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_BagItemTemplate_C:OnItemSelected")
  self:PlayAnimation(self.Up)
  self:OpenVisualItemTips()
  return UE4.UWidgetBlueprintLibrary.Handled()
end

return UMG_MoneyTemplate_2_C
