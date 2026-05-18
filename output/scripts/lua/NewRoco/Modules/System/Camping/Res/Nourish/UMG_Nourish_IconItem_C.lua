local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_IconItem_C = Base:Extend("UMG_Nourish_IconItem_C")

function UMG_Nourish_IconItem_C:OnConstruct()
end

function UMG_Nourish_IconItem_C:OnDestruct()
end

function UMG_Nourish_IconItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local IconPath, BgQuality
  if self.data.Type == Enum.GoodsType.GT_BAGITEM then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.Id)
    IconPath = BagItemConf.icon
    BgQuality = BagItemConf.item_quality
  elseif self.data.Type == Enum.GoodsType.GT_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.Id)
    IconPath = VIItemConf.bigIcon
    BgQuality = VIItemConf.item_quality
  end
  self.icon:SetPath(NRCUtils:FormatConfIconPath(IconPath, _G.UIIconPath.BagItemPath))
  self.txtLV:SetText(self.data.Count)
  self:SetQuality(BgQuality)
end

function UMG_Nourish_IconItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false)
  end
end

function UMG_Nourish_IconItem_C:SetQuality(quality)
  if 0 == quality then
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

function UMG_Nourish_IconItem_C:OnDeactive()
end

return UMG_Nourish_IconItem_C
