local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Email_propsbox_C = Base:Extend("UMG_Email_propsbox_C")

function UMG_Email_propsbox_C:OnConstruct()
end

function UMG_Email_propsbox_C:OnDestruct()
end

function UMG_Email_propsbox_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:ShowItem(_data)
  self:PlayAnimation(self.In)
end

function UMG_Email_propsbox_C:OnItemSelected(_bSelected)
  self:StopAnimation(self.select_in)
  self:StopAnimation(self.select_out)
  if _bSelected then
    self:PlayAnimation(self.select_in)
    self:SetQuality(self.itemQuality)
    self.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("E7DAC2FF"))
    if self.data.Type == _G.Enum.GoodsType.GT_PET then
      local pet_id = self.data.Id
      local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
      local param = {
        petbaseId = pet_conf.base_id,
        needBlur = true,
        notAcquired = false,
        isSketch = true
      }
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false, nil, nil, nil, nil, nil, self, self.CancelSelect)
    end
  else
  end
end

function UMG_Email_propsbox_C:CancelSelect()
  self.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
  self:PlayAnimation(self.select_out)
  self:SetQuality(0)
  self:SetBGQuality(self.itemQuality)
end

function UMG_Email_propsbox_C:ShowItem(reward)
  if nil == reward then
    return
  end
  local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Email/Raw/Frames/img_youjian_png.img_youjian_png'"
  self.txtLV:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
  if reward and reward.is_head_icon and nil == reward.Id then
    self.icon:SetPath(iconPath)
    self.Quality:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    local num = string.format("x%d", reward.Count)
    self.txtLV:SetText(num)
    self:SetItemIconPath(reward)
  end
  if reward.is_head_icon then
    if reward.is_read then
      self.Read:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Read:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NumBlackground:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.txtLV:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if reward.is_recv then
      self.Read:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Read:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.NumBlackground:SetVisibility(UE4.ESlateVisibility.Visible)
    self.txtLV:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self:SetBGQuality(self.itemQuality)
end

function UMG_Email_propsbox_C:SetItemIconPath(reward)
  local itemId = reward.Id
  local iconPath = ""
  self.itemQuality = 0
  self:SetQuality(0)
  if reward.Type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if nil ~= vItemConf then
      self.itemQuality = vItemConf.item_quality
      iconPath = vItemConf.bigIcon
    end
  elseif reward.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if nil ~= bagItemConf then
      self.itemQuality = bagItemConf.item_quality
      iconPath = bagItemConf.icon
    end
  elseif reward.Type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if modelConf then
        iconPath = modelConf.icon
      end
      self.itemQuality = petBaseConf.quality
    end
  end
  self.icon:SetPath(iconPath)
end

function UMG_Email_propsbox_C:SetQuality(quality)
  self.Quality:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Quality:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_daojukuangnormal1_png.img_daojukuangnormal1_png'")
  elseif 1 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_1)
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_2)
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_3)
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_4)
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetPath(UEPath.PROP_QUALITY_5)
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Email_propsbox_C:SetBGQuality(quality)
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Hidden)
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

function UMG_Email_propsbox_C:OnAnimationFinished(anim)
end

return UMG_Email_propsbox_C
