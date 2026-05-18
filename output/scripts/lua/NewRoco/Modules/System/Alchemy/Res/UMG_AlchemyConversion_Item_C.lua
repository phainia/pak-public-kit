local UMG_AlchemyConversion_Item_C = _G.NRCViewBase:Extend("UMG_AlchemyConversion_Item_C")
local QualityColor = {
  "#afac9fff",
  "#5ca011ff",
  "#42a7ccff",
  "#7f4dffff",
  "#efa012ff"
}

function UMG_AlchemyConversion_Item_C:OnConstruct()
end

function UMG_AlchemyConversion_Item_C:OnDestruct()
end

function UMG_AlchemyConversion_Item_C:UpdateData(data, parent, index, max)
  self.data = data
  self.parent = parent
  self.itemId, self.currentNum = self:GetMaterialShowInfo()
  self.parentSelected = nil
  if self.data.cost_goods_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.itemId)
    if nil ~= vItemConf then
      self.Icon:SetPath(vItemConf.bigIcon)
      self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(QualityColor[vItemConf.item_quality]))
    end
  elseif self.data.cost_goods_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.itemId)
    if nil ~= bagItemConf then
      self.Icon:SetPath(bagItemConf.icon)
      self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(QualityColor[bagItemConf.item_quality]))
    end
  end
  self.CurrentNumText:SetText(string.format("%d", self.currentNum))
  self.NeedNum:SetText(string.format("/%d", self.data.cost_goods_num))
  if self.currentNum >= self.data.cost_goods_num then
    self.CurrentNumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#908F85FF"))
  else
    self.CurrentNumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#cc4748ff"))
  end
  if 1 == index then
    self.LeftWhiteLine:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LeftYellowLine:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.LeftWhiteLine:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.LeftYellowLine:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  if index == max then
    self.RightWhiteLine:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RightYellowLine:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.RightWhiteLine:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.RightYellowLine:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  self:AddButtonListener(self.IconButton, self.OnClicked)
end

function UMG_AlchemyConversion_Item_C:GetMaterialShowInfo()
  local dataList = {}
  local goodsList = self.data.cost_goods_id
  local costType = self.data.cost_goods_type
  for i = 1, #goodsList do
    local num = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetMaterialNum, goodsList[i], costType)
    local itemData = {
      itemId = goodsList[i],
      itemNum = num
    }
    table.insert(dataList, itemData)
  end
  dataList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetSortGoodsList, dataList, costType)
  return dataList[1].itemId, dataList[1].itemNum
end

function UMG_AlchemyConversion_Item_C:SyncParentSelect(_bSelected)
  if self.parentSelected ~= nil and self.parentSelected == _bSelected then
    return
  end
  self.parentSelected = _bSelected
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_in)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_out)
  end
end

function UMG_AlchemyConversion_Item_C:OnClicked()
  if self.data then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.itemId, self.data.cost_goods_type, false)
  end
end

function UMG_AlchemyConversion_Item_C:OnDeactive()
end

return UMG_AlchemyConversion_Item_C
