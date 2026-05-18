local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_Subject_IconItem_C = Base:Extend("UMG_Handbook_Subject_IconItem_C")

function UMG_Handbook_Subject_IconItem_C:OnConstruct()
end

function UMG_Handbook_Subject_IconItem_C:OnBtnClick()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.data.Id, self.data.Type, false)
end

function UMG_Handbook_Subject_IconItem_C:OnDestruct()
end

function UMG_Handbook_Subject_IconItem_C:OnTouchEnded()
  self:OnBtnClick()
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Handbook_Subject_IconItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  local IconPath, BgQuality
  self.Button_35.OnClicked:Add(self, self.OnBtnClick)
  if self.data.award_type == _G.Enum.PetHandbookAward.AWARD_VITEM then
    local VIItemConf = _G.DataConfigManager:GetVisualItemConf(self.data.award_id)
    IconPath = NRCUtils:FormatConfIconPath(VIItemConf.bigIcon, _G.UIIconPath.BagItemPath)
    BgQuality = VIItemConf.item_quality
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    local id = self.data.award_id
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(id)
    IconPath = NRCUtils:FormatConfIconPath(BagItemConf.icon, _G.UIIconPath.BagItemPath)
    BgQuality = BagItemConf.item_quality
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_CATCH then
  elseif self.data.award_type == _G.Enum.PetHandbookAward.AWARD_PET_CATCH_CHANCE then
    IconPath = "PaperSprite'/Game/NewRoco/Modules/System/Handbook/Raw/Common/Images/Frames/img_icon_png.img_icon_png'"
    BgQuality = 1
  end
  self.icon:SetPath(IconPath)
  self.NRCText_15:SetText(self.data.award_count)
  self:SetQuality(BgQuality)
end

function UMG_Handbook_Subject_IconItem_C:OnItemSelected(_bSelected)
  if _bSelected then
  end
end

function UMG_Handbook_Subject_IconItem_C:SetQuality(quality)
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

function UMG_Handbook_Subject_IconItem_C:OnDeactive()
end

return UMG_Handbook_Subject_IconItem_C
