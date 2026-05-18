local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Purchase_HintItem_C = Base:Extend("UMG_Purchase_HintItem_C")

function UMG_Purchase_HintItem_C:OnConstruct()
end

function UMG_Purchase_HintItem_C:OnDestruct()
end

function UMG_Purchase_HintItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Dialogue:SetText(self.data.name)
end

function UMG_Purchase_HintItem_C:OnItemSelected(_bSelected)
end

function UMG_Purchase_HintItem_C:OnDeactive()
end

return UMG_Purchase_HintItem_C
