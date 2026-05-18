local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TowerAwardTemplate_C = Base:Extend("UMG_TowerAwardTemplate_C")

function UMG_TowerAwardTemplate_C:OnConstruct()
  self.uiData = {}
end

function UMG_TowerAwardTemplate_C:OnDestruct()
end

function UMG_TowerAwardTemplate_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_TowerAwardTemplate_C:updateItemInfo()
  local itemId = self.uiData.id
  local itemType = self.uiData.type
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    self:getQuality(vItemsConf.item_quality)
    self.ItemIcon:SetPath(vItemsConf.bigIcon)
    self.ItemCount:SetText(self.uiData.num)
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    self:getQuality(bagItemConf.item_quality)
    self.ItemIcon:SetPath(bagItemConf.icon)
    self.ItemCount:SetText(self.uiData.num)
  end
end

function UMG_TowerAwardTemplate_C:getQuality(quality)
  self.itemIconBG:SetVisibility(UE4.ESlateVisibility.Visible)
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

function UMG_TowerAwardTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.uiData.id, self.uiData.type)
  end
end

function UMG_TowerAwardTemplate_C:OnActive()
end

function UMG_TowerAwardTemplate_C:OnDeactive()
end

return UMG_TowerAwardTemplate_C
