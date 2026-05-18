local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Photo_PetItem_C = Base:Extend("UMG_Photo_PetItem_C")

function UMG_Photo_PetItem_C:OnConstruct()
end

function UMG_Photo_PetItem_C:OnDestruct()
end

function UMG_Photo_PetItem_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    return
  end
  self.petID = _data.petID
  self.petGID = _data.petGID
  if self.petGID and 0 ~= self.petGID and _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID) then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID)
    self.HeadIcon:SetIconPathAndMaterial(self.petID, petData.mutation_type, petData.glass_info)
  else
    self.HeadIcon:SetIconPathAndMaterial(self.petID)
  end
end

function UMG_Photo_PetItem_C:OnItemSelected(_bSelected)
end

function UMG_Photo_PetItem_C:OnDeactive()
end

return UMG_Photo_PetItem_C
