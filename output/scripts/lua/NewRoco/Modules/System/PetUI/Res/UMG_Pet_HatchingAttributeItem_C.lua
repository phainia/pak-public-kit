local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pet_HatchingAttributeItem_C = Base:Extend("UMG_Pet_HatchingAttributeItem_C")

function UMG_Pet_HatchingAttributeItem_C:OnConstruct()
end

function UMG_Pet_HatchingAttributeItem_C:OnDestruct()
end

function UMG_Pet_HatchingAttributeItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Switcher:SetActiveWidgetIndex(self.data.type)
  self.Quantity:SetText(self.data.des)
end

function UMG_Pet_HatchingAttributeItem_C:OnItemSelected(_bSelected)
end

function UMG_Pet_HatchingAttributeItem_C:OnDeactive()
end

return UMG_Pet_HatchingAttributeItem_C
