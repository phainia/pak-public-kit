local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_AppearanceAccess_C = Base:Extend("UMG_AppearanceAccess_C")

function UMG_AppearanceAccess_C:OnConstruct()
end

function UMG_AppearanceAccess_C:OnDestruct()
end

function UMG_AppearanceAccess_C:OnItemUpdate(_data, datalist, index)
  self.NRCTitle:SetText(_data.acquire_way_text)
end

function UMG_AppearanceAccess_C:OnItemSelected(_bSelected)
end

function UMG_AppearanceAccess_C:OnDeactive()
end

return UMG_AppearanceAccess_C
