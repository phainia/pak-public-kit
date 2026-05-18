local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DynamicInformationList_C = Base:Extend("UMG_DynamicInformationList_C")

function UMG_DynamicInformationList_C:OnConstruct()
end

function UMG_DynamicInformationList_C:OnDestruct()
end

function UMG_DynamicInformationList_C:OnItemUpdate(_data, datalist, index)
  self.Text1:SetText(_data)
end

function UMG_DynamicInformationList_C:OnItemSelected(_bSelected)
end

function UMG_DynamicInformationList_C:OnDeactive()
end

return UMG_DynamicInformationList_C
