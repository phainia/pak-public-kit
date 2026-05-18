require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AwardTemplate_C = Base:Extend("UMG_AwardTemplate_C")

function UMG_AwardTemplate_C:OnConstruct()
  self.uiData = {}
end

function UMG_AwardTemplate_C:Destruct()
end

function UMG_AwardTemplate_C:OnClick()
  if not self.uiData then
    Log.Error("UIData is nil???")
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_LevelUpRewards_C:OnAwardListItemSelected")
  if self.uiData.level_reward_type == _G.Enum.GoodsType.GT_BAGITEM then
    local Itemdata = _G.DataConfigManager:GetBagItemConf(self.uiData.level_reward_id)
    if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
      local skillMachineid = Itemdata.item_behavior[1].ratio[1]
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.level_reward_id, self.uiData.level_reward_type, false)
    end
  elseif self.uiData.level_reward_type == _G.Enum.GoodsType.GT_PET then
    local pet_id = self.uiData.level_reward_id
    local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
    local param = {
      petbaseId = pet_conf.base_id,
      needBlur = true,
      notAcquired = false,
      isSketch = true
    }
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
  elseif self.uiData.level_reward_type == _G.Enum.GoodsType.GT_CARD_SKIN then
    Log.Debug("\232\191\152\230\178\161\230\156\137\229\138\160\233\128\154\231\148\168\229\144\141\231\137\135\232\131\140\230\153\175\229\188\185\229\135\186\233\128\187\232\190\145,\229\144\142\230\156\159\229\138\160")
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.uiData.level_reward_id, self.uiData.level_reward_type, false)
  end
end

function UMG_AwardTemplate_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:updateItemInfo()
end

function UMG_AwardTemplate_C:updateItemInfo()
  local itemId = self.uiData.level_reward_id
  if self.uiData.level_reward_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if nil ~= vItemConf then
      self:getQuality(vItemConf.item_quality)
      self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(vItemConf.bigIcon, _G.UIIconPath.BagItemPath))
    end
  elseif self.uiData.level_reward_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if nil ~= bagItemConf then
      self:getQuality(bagItemConf.item_quality)
      self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    end
  elseif self.uiData.level_reward_type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if not petBaseConf then
      return
    end
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      self:SetPetQuality(petBaseConf.quality)
      self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
    end
  elseif self.uiData.level_reward_type == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(self.uiData.level_reward_id)
    if cardSkinConf then
      self:getQuality(cardSkinConf.card_quality)
      local propIconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
      self.ItemIcon:SetPath(propIconPath)
    end
  end
  self:SetNumSize(self.uiData.level_reward_count)
  self.ItemCount:SetText(self.uiData.level_reward_count)
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_AwardTemplate_C:SetNumSize(Count)
  local number = Count
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local Font = self.ItemCount.Font
  Font.Size = 24
  self.ItemCount:SetFont(Font)
  if length > 5 then
    Font.Size = 22
    self.ItemCount:SetFont(Font)
  end
end

function UMG_AwardTemplate_C:SetPetQuality(quality)
  if quality == _G.Enum.PetQuality.PQ_BLUE then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif quality == _G.Enum.PetQuality.PQ_PURPLE then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif quality == _G.Enum.PetQuality.PQ_ORANGE then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  else
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  end
end

function UMG_AwardTemplate_C:SetAlreadyReceived()
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_AwardTemplate_C:getQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.itemIconBG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_AwardTemplate_C:OnSelectionChange(_bSelected)
  if _bSelected then
  else
  end
end

return UMG_AwardTemplate_C
