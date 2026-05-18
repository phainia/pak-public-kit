local UMG_ContractGiftItem_C = _G.NRCPanelBase:Extend("UMG_ContractGiftItem_C")

function UMG_ContractGiftItem_C:OnActive()
end

function UMG_ContractGiftItem_C:OnConstruct()
  self:AddButtonListener(self.btn_2, self.OnClick)
end

function UMG_ContractGiftItem_C:OnDeactive()
  self:RemoveButtonListener(self.btn_2, self.OnClick)
end

function UMG_ContractGiftItem_C:SetItemInfo(itemData)
  self.itemData = itemData
  local iconPath = ""
  local quality = 0
  if itemData.itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemData.itemId)
    if vItemConf then
      iconPath = vItemConf.bigIcon or vItemConf.iconPath
      quality = vItemConf.item_quality or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemData.itemId)
    if bagItemConf then
      iconPath = bagItemConf.icon
      quality = bagItemConf.item_quality or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(itemData.itemId)
    if petInfo then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        iconPath = modelConf and modelConf.icon or ""
      end
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(itemData.itemId)
    if cardSkinConf then
      iconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      quality = cardSkinConf.card_quality or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_CARD_ICON then
    local cardIconConf = _G.DataConfigManager:GetCardIconConf(itemData.itemId)
    if cardIconConf then
      iconPath = string.format("%s%s.%s'", UEPath.CARD_HEAD_PATH, cardIconConf.icon_resource_path, cardIconConf.icon_resource_path)
      quality = cardIconConf.card_quality or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_CARD_LABEL then
    local cardLabelConf = _G.DataConfigManager:GetCardLabelConf(itemData.itemId)
    if cardLabelConf then
      iconPath = cardLabelConf.label_icon or UEPath.CARD_LABEL_PATH
      quality = cardLabelConf.card_quality or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_FASHION_SUITS then
    local fashionConf = _G.DataConfigManager:GetFashionSuitsConf(itemData.itemId)
    if fashionConf then
      iconPath = fashionConf.suits_icon
      quality = fashionConf.suit_grade or 0
    end
  elseif itemData.itemType == _G.Enum.GoodsType.GT_REWARD then
    local rewardConf = _G.DataConfigManager:GetRewardConf(itemData.itemId)
    if rewardConf and #rewardConf.RewardItem > 0 then
      local rewardItem = rewardConf.RewardItem[1]
      local tempItemData = {
        itemType = rewardItem.type,
        itemId = rewardItem.id,
        bShowTip = true,
        IsCanClick = true,
        bShowNum = true
      }
      self:SetItemInfo(tempItemData)
    end
  end
  if self.Icon then
    self.Icon:SetPath(iconPath)
  end
  if self.SetQuality then
    self:SetQuality(quality)
  end
end

function UMG_ContractGiftItem_C:SetQuality(quality)
  if not self.Background then
    return
  end
  if 1 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_ContractGiftItem_C:OnClick()
  local itemData = self.itemData
  if not itemData then
    return
  end
  if itemData.itemType == _G.Enum.GoodsType.GT_PET then
    local pet_id = itemData.itemId
    local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
    if pet_conf then
      local param = {
        petbaseId = pet_conf.base_id,
        needBlur = true,
        notAcquired = false,
        isSketch = true
      }
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
    end
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemData.itemId, itemData.itemType, false)
  end
end

return UMG_ContractGiftItem_C
