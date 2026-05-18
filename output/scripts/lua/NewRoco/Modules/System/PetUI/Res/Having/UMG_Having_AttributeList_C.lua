local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Having_AttributeList_C = Base:Extend("UMG_Having_AttributeList_C")

function UMG_Having_AttributeList_C:OnConstruct()
end

function UMG_Having_AttributeList_C:OnDestruct()
end

function UMG_Having_AttributeList_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_Having_AttributeList_C:SetInfo()
  local data = self.data
  self.Title:SetText(self.data.Text)
  Log.Dump(data[1], 6, "UMG_Having_AttributeList_C:SetInfo")
  self.List:InitGridView(data[1])
end

function UMG_Having_AttributeList_C:OnItemSelected(_bSelected)
end

function UMG_Having_AttributeList_C:OnDeactive()
end

return UMG_Having_AttributeList_C
