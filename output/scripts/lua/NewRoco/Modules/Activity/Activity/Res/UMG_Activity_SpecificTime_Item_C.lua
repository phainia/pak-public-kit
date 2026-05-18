local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_SpecificTime_Item_C = Base:Extend("UMG_Activity_SpecificTime_Item_C")

function UMG_Activity_SpecificTime_Item_C:OnConstruct()
end

function UMG_Activity_SpecificTime_Item_C:OnDestruct()
end

function UMG_Activity_SpecificTime_Item_C:OnItemUpdate(_data, datalist, index)
  if _data then
    self.Desc:SetText(_data.Desc)
    self.Icon:SetPath(_data.IconPath)
    self.Quantity:SetText(_data.GetNum)
    self.Quantity_1:SetText(_data.LimitNum)
  end
end

function UMG_Activity_SpecificTime_Item_C:OnItemSelected(_bSelected)
end

function UMG_Activity_SpecificTime_Item_C:OnDeactive()
end

return UMG_Activity_SpecificTime_Item_C
