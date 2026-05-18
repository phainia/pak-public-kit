local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicManual_IconItem_C = Base:Extend("UMG_MagicManual_IconItem_C")

function UMG_MagicManual_IconItem_C:OnConstruct()
end

function UMG_MagicManual_IconItem_C:OnDestruct()
end

function UMG_MagicManual_IconItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_MagicManual_IconItem_C:SetInfo()
  local data = self.data.RewardConf
  local quality, ItemPath
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
  self.icon:SetPath(ItemPath)
  self:SetQuality(quality)
  self.txtLV:SetText(data.Count)
  self:SetState(self.data.state)
end

function UMG_MagicManual_IconItem_C:SetQuality(quality)
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

function UMG_MagicManual_IconItem_C:SetState(state)
  if state == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.Finish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Finish:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_MagicManual_IconItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_CampingTemplate_C:OnItemSelected")
    if self.data then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.RewardConf.Id, self.data.RewardConf.Type, false)
    end
  end
end

function UMG_MagicManual_IconItem_C:OnDeactive()
end

return UMG_MagicManual_IconItem_C
