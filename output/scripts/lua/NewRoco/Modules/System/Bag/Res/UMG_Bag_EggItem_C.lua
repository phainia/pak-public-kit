local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Bag_EggItem_C = Base:Extend("UMG_Bag_EggItem_C")

function UMG_Bag_EggItem_C:OnItemUpdate(_data, datalist, index)
  self:OnShowItem(_data)
end

function UMG_Bag_EggItem_C:OnShowItem(_data)
  self.data = _data
  self:OnSwitcherSwitcher(self.data.type)
  self.Quantity:SetText(self.data.des)
  self.Quantity_1:SetText(self.data.des)
  self.Quantity_3:SetText(self.data.des)
  self:PlayAnimation(self.In)
end

function UMG_Bag_EggItem_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Bag_EggItem_C
