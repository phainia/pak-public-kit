local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pass_UpgradeItme_C = Base:Extend("UMG_Pass_UpgradeItme_C")

function UMG_Pass_UpgradeItme_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:RefreshItem()
end

function UMG_Pass_UpgradeItme_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_CampingTemplate_C:OnItemSelected")
    if self.data.Type == _G.Enum.GoodsType.GT_BAGITEM then
      local Itemdata = _G.DataConfigManager:GetBagItemConf(self.data.Id)
      if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
        local skillMachineid = Itemdata.item_behavior[1].ratio[1]
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
      else
        _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false)
      end
    elseif self.data.Type == _G.Enum.GoodsType.GT_PET then
      local pet_id = self.data.Id
      local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
      local param = {
        petbaseId = pet_conf.base_id,
        needBlur = false,
        notAcquired = false,
        isSketch = true
      }
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false)
    end
  end
end

function UMG_Pass_UpgradeItme_C:RefreshItem()
  local data = self.data
  local Type = data.Type
  local ID = data.Id
  local Count = data.Count
  local _IconPath, _BgQuality
  if Type == Enum.GoodsType.GT_REWARD then
    local RewardConf = _G.DataConfigManager:GetRewardConf(ID)
    for i = 1, #RewardConf.RewardItem do
      if RewardConf.RewardItem[i].Type == Enum.GoodsType.GT_BAGITEM then
        local BagItemConf = _G.DataConfigManager:GetBagItemConf(RewardConf.RewardItem[i].Id)
        _IconPath = BagItemConf.big_icon
        _BgQuality = BagItemConf.item_quality
        break
      end
    end
  elseif Type == Enum.GoodsType.GT_BAGITEM then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(ID)
    _IconPath = BagItemConf.big_icon
    _BgQuality = BagItemConf.item_quality
  elseif Type == Enum.GoodsType.GT_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(ID)
    _IconPath = VIItemConf.bigIcon
    _BgQuality = VIItemConf.item_quality
  elseif Type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(ID)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      _IconPath = modelConf.icon
      _BgQuality = petBaseConf.quality
    end
  end
  self.txtLV:SetText(Count)
  self.icon:SetPath(_IconPath)
  self.QualityBg:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:SetTagQuality(_BgQuality)
end

function UMG_Pass_UpgradeItme_C:SetTagQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Pass_UpgradeItme_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_Pass_UpgradeItme_C:SetPetQuality(quality)
  if quality == _G.Enum.PetQuality.PQ_BLUE then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_3)
  elseif quality == _G.Enum.PetQuality.PQ_PURPLE then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_4)
  elseif quality == _G.Enum.PetQuality.PQ_ORANGE then
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_5)
  else
    self.QualityBg:SetPath(UEPath.PROP_QUALITY_NONE)
  end
end

function UMG_Pass_UpgradeItme_C:PlayInAnimation()
  self:PlayAnimation(self.In)
  self.StarParticleSystem:SetActivate(true)
end

function UMG_Pass_UpgradeItme_C:PlayOutAnimation()
  self:PlayAnimation(self.Out)
end

return UMG_Pass_UpgradeItme_C
