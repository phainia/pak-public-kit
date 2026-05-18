local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RolePlay_DotItem_C = Base:Extend("UMG_RolePlay_DotItem_C")

function UMG_RolePlay_DotItem_C:OnConstruct()
end

function UMG_RolePlay_DotItem_C:OnDestruct()
end

function UMG_RolePlay_DotItem_C:OnItemUpdate(_data, datalist, index)
end

function UMG_RolePlay_DotItem_C:OnItemSelected(_bSelected)
  self.Bright:SetVisibility(_bSelected and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_RolePlay_DotItem_C:OnDeactive()
end

return UMG_RolePlay_DotItem_C
