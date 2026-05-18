local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetTeam_List_C = Base:Extend("UMG_PetTeam_List_C")

function UMG_PetTeam_List_C:OnConstruct()
end

function UMG_PetTeam_List_C:OnDestruct()
end

function UMG_PetTeam_List_C:OnItemUpdate(_data, datalist, index)
  self.NumText:SetText(_data.activedNum)
  self.Icon:SetPath(_data.typeCfg.field_res)
end

function UMG_PetTeam_List_C:OnItemSelected(_bSelected)
end

function UMG_PetTeam_List_C:OnDeactive()
end

return UMG_PetTeam_List_C
