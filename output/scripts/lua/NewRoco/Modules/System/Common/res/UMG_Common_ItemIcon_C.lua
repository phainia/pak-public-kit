local UMG_Common_ItemIcon_C = _G.NRCViewBase:Extend("UMG_Common_ItemIcon_C")

function UMG_Common_ItemIcon_C:OnActive()
end

function UMG_Common_ItemIcon_C:OnDeactive()
end

function UMG_Common_ItemIcon_C:OnAddEventListener()
end

function UMG_Common_ItemIcon_C:OnConstruct()
end

function UMG_Common_ItemIcon_C:OnDestruct()
  self.uiData = nil
end

function UMG_Common_ItemIcon_C:SetIcon(_data)
  self.uiData = _data
  local iconPath = ""
  local iconNum = _data.itemNum
  if _data.itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_data.itemId)
    if nil ~= vItemConf then
      self:SetQuality(vItemConf.item_quality)
      iconPath = vItemConf.bigIcon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(_data.itemId)
    if nil ~= bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
      iconPath = bagItemConf.icon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_PET then
  end
  if _data.bShowNum == true then
    self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text_Quantity:SetText(iconNum)
  self.Icon:SetPath(iconPath)
end

function UMG_Common_ItemIcon_C:SetIconPath(iconPath)
  self.Icon:SetPath(iconPath)
end

function UMG_Common_ItemIcon_C:SetNum(iconNum)
  self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text_Quantity:SetText(iconNum)
end

function UMG_Common_ItemIcon_C:HideTextQuantity()
  self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Common_ItemIcon_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_Common_ItemIcon_C
