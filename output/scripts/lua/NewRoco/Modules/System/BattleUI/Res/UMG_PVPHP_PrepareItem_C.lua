local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVPHP_PrepareItem_C = Base:Extend("UMG_PVPHP_PrepareItem_C")

function UMG_PVPHP_PrepareItem_C:OnConstruct()
  if _G.GlobalConfig.DebugOpenUI then
    self:PlayAnimation(self.In)
  end
end

function UMG_PVPHP_PrepareItem_C:OnDestruct()
end

function UMG_PVPHP_PrepareItem_C:OnItemUpdate(_data, datalist, index)
end

function UMG_PVPHP_PrepareItem_C:OnItemSelected(_bSelected)
end

function UMG_PVPHP_PrepareItem_C:OnDeactive()
end

function UMG_PVPHP_PrepareItem_C:PlayAnimationIn()
end

return UMG_PVPHP_PrepareItem_C
