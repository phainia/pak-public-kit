local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Magic_Nourish_List_C = Base:Extend("UMG_Magic_Nourish_List_C")

function UMG_Magic_Nourish_List_C:OnConstruct()
end

function UMG_Magic_Nourish_List_C:OnDestruct()
end

function UMG_Magic_Nourish_List_C:OnItemUpdate(_data, datalist, _index)
  self.index = _index
  self.uiData = _data
  self:SetData()
end

function UMG_Magic_Nourish_List_C:OnItemSelected(_bSelected)
end

function UMG_Magic_Nourish_List_C:OnDeactive()
end

function UMG_Magic_Nourish_List_C:SetData()
  self.List:InitGridView(self.uiData)
end

return UMG_Magic_Nourish_List_C
