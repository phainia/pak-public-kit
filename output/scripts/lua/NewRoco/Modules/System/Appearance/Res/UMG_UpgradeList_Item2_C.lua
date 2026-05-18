local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_UpgradeList_Item2_C = Base:Extend("UMG_UpgradeList_Item2_C")
local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")

function UMG_UpgradeList_Item2_C:OnConstruct()
  self.NRCText_1:SetText(LuaText.fashion_extra_credit)
end

function UMG_UpgradeList_Item2_C:OnDestruct()
end

function UMG_UpgradeList_Item2_C:UpdateUI()
  if not self.uiData then
    return
  end
  if self.uiData.bFakeExtraPikaPoint then
    self:UpdateUIWithFakePikaPoint()
  else
    self:UpdateUIWithShopData()
  end
end

function UMG_UpgradeList_Item2_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:UpdateUI()
end

function UMG_UpgradeList_Item2_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.uiData then
      return
    end
    if self.uiData.CallbackCaller and self.uiData.CallbackFunc then
      self.uiData.CallbackFunc(self.uiData.CallbackCaller, self.uiData, self._index)
    end
  end
end

function UMG_UpgradeList_Item2_C:OnDeactive()
end

function UMG_UpgradeList_Item2_C:GetQualityColor(quality)
  if nil == quality or 0 == quality then
    return nil
  elseif 1 == quality then
    return UEPath.Color_QUALITY_1
  elseif 2 == quality then
    return UEPath.Color_QUALITY_2
  elseif 3 == quality then
    return UEPath.Color_QUALITY_3
  elseif 4 == quality then
    return UEPath.Color_QUALITY_4
  elseif 5 == quality then
    return UEPath.Color_QUALITY_5
  end
end

function UMG_UpgradeList_Item2_C:UpdateUIWithShopData()
  local fashionGoodsConf = DataConfigManager:GetNormalShopConf(self.uiData.GoodsShopId)
  if nil == fashionGoodsConf then
    return
  end
  self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  local goodsPrice = 0
  local costGoodsType = 0
  local costGoodsId = 0
  if nil ~= self.uiData.packageGoodsId and 0 ~= self.uiData.packageGoodsId then
    local goodsSevData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, self.uiData.ShopId, self.uiData.GoodsShopId)
    goodsSevData = goodsSevData or _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetSubGoodsSeverData, self.uiData.ShopId, self.uiData.packageGoodsId, self.uiData.GoodsShopId)
    if goodsSevData then
      goodsPrice = goodsSevData.real_price.num
      costGoodsType = goodsSevData.real_price.goods_type
      costGoodsId = goodsSevData.real_price.goods_id
    end
  else
    local goodsSevData = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetGoodsSeverData, self.uiData.ShopId, self.uiData.GoodsShopId)
    if goodsSevData then
      goodsPrice = goodsSevData.real_price.num
      costGoodsType = goodsSevData.real_price.goods_type
      costGoodsId = goodsSevData.real_price.goods_id
    end
  end
  local shopConf = DataConfigManager:GetShopConf(self.uiData.ShopId)
  if nil == shopConf then
    return
  end
  local costGoodsIcon = NPCShopUtils:GetGoodsCurrencyIconByType(costGoodsType, costGoodsId)
  local itemIconPath, qualityColor
  local bHasOwned = false
  local shopOriginalPrice = goodsPrice
  local goodsType = fashionGoodsConf.Type
  if goodsType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(fashionGoodsConf.item_id)
    if suitConf and suitConf.suit_grade and suitConf.suits_icon then
      qualityColor = AppearanceUtils:GetSuitGradeColor(suitConf.suit_grade)
      itemIconPath = suitConf.suits_icon
      bHasOwned = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.HadOwnedEntireSuit, fashionGoodsConf.item_id)
    end
  elseif goodsType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(fashionGoodsConf.item_id)
    if cardSkinConf and cardSkinConf.card_quality and cardSkinConf.skin_resource_path then
      qualityColor = self:GetQualityColor(cardSkinConf.card_quality)
      itemIconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      bHasOwned = _G.NRCModuleManager:DoCmd(FriendModuleCmd.HasCardSkin, cardSkinConf.id)
    end
  elseif goodsType == _G.Enum.GoodsType.GT_FASHION then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionGoodsConf.item_id)
    if fashionItemConf and fashionItemConf.item_quality and fashionItemConf.icon then
      qualityColor = self:GetQualityColor(fashionItemConf.item_quality)
      itemIconPath = fashionItemConf.icon
      bHasOwned = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.CheckHasOwned, _G.Enum.GoodsType.GT_FASHION, fashionGoodsConf.item_id)
    end
  else
    Log.Error("\230\156\170\229\164\132\231\144\134\231\177\187\229\158\139", goodsType)
  end
  if nil == qualityColor then
    self.QualityColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.QualityColor:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local color = UE4.UNRCStatics.HexToLinearColor(qualityColor)
    self.QualityColor:SetColorAndOpacity(color)
  end
  self.Icon:SetPath(itemIconPath)
  if bHasOwned then
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.AlreadyOwned_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Discount:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCSwitcher_84:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCSwitcher_84:SetActiveWidgetIndex(0)
  self.NRCImage:SetPath(costGoodsIcon)
  self.OriginalPrice1:SetText(shopOriginalPrice)
  if bHasOwned or self.uiData.bIsFree then
    self.CrossOut1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CrossOut1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.uiData.bIsFree then
    self.Gift:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Gift:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_UpgradeList_Item2_C:UpdateUIWithFakePikaPoint()
  if not self.uiData or not self.uiData.vItemPrice then
    return
  end
  local vItemConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_PIKA_POINT)
  if not vItemConf then
    return
  end
  self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  local qualityColor = self:GetQualityColor(vItemConf.item_quality)
  if nil == qualityColor then
    self.QualityColor_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.QualityColor_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local color = UE4.UNRCStatics.HexToLinearColor(qualityColor)
    self.QualityColor_1:SetColorAndOpacity(color)
  end
  self.Icon_1:SetPath(vItemConf.iconPath)
  self.NumberText:SetText("x" .. self.uiData.vItemPrice)
  self.NRCSwitcher_84:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

return UMG_UpgradeList_Item2_C
