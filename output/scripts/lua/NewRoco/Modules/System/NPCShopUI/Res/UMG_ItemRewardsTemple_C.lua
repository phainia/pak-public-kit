require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ItemRewardsTemple_C = Base:Extend("UMG_ItemRewardsTemple_C")

function UMG_ItemRewardsTemple_C:OnConstruct()
  self.uiData = {}
end

function UMG_ItemRewardsTemple_C:Destruct()
end

function UMG_ItemRewardsTemple_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_ItemRewardsTemple_C:updateItemInfo()
  local itemId = self.uiData.id
  local itemType = self.uiData.type
  if itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if vItemsConf then
      self:getQuality(vItemsConf.item_quality)
      self.itemIcon:SetPath(NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath))
      self.itemCount:SetText(self.uiData.num)
    else
      self:LogError("VisualItemConf\228\184\173\228\184\141\229\173\152\229\156\168ID" .. itemId .. "\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174")
    end
  elseif itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    self:getQuality(bagItemConf.item_quality)
    self.itemIcon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    self.Panel_Count:SetVisibility(self.uiData.num and self.uiData.num > 0 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
    self.itemCount:SetText(self.uiData.num)
  elseif itemType == _G.Enum.GoodsType.GT_PET then
    local petData = self.uiData.pet_data
    if petData then
      itemId = petData.conf_id
    end
    local petInfo = _G.DataConfigManager:GetPetConf(itemId, true)
    local baseId = 0
    if nil ~= petInfo then
      baseId = petInfo.base_id
    else
      local monsterConf = _G.DataConfigManager:GetMonsterConf(itemId)
      if nil ~= monsterConf then
        baseId = monsterConf.base_id
      end
    end
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseId)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self:SetPetQuality(petBaseConf.quality)
      self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
      self.ItemCount:SetText(self.uiData.num)
    end
  elseif itemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(itemId)
    self:getQuality(cardSkinConf.card_quality)
    local propIconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
    self.itemIcon:SetPath(propIconPath)
    self.itemCount:SetText(self.uiData.num)
    self.Panel_Count:SetVisibility(self.uiData.num and self.uiData.num > 0 and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
  end
end

function UMG_ItemRewardsTemple_C:OnClick()
  if self.uiData.type == _G.Enum.GoodsType.GT_BAGITEM then
    local Itemdata = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
    if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
      local skillMachineid = Itemdata.item_behavior[1].ratio[1]
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
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
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.id, self.uiData.type, false)
  end
end

function UMG_ItemRewardsTemple_C:getQuality(quality)
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

function UMG_ItemRewardsTemple_C:SetPetQuality(quality)
  self.itemIconBG:SetVisibility(UE4.ESlateVisibility.Visible)
  if quality == _G.Enum.PetQuality.PQ_BLUE then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_3)
  elseif quality == _G.Enum.PetQuality.PQ_PURPLE then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_4)
  elseif quality == _G.Enum.PetQuality.PQ_ORANGE then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_5)
  else
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_NONE)
  end
end

return UMG_ItemRewardsTemple_C
