local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SelectionOfBranchColleges_Item_C = _G.NRCViewBase:Extend("UMG_SelectionOfBranchColleges_Item_C")

function UMG_SelectionOfBranchColleges_Item_C:OnConstruct()
  self:OnUnSelectItem()
  self:AddButtonListener(self.Button_18, self.OnItemSelected)
end

function UMG_SelectionOfBranchColleges_Item_C:OnDestruct()
end

function UMG_SelectionOfBranchColleges_Item_C:OnShowItemUpdate(_data, index)
  self.data = _data
  self.index = index
  local conf = self.data.conf
  self.Image_Select:SetPath(conf.selected_pic)
  self.CollegeName:SetText(conf.name)
  self.CollegeBadge:SetPath(conf.pic)
  self.bSelected = false
end

function UMG_SelectionOfBranchColleges_Item_C:OnItemSelected()
  if UE4.UObject.IsValid(self.data.parent) then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_SelectionOfBranchColleges_Item_C:OnTouchEnded")
    self.data.parent:OnSelectItem(self.index, self.data)
  end
end

function UMG_SelectionOfBranchColleges_Item_C:OnSelectItem()
  if not self.bSelected then
    self:PlayAnimation(self.Select)
    self.bSelected = true
  end
end

function UMG_SelectionOfBranchColleges_Item_C:OnUnSelectItem()
  if self.bSelected then
    self:PlayAnimation(self.Cancel)
    self.bSelected = false
  end
end

function UMG_SelectionOfBranchColleges_Item_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_SelectionOfBranchColleges_Item_C:OnDeactive()
end

return UMG_SelectionOfBranchColleges_Item_C
