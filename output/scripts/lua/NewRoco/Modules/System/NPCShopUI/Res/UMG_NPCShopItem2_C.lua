local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_NPCShopItem2_C = Base:Extend("UMG_NPCShopItem2_C")

function UMG_NPCShopItem2_C:OnConstruct()
end

function UMG_NPCShopItem2_C:OnDestruct()
end

function UMG_NPCShopItem2_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetUpInfos()
end

function UMG_NPCShopItem2_C:SetUpInfos()
  local itemID = self.uiData.shopItemId
  local goodsConf = _G.DataConfigManager:GetNormalShopConf(itemID)
  if nil == goodsConf then
    return
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(goodsConf.item_id)
  if bagItemConf and nil ~= bagItemConf.big_icon then
    self.Icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.big_icon, _G.UIIconPath.BagItemPath))
  end
  self:SetQuality(bagItemConf and bagItemConf.item_quality or 0)
  local iconPath = NPCShopUtils:GetGoodsCurrencyIconPath(self.uiData.npcShopId, self.uiData.shopItemId)
  self.CostItemImage:SetPath(iconPath)
  local costNum = self.uiData.priceNum * self.uiData.selectedNum
  self.OriginalPrice2_1:SetText(costNum)
end

function UMG_NPCShopItem2_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_NPCShopItem2_C:OnItemSelected(_bSelected)
end

function UMG_NPCShopItem2_C:OnDeactive()
end

return UMG_NPCShopItem2_C
