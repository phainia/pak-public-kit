local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Task_ItemTemplate_C = Base:Extend("UMG_Task_ItemTemplate_C")

function UMG_Task_ItemTemplate_C:OnConstruct()
end

function UMG_Task_ItemTemplate_C:OnDestruct()
end

function UMG_Task_ItemTemplate_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.IsAdd = false
  self.index = index
  self.IsRemove = false
  self:SetInfo()
end

function UMG_Task_ItemTemplate_C:SetInfo()
  local data = self.data
  if not data then
    return
  end
  if data.RewardItem and data.RewardItem.Id then
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
    end
    self.ItemIcon:SetPath(ItemPath)
    self:SetQuality(quality)
  end
  self.AlreadyCollected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NumText:SetText(data.Count)
  if data.RewardType == TaskEnum.AddOrRemoveTaskReward.Add or data.RewardType == TaskEnum.AddOrRemoveTaskReward.Remove then
    self:AddOrRemove(false, true)
  end
  self.Label:SetVisibility(UE4.ESlateVisibility.Hidden)
  if data.TokenType == _G.Enum.TokenRewardType.TOKEN_ADD_REWARD then
    self.Label:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Task/Raw/Envelope/Frames/img_ewaijiangli_png.img_ewaijiangli_png'")
    self.Label:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif data.TokenType == _G.Enum.TokenRewardType.TOKEN_MULTI_REWARD then
    self.Label:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Task/Raw/Envelope/Frames/img_shuangbei_png.img_shuangbei_png'")
    self.Label:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.CanvasPanel_0:SetRenderOpacity(1)
end

function UMG_Task_ItemTemplate_C:SetQuality(quality)
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

function UMG_Task_ItemTemplate_C:SetTokenInfo(_IsPrize, IsTokenChange, IsEquipment)
  self._IsPrize = _IsPrize
  self.IsTokenChange = IsTokenChange
  self.IsEquipment = IsEquipment
  self.IsRemove = true
end

function UMG_Task_ItemTemplate_C:AddOrRemove(bAdd, bAnim)
  if bAnim then
    if bAdd then
      self.IsAdd = false
      self:PlayAnimationReverse(self.In)
    else
      self.IsAdd = true
      self:PlayAnimation(self.In)
    end
  end
end

function UMG_Task_ItemTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_CampingTemplate_C:OnItemSelected")
    if self.data and self.data.RewardItem and self.data.RewardItem.Id then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.RewardItem.Id, self.data.RewardItem.Type, false)
    end
  end
end

function UMG_Task_ItemTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.In then
  end
end

function UMG_Task_ItemTemplate_C:OnDeactive()
end

return UMG_Task_ItemTemplate_C
