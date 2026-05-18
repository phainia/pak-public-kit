local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RewardsItem_C = Base:Extend("UMG_RewardsItem_C")

function UMG_RewardsItem_C:OnConstruct()
  self.uiData = {}
end

function UMG_RewardsItem_C:OnDestruct()
end

function UMG_RewardsItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_RewardsItem_C:updateItemInfo()
  local itemId = self.uiData.id
  local itemType = self.uiData.type
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if vItemsConf then
      self:SetQuality(vItemsConf.item_quality)
      self.itemIcon:SetPath(vItemsConf.bigIcon)
      self.NumText:SetText("x" .. self.uiData.num)
    else
      self:LogError("VisualItemConf\228\184\173\228\184\141\229\173\152\229\156\168ID" .. itemId .. "\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174")
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
      self.itemIcon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    end
    self.Panel_Count:SetVisibility(self.uiData.num and self.uiData.num > 0 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
    self.NumText:SetText("x" .. self.uiData.num)
  elseif itemType == _G.Enum.GoodsType.GT_PET then
    local petData = self.uiData.pet_data
    if petData then
      itemId = petData.conf_id
    end
    local petInfo = _G.DataConfigManager:GetPetConf(itemId)
    if petInfo then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        if modelConf then
          self:SetQuality(petBaseConf.quality)
          self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
          self.NumText:SetText(self.uiData.num)
        end
      end
    end
  elseif itemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(itemId)
    self:SetQuality(cardSkinConf.card_quality)
    local propIconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
    self.itemIcon:SetPath(propIconPath)
    self.NumText:SetText("x" .. self.uiData.num)
    self.Panel_Count:SetVisibility(self.uiData.num and self.uiData.num > 0 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
  end
end

function UMG_RewardsItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.uiData.type == _G.Enum.GoodsType.GT_BAGITEM then
      if self.uiData.IsOverrideNum then
        local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, self.uiData.id)
        local num = 0
        if nil ~= bagItemData then
          num = bagItemData.num
        end
        num = num + self.uiData.num
        _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.id, self.uiData.type, false, nil, nil, nil, nil, num)
      else
        _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.id, self.uiData.type, false)
      end
    elseif self.uiData.type == _G.Enum.GoodsType.GT_PET then
      local petId = self.uiData.id
      local petData = self.uiData.pet_data
      if petData then
        petId = petData.conf_id
      end
      local pet_conf = _G.DataConfigManager:GetPetConf(petId)
      local param = {
        petbaseId = pet_conf.base_id,
        needBlur = false,
        notAcquired = false,
        isSketch = true
      }
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
      _G.NRCAudioManager:PlaySound2DAuto(1284, "UMG_ItemRewardsTemple_C:OnClick")
    elseif self.uiData.type == _G.Enum.GoodsType.GT_CARD_SKIN then
      local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(self.uiData.id)
      if cardSkinConf and cardSkinConf.bagitem_id then
        local itemId = cardSkinConf.bagitem_id
        local itemType = _G.Enum.GoodsType.GT_BAGITEM
        _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, itemId, itemType, false)
      end
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.id, self.uiData.type, false)
    end
  end
end

function UMG_RewardsItem_C:SetQuality(quality)
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

function UMG_RewardsItem_C:OnDeactive()
end

return UMG_RewardsItem_C
