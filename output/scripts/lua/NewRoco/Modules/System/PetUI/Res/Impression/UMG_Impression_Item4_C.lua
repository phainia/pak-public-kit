local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Impression_Item4_C = Base:Extend("UMG_Impression_Item4_C")

function UMG_Impression_Item4_C:OnConstruct()
end

function UMG_Impression_Item4_C:OnDestruct()
end

function UMG_Impression_Item4_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  self.ItemConf = _data.conf
  self.data = _data
  self.index = index
  self:ShowItem()
end

function UMG_Impression_Item4_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:SetQuality(self.ItemConf.item_quality)
    self:PlayAnimation(self.In)
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.ItemConf.id, _G.Enum.GoodsType.GT_BAGITEM)
  else
    self:PlayAnimation(self.Out)
    self:SetQuality(1)
  end
end

function UMG_Impression_Item4_C:ShowItem()
  self.icon:SetPath(self.ItemConf.icon)
  local num = self.data.num
  local max = self.data.maxNum
  local text = string.format("<span color=\"#908F85FF\" size=\"24\" font=\"/Game/NewRoco/Font/244-ShangShouDunDun_Font\">%d/</><span color=\"#908F85FF\" size=\"30\" font=\"/Game/NewRoco/Font/244-ShangShouDunDun_Font\">%d</>", num, max)
  if num < max then
    text = string.format("<span color=\"#AF3D3EFF\" size=\"24\" font=\"/Game/NewRoco/Font/244-ShangShouDunDun_Font\"> %d/</><span color=\"#908F85FF\" size=\"30\" font=\"/Game/NewRoco/Font/244-ShangShouDunDun_Font\">%d</>", num, max)
  end
  self.txtLV:SetText(text)
  self:SetQuality(self.ItemConf.item_quality)
  self:SetBGQuality(self.ItemConf.item_quality)
end

function UMG_Impression_Item4_C:SetQuality(quality)
  self.Background:SetVisibility(UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.Background:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_Impression_Item4_C:SetBGQuality(quality)
  self.Background_1:SetVisibility(UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.Background_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Background_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_Impression_Item4_C
