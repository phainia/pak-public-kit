local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetLeader_Item_C = Base:Extend("UMG_PetLeader_Item_C")

function UMG_PetLeader_Item_C:OnConstruct()
end

function UMG_PetLeader_Item_C:OnDestruct()
end

function UMG_PetLeader_Item_C:OnItemUpdate(_data, datalist, index)
  self.HeadIcon:SetIconPathAndMaterial(_data.id)
end

function UMG_PetLeader_Item_C:OnItemSelected(_bSelected)
end

function UMG_PetLeader_Item_C:OnDeactive()
end

return UMG_PetLeader_Item_C
