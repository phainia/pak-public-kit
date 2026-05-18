local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_CollectRewards_Item2_C = Base:Extend("UMG_Handbook_CollectRewards_Item2_C")

function UMG_Handbook_CollectRewards_Item2_C:OnConstruct()
end

function UMG_Handbook_CollectRewards_Item2_C:OnDestruct()
end

function UMG_Handbook_CollectRewards_Item2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Button.OnClicked:Add(self, self.OnClickBtn)
  local IconPath, BgQuality
  if self.data.type == _G.Enum.PetHandbookAward.AWARD_VITEM or self.data.type == _G.Enum.GoodsType.GT_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.id)
    IconPath = NRCUtils:FormatConfIconPath(VIItemConf.bigIcon, _G.UIIconPath.BagItemPath)
    BgQuality = VIItemConf.item_quality
  elseif self.data.type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    local id = self.data.id
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(id)
    IconPath = NRCUtils:FormatConfIconPath(BagItemConf.icon, _G.UIIconPath.BagItemPath)
    BgQuality = BagItemConf.item_quality
  elseif self.data.type == _G.Enum.PetHandbookAward.AWARD_CATCH then
  elseif self.data.type == _G.Enum.PetHandbookAward.AWARD_PET_CATCH_CHANCE then
    IconPath = "PaperSprite'/Game/NewRoco/Modules/System/Handbook/Raw/Common/Images/Frames/img_icon_png.img_icon_png'"
    BgQuality = 1
  end
  self.Icon:SetPath(IconPath)
  self.Number:SetText(string.format("x%s", self.data.num))
  self:SetQuality(BgQuality)
  if self.data.bMask then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Number:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#7a7770"))
  else
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Number:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
  end
end

function UMG_Handbook_CollectRewards_Item2_C:SetQuality(quality)
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

function UMG_Handbook_CollectRewards_Item2_C:OnClickBtn()
  local data = self.data
  if data and data.id and data.type then
    local type = data.type == _G.Enum.PetHandbookAward.AWARD_VITEM and 2 or data.type
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, data.id, type)
  end
end

function UMG_Handbook_CollectRewards_Item2_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_CollectRewards_Item2_C:OnDeactive()
end

return UMG_Handbook_CollectRewards_Item2_C
