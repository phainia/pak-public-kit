local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PreProcess_Item_C = Base:Extend("UMG_PreProcess_Item_C")

function UMG_PreProcess_Item_C:OnConstruct()
end

function UMG_PreProcess_Item_C:OnDestruct()
end

function UMG_PreProcess_Item_C:OnItemUpdate(_data, datalist, index)
  self.Text:SetText(table.tostring(_data))
end

function UMG_PreProcess_Item_C:OnItemSelected(_bSelected)
end

function UMG_PreProcess_Item_C:OnDeactive()
end

return UMG_PreProcess_Item_C
