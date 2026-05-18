local UMG_PetEvolutionRewardTemple_C = _G.NRCViewBase:Extend("UMG_PetEvolutionRewardTemple_C")

function UMG_PetEvolutionRewardTemple_C:Construct()
end

function UMG_PetEvolutionRewardTemple_C:Destruct()
  self.uiData = nil
end

function UMG_PetEvolutionRewardTemple_C:SetData(_data)
  self.uiData = _data
  self:UpdateItemInfo()
end

function UMG_PetEvolutionRewardTemple_C:UpdateItemInfo()
  local itemData = self.uiData
  local updateInfo = false
  if itemData.itemType == _G.Enum.GoodsType.GT_VITEM then
    local itemCfg = _G.DataConfigManager:GetVisualItemConf(itemData.itemId or 0)
    if itemCfg then
      self.itemIcon:SetPath(itemCfg.bigIcon)
      self:SetQuality(itemCfg.item_quality)
      self.panelItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.itemCount:SetText(itemData.itemCnt or 0)
      updateInfo = true
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local itemCfg = _G.DataConfigManager:GetBagItemConf(itemData.itemId or 0)
    if itemCfg then
      self.itemIcon:SetPath(itemCfg.icon)
      self:SetQuality(itemCfg.item_quality)
      self.panelItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.itemCount:SetText(itemData.itemCnt or 0)
      updateInfo = true
    end
  end
  if not updateInfo then
    self:SetQuality(1)
    self.panelItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.itemCount:SetText("")
  end
end

function UMG_PetEvolutionRewardTemple_C:SetQuality(quality)
  self.itemIconBG:SetVisibility(0 == quality and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.itemIconBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_5)
  end
end

return UMG_PetEvolutionRewardTemple_C
