local UMG_BoookDepartment_C = _G.NRCPanelBase:Extend("UMG_BoookDepartment_C")

function UMG_BoookDepartment_C:OnConstruct()
end

function UMG_BoookDepartment_C:OnDestruct()
end

function UMG_BoookDepartment_C:OnActive()
end

function UMG_BoookDepartment_C:SetPathInfo(type)
  local Icon = type.type_icon
  self.petTypeIcon2:SetPath(Icon)
  self.Text:SetText(type.short_name)
end

function UMG_BoookDepartment_C:OnDeactive()
end

return UMG_BoookDepartment_C
