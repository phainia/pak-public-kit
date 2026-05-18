local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_Department_C = Base:Extend("UMG_Nourish_Department_C")

function UMG_Nourish_Department_C:OnConstruct()
end

function UMG_Nourish_Department_C:OnDestruct()
end

function UMG_Nourish_Department_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local TypeDiC = _G.DataConfigManager:GetTypeDictionary(self.data)
  self.Icon:SetPath(TypeDiC.field_res)
end

function UMG_Nourish_Department_C:OnItemSelected(_bSelected)
end

function UMG_Nourish_Department_C:OnDeactive()
end

return UMG_Nourish_Department_C
