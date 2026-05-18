local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local UMG_TaskRewardItem_C = Base:Extend("UMG_TaskRewardItem_C")

function UMG_TaskRewardItem_C:OnConstruct()
end

function UMG_TaskRewardItem_C:OnDestruct()
end

function UMG_TaskRewardItem_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  self:SetInfo()
end

function UMG_TaskRewardItem_C:SetInfo()
  local data = self.Data
  if not data then
    return
  end
  if data and data.RewardItem.Id then
    local quality, ItemPath
    if data.RewardItem.Type == Enum.GoodsType.GT_VITEM then
      local VisualItemConf = _G.DataConfigManager:GetVisualItemConf(data.RewardItem.Id)
      quality = VisualItemConf.item_quality
      ItemPath = VisualItemConf.bigIcon
    elseif data.RewardItem.Type == Enum.GoodsType.GT_BAGITEM then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(data.RewardItem.Id)
      ItemPath = BagItemConf.icon
      quality = BagItemConf.item_quality
    elseif data.RewardItem.Type == Enum.GoodsType.GT_PET then
      local PetConf = _G.DataConfigManager:GetPetConf(data.RewardItem.Id)
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
        ItemPath = modelConf.icon
      end
    elseif data.RewardItem.Type == Enum.GoodsType.GT_FASHION then
      local itemConf = _G.DataConfigManager:GetFashionItemConf(data.RewardItem.Id)
      if itemConf then
        ItemPath = itemConf.icon
        quality = itemConf.item_quality
      end
    end
    self.Icon:SetPath(ItemPath)
    self:SetQuality(quality)
  end
  if data.TokenType == _G.Enum.TokenRewardType.TOKEN_MULTI_REWARD then
    self.UP:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UP:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.ItemCount:SetText(data.RewardItem.Count)
  local CurSelectTabIndex = _G.NRCModuleManager:DoCmd(TaskModuleCmd.GetSelectTaskTabIndex)
  if CurSelectTabIndex ~= TaskEnum.TaskTab.Legendary then
    self:PlayAnimation(self.Qitan_in)
  elseif CurSelectTabIndex ~= TaskEnum.TaskTab.Gleanings then
    self:PlayAnimation(self.Shiyi_in)
  end
end

function UMG_TaskRewardItem_C:SetQuality(quality)
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

function UMG_TaskRewardItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.Data.RewardItem.Id, self.Data.RewardItem.Type, false)
  end
end

function UMG_TaskRewardItem_C:OnDeactive()
end

return UMG_TaskRewardItem_C
