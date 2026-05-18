local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetWareHouseFreeListItem_C = Base:Extend("UMG_PetWareHouseFreeListItem_C")

function UMG_PetWareHouseFreeListItem_C:OnConstruct()
end

function UMG_PetWareHouseFreeListItem_C:OnDestruct()
end

function UMG_PetWareHouseFreeListItem_C:OnItemUpdate(_data, datalist, index)
  self.UiData = _data
  self.Pos = _data.Pos
  self.talentIndex = _data.talentIndex
  self.parent = _data.parent
  if 1 == self.Pos then
    self.TitleSwticher:SetActiveWidgetIndex(self.talentIndex - 1)
    self.TitleSwticher:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.TitleSwticher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.GridView:InitGridView(_data.petList)
end

function UMG_PetWareHouseFreeListItem_C:OnItemSelected(_bSelected, _bScroll)
  if _bSelected then
    if _bScroll then
      local index = self.GridView:GetSelectedIndex()
      local item = self.GridView:GetItemByIndex(index)
      if item then
        item.IsScrollSelect = true
      end
      self.GridView:SelectItemByIndex(index)
    end
    if self.parent and self.parent.RefreshSelectGid and self.UiData.selectIndex then
      self.GridView:SelectItemByIndex(self.UiData.selectIndex - 1)
      self.parent.RefreshSelectGid = nil
    end
  elseif UE4.UObject.IsValid(self.GridView) and self.GridView then
    self.GridView:ClearSelection()
  end
end

function UMG_PetWareHouseFreeListItem_C:OnDeactive()
end

return UMG_PetWareHouseFreeListItem_C
