local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetTeam_PetItem_C = Base:Extend("UMG_PetTeam_PetItem_C")

function UMG_PetTeam_PetItem_C:OnConstruct()
end

function UMG_PetTeam_PetItem_C:OnDestruct()
end

function UMG_PetTeam_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.petData = _data
  self.HeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
end

function UMG_PetTeam_PetItem_C:OnItemSelected(_bSelected)
end

function UMG_PetTeam_PetItem_C:OnDeactive()
end

return UMG_PetTeam_PetItem_C
