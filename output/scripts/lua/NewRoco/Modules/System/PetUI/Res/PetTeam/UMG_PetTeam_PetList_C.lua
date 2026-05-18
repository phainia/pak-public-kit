local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetTeam_PetList_C = Base:Extend("UMG_PetTeam_PetList_C")

function UMG_PetTeam_PetList_C:OnConstruct()
end

function UMG_PetTeam_PetList_C:OnDestruct()
end

function UMG_PetTeam_PetList_C:OnItemUpdate(_data, datalist, index)
  self.Pet:SetPath(_data.modelConf.small_icon)
end

function UMG_PetTeam_PetList_C:OnItemSelected(_bSelected)
end

function UMG_PetTeam_PetList_C:OnDeactive()
end

return UMG_PetTeam_PetList_C
