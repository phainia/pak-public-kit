local AppearanceUtils = require("NewRoco.Modules.System.Appearance.AppearanceUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TakePhotos_ClothingItem_C = Base:Extend("UMG_TakePhotos_ClothingItem_C")

function UMG_TakePhotos_ClothingItem_C:OnConstruct()
  self.btnLevelUp:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SelectedAtEnd = nil
end

function UMG_TakePhotos_ClothingItem_C:OnDestruct()
end

function UMG_TakePhotos_ClothingItem_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  local wardrobeConf = self.Data.FashionRolePlayItem.value
  local fashionItems = wardrobeConf.wearing_item
  local iconPath = AppearanceUtils.GetWardrobeIconPath(fashionItems)
  local name = wardrobeConf.name
  if "" == name then
    name = LuaText.umg_appearance_suititem_1 .. self.Data.FashionRolePlayItem.wardrobeIndex
  end
  self.Image_Icon:SetPath(iconPath or "")
  self.Text_Title:SetText(name)
  self.isGlassItem, self.dressGlassInfo = AppearanceUtils.GetWardrobeGlassInfo(fashionItems)
  self.Dazzling:UpdateState(self.isGlassItem, self.dressGlassInfo)
end

function UMG_TakePhotos_ClothingItem_C:OnItemSelected(bSelected)
  if bSelected then
    self.Data.OnClicked()
    if not self.SelectedAtEnd then
      self.SelectedAtEnd = true
      self:PlayAnimationForward(self.Selected_in)
    end
  elseif self.SelectedAtEnd then
    self.SelectedAtEnd = false
    self:PlayAnimationReverse(self.Selected_in)
  end
end

return UMG_TakePhotos_ClothingItem_C
