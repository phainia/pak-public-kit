local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicManual_IconItem1_C = Base:Extend("UMG_MagicManual_IconItem1_C")

function UMG_MagicManual_IconItem1_C:OnConstruct()
end

function UMG_MagicManual_IconItem1_C:OnDestruct()
end

function UMG_MagicManual_IconItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_MagicManual_IconItem1_C:SetInfo()
  local data = self.data
  local quality, ItemPath
  local iconNum = data.Count
  if nil == iconNum then
    iconNum = data.num
  end
  if data.Type then
    if data.Type == Enum.GoodsType.GT_VITEM then
      local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(data.Id)
      quality = VisualItemConf.item_quality
      ItemPath = NRCUtils:FormatConfIconPath(VisualItemConf.bigIcon, _G.UIIconPath.BagItemPath)
    elseif data.Type == Enum.GoodsType.GT_BAGITEM then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(data.Id)
      ItemPath = NRCUtils:FormatConfIconPath(BagItemConf.icon, _G.UIIconPath.BagItemPath)
      quality = BagItemConf.item_quality
    elseif data.Type == Enum.GoodsType.GT_PET then
      local PetConf = _G.DataConfigManager:GetPetConf(data.Id)
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetConf.base_id)
      if petBaseConf then
        local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
        if petBaseConf.quality == _G.Enum.PetQuality.PQ_BLUE then
          quality = 3
        elseif petBaseConf.quality == _G.Enum.PetQuality.PQ_PURPLE then
          quality = 4
        elseif petBaseConf.quality == _G.Enum.PetQuality.PQ_ORANGE then
          quality = 5
        end
        ItemPath = NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath)
      end
    end
  elseif data.type == Enum.GoodsType.GT_VITEM then
    local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(data.id)
    quality = VisualItemConf.item_quality
    ItemPath = NRCUtils:FormatConfIconPath(VisualItemConf.bigIcon, _G.UIIconPath.BagItemPath)
  elseif data.type == Enum.GoodsType.GT_BAGITEM then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(data.id)
    ItemPath = NRCUtils:FormatConfIconPath(BagItemConf.icon, _G.UIIconPath.BagItemPath)
    quality = BagItemConf.item_quality
  elseif data.type == Enum.GoodsType.GT_PET then
    local PetConf = _G.DataConfigManager:GetPetConf(data.id)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetConf.base_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if petBaseConf.quality == _G.Enum.PetQuality.PQ_BLUE then
        quality = 3
      elseif petBaseConf.quality == _G.Enum.PetQuality.PQ_PURPLE then
        quality = 4
      elseif petBaseConf.quality == _G.Enum.PetQuality.PQ_ORANGE then
        quality = 5
      end
      ItemPath = NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath)
    end
  end
  if iconNum > 0 then
    self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.icon:SetPath(ItemPath)
  self:SetQuality(quality)
  if data.Count == nil then
    self.txtLV:SetText("x" .. tostring(data.num))
  else
    self.txtLV:SetText("x" .. tostring(data.Count))
  end
end

function UMG_MagicManual_IconItem1_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Background:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_MagicManual_IconItem1_C:OnItemSelected(_bSelected)
  if _bSelected and self.data.Id ~= nil then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_CampingTemplate_C:OnItemSelected")
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false)
  else
    self:OnClick()
  end
end

function UMG_MagicManual_IconItem1_C:OnClick()
  if self.data.type == _G.Enum.GoodsType.GT_BAGITEM then
    local Itemdata = _G.DataConfigManager:GetBagItemConf(self.data.id)
    if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
      local skillMachineid = Itemdata.item_behavior[1].ratio[1]
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.id, self.data.type, false)
    end
  elseif self.data.type == _G.Enum.GoodsType.GT_PET then
    local petId = self.data.id
    local petData = self.data.pet_data
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
    _G.NRCAudioManager:PlaySound2DAuto(1284, "UMG_MagicManual_IconItem1_C:OnClick")
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.id, self.data.type, false)
  end
end

function UMG_MagicManual_IconItem1_C:OnDeactive()
end

return UMG_MagicManual_IconItem1_C
