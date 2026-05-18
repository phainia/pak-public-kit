require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetBloodlineMagic_PetItem_C = Base:Extend("UMG_PetBloodlineMagic_PetItem_C")

function UMG_PetBloodlineMagic_PetItem_C:Initialize(Initializer)
end

function UMG_PetBloodlineMagic_PetItem_C:OnConstruct()
end

function UMG_PetBloodlineMagic_PetItem_C:OnDestruct()
end

function UMG_PetBloodlineMagic_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self.HeadIcon:SetIconPathAndMaterial(_data.base_conf_id, _data.mutation_type, _data.glass_info)
end

return UMG_PetBloodlineMagic_PetItem_C
