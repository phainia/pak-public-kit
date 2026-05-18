local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_DescribeItem1_C = Base:Extend("UMG_Leve_DescribeItem1_C")

function UMG_Leve_DescribeItem1_C:OnConstruct()
end

function UMG_Leve_DescribeItem1_C:OnDestruct()
end

function UMG_Leve_DescribeItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Title:SetText(self.data.des)
end

function UMG_Leve_DescribeItem1_C:OnItemSelected(_bSelected)
end

function UMG_Leve_DescribeItem1_C:OnDeactive()
end

return UMG_Leve_DescribeItem1_C
