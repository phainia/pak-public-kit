local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ListItem_Pet_2_C = Base:Extend("UMG_ListItem_Pet_2_C")

function UMG_ListItem_Pet_2_C:OnConstruct()
end

function UMG_ListItem_Pet_2_C:OnDestruct()
end

function UMG_ListItem_Pet_2_C:OnItemUpdate(_data, datalist, index)
  self.petID = _data.petID
  self.petGID = _data.petGID
  if self.petGID and _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID) then
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID)
    self.pet:SetIconPathAndMaterial(self.petID, petData.mutation_type, petData.glass_info)
  else
    self.pet:SetIconPathAndMaterial(self.petID)
  end
end

function UMG_ListItem_Pet_2_C:OnItemSelected(_bSelected)
end

function UMG_ListItem_Pet_2_C:OnDeactive()
end

return UMG_ListItem_Pet_2_C
