local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local Base = require("NewRoco.TUI.BP_ScrollViewItemBase_C")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")
local UMG_NPCShopItem_2_C = Base:Extend("UMG_NPCShopItem_2_C")

function UMG_NPCShopItem_2_C:OnConstruct()
  self.uiData = {}
end

function UMG_NPCShopItem_2_C:OnDestruct()
  self.uiData = nil
end

function UMG_NPCShopItem_2_C:UpdateInfo()
  local itemID = self.uiData.shopItemId
  local shopId = self.uiData.npcShopId
  local goodsConf, bagItemConf, vItemConf, color, iconPath
  if 101 == shopId then
    goodsConf = _G.DataConfigManager:GetNormalShopConf(itemID)
    bagItemConf = _G.DataConfigManager:GetFashionItemConf(goodsConf.item_id)
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.uiData.IsTailorShopGoods then
    goodsConf = _G.DataConfigManager:GetNormalShopConf(itemID)
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(goodsConf.item_id)
    if suitConf then
      color = AppearanceUtils:GetSuitGradeColor(suitConf.suit_grade)
      iconPath = suitConf.suits_icon
    end
  else
    self.NRCSwitcher_84:SetActiveWidgetIndex(1)
    goodsConf = NPCShopUtils:GetAdjustGoodConf(itemID, shopId)
    if goodsConf.Type == Enum.GoodsType.GT_BAGITEM then
      bagItemConf = _G.DataConfigManager:GetBagItemConf(goodsConf.item_id)
    elseif goodsConf.Type == Enum.GoodsType.GT_VITEM then
      vItemConf = _G.DataConfigManager:GetVisualItemConf(goodsConf.item_id)
    end
  end
  if nil == iconPath then
    if bagItemConf then
      if bagItemConf.big_icon then
        iconPath = bagItemConf.big_icon
      else
        iconPath = bagItemConf.icon
      end
    elseif vItemConf then
      if vItemConf.bigIcon then
        iconPath = vItemConf.bigIcon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_CARD_SKIN then
      local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(goodsConf.item_id)
      if cardSkinConf then
        color = self:GetQualityColor(cardSkinConf.card_quality)
        iconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_CARD_ICON then
      local cardIconConf = _G.DataConfigManager:GetCardIconConf(goodsConf.item_id)
      if cardIconConf then
        color = self:GetQualityColor(cardIconConf.card_quality)
        iconPath = string.format("%s%s.%s", UEPath.CARD_HEAD_PATH, cardIconConf.icon_resource_path, cardIconConf.icon_resource_path)
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_CARD_LABEL then
      local cardLabelConf = _G.DataConfigManager:GetCardLabelConf(goodsConf.item_id)
      if cardLabelConf then
        color = self:GetQualityColor(cardLabelConf.card_quality)
        iconPath = cardLabelConf.label_icon or UEPath.CARD_LABEL_PATH
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_FASHION_SUITS then
      local fashionConf = _G.DataConfigManager:GetFashionSuitsConf(goodsConf.item_id)
      if fashionConf then
        color = AppearanceUtils:GetSuitGradeColor(fashionConf.suit_grade)
        iconPath = fashionConf.suits_icon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_FASHION then
      local fashionConf = _G.DataConfigManager:GetFashionItemConf(goodsConf.item_id)
      if fashionConf then
        color = self:GetQualityColor(fashionConf.item_quality)
        iconPath = fashionConf.icon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_SALON then
      local salonConf = _G.DataConfigManager:GetSalonItemConf(goodsConf.item_id)
      if salonConf then
        color = self:GetQualityColor(salonConf.item_quality)
        iconPath = salonConf.icon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_SHARE_FORM then
      local shareConf = _G.DataConfigManager:GetPetShareItemConf(goodsConf.item_id)
      if shareConf then
        color = self:GetQualityColor(shareConf.item_quality)
        iconPath = shareConf.item_icon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_RP_BEHAVIOR then
      local itemConf = _G.DataConfigManager:GetRoleplayBehaviorConf(goodsConf.item_id)
      if itemConf then
        color = self:GetQualityColor(5)
        iconPath = itemConf.icon_path
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_EMOJI then
      local chatEmojiConf = _G.DataConfigManager:GetChatEmojiConf(goodsConf.item_id)
      if chatEmojiConf then
        color = self:GetQualityColor(chatEmojiConf.card_quality)
        iconPath = chatEmojiConf.emoji_goods_icon
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_FASHION_PACKAGE then
      local fashionPackageConf = _G.DataConfigManager:GetFashionPackageConf(goodsConf.item_id)
      if fashionPackageConf then
        color = self:GetQualityColor(5)
      end
    elseif goodsConf.Type == Enum.GoodsType.GT_FASHION_BOND then
      local fashionBondConf = _G.DataConfigManager:GetFashionBondConf(goodsConf.item_id)
      if fashionBondConf then
        color = self:GetQualityColor(5)
        iconPath = fashionBondConf.fashion_bond_icon
      end
    end
  end
  self:SetIcon(iconPath, bagItemConf)
  local icon = NPCShopUtils:GetGoodsCurrencyIconPath(shopId, itemID)
  if icon then
    self.CostIcon:SetPath(icon)
    self.NRCImage_1:SetPath(icon)
  end
  local shopConf = DataConfigManager:GetShopConf(shopId)
  if self.Quantity then
    if shopConf and shopConf.shop_type == _G.Enum.ShopType.ST_FASHION_TAILOR then
      self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if 101 ~= self.uiData.npcShopId and 102 ~= self.uiData.npcShopId then
    self.ItemCount:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.OriginalPrice2:SetText(self.uiData.priceNum)
  else
    self.ItemNum:SetText(self.uiData.selectedNum * self.uiData.priceNum)
  end
  if bagItemConf then
    local num = goodsConf.item_num * self.uiData.selectedNum
    self:SetItemNameTextSize(num)
    self.ItemCount:SetText("x" .. num)
  elseif vItemConf then
    local num = goodsConf.item_num * self.uiData.selectedNum
    self:SetItemNameTextSize(num)
    self.ItemCount:SetText("x" .. num)
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if nil == color then
    if bagItemConf then
      color = self:GetQualityColor(bagItemConf and bagItemConf.item_quality or 0)
    elseif vItemConf then
      color = self:GetQualityColor(vItemConf and vItemConf.item_quality or 0)
    end
  end
  self.itemIconBG:SetPath(UEPath.PROP_QUALITY_NONE)
  if color then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  end
end

function UMG_NPCShopItem_2_C:SetItemNameTextSize(inputText)
  local text = inputText
  local textStr = tostring(text)
  local length = string.len(textStr)
  local Font = self.ItemCount.Font
  if length <= 4 then
    Font.Size = 28
    self.ItemCount:SetFont(Font)
  elseif length > 4 and length <= 5 then
    Font.Size = 26
    self.ItemCount:SetFont(Font)
  elseif length > 5 and length <= 6 then
    Font.Size = 24
    self.ItemCount:SetFont(Font)
  end
end

function UMG_NPCShopItem_2_C:SetData(_data)
  Base.SetData(self, _data)
  self.uiData = _data
  self:UpdateInfo()
end

function UMG_NPCShopItem_2_C:OnActive()
end

function UMG_NPCShopItem_2_C:OnDeactive()
end

function UMG_NPCShopItem_2_C:GetQualityColor(quality)
  local color
  if 0 == quality then
  elseif 1 == quality then
    color = UEPath.Color_QUALITY_1
  elseif 2 == quality then
    color = UEPath.Color_QUALITY_2
  elseif 3 == quality then
    color = UEPath.Color_QUALITY_3
  elseif 4 == quality then
    color = UEPath.Color_QUALITY_4
  elseif 5 == quality then
    color = UEPath.Color_QUALITY_5
  end
  return color
end

function UMG_NPCShopItem_2_C:OnSelectionChange(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_NPCShopItem_2_C:OnSelectionChange")
  end
end

function UMG_NPCShopItem_2_C:SetIcon(icon_path, bag_item_conf)
  if icon_path and bag_item_conf and bag_item_conf.type == _G.Enum.BagItemType.BI_PET_EGG and bag_item_conf.item_behavior and bag_item_conf.item_behavior[1] and bag_item_conf.item_behavior[1].ratio2 and bag_item_conf.item_behavior[1].ratio2[1] then
    local eggInfo = {}
    eggInfo.random_egg_conf = bag_item_conf.item_behavior[1].ratio2[1]
    self.IconSwitcher:SetActiveWidgetIndex(1)
    self.PetEggIcon:SetEggIcon(eggInfo, icon_path)
    return
  end
  if icon_path then
    self.IconSwitcher:SetActiveWidgetIndex(0)
    self.ItemIcon:SetPath(icon_path)
  end
end

return UMG_NPCShopItem_2_C
