local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_Subject_Item3_C = Base:Extend("UMG_Handbook_Subject_Item3_C")

function UMG_Handbook_Subject_Item3_C:OnConstruct()
end

function UMG_Handbook_Subject_Item3_C:OnBtnClick()
  local type = _G.Enum.GoodsType.GT_BAGITEM
  local id = self.data.award_id
  if self.data.award_type == _G.Enum.PetHandbookAward.AWARD_VITEM then
    type = _G.Enum.GoodsType.GT_VITEM
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    type = _G.Enum.GoodsType.GT_BAGITEM
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_PET_CATCH_CHANCE then
    type = _G.Enum.GoodsType.GT_BAGITEM
  end
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, id, type, false)
end

function UMG_Handbook_Subject_Item3_C:OnDestruct()
end

function UMG_Handbook_Subject_Item3_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  local IconPath, BgQuality
  self.NRCText_15:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Button_35.OnClicked:Add(self, self.OnBtnClick)
  if self.data.award_type == _G.Enum.PetHandbookAward.AWARD_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.award_id)
    IconPath = VIItemConf.bigIcon
    BgQuality = VIItemConf.item_quality
    self.NRCText_15:SetText(self.data.award_count)
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    local id = self.data.award_id
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(id)
    IconPath = BagItemConf.icon
    BgQuality = BagItemConf.item_quality
    self.NRCText_15:SetText(self.data.award_count)
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_PET_CATCH_CHANCE then
    local id = self.data.award_id
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(id)
    IconPath = BagItemConf.icon
    BgQuality = BagItemConf.item_quality
    self.NRCText_15:SetText(self.data.award_count)
    local value = tonumber(self.data.award_count) / 100
    self.NRCText_15:SetText(string.format("%d%%", value))
  end
  self.icon:SetPath(NRCUtils:FormatConfIconPath(IconPath, _G.UIIconPath.BagItemPath))
  self:SetQuality(BgQuality)
end

function UMG_Handbook_Subject_Item3_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_Subject_Item3_C:SetQuality(quality)
  self.Background:SetVisibility(quality > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
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

function UMG_Handbook_Subject_Item3_C:OnDeactive()
end

return UMG_Handbook_Subject_Item3_C
