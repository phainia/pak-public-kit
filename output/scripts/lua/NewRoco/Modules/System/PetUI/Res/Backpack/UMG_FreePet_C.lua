local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FreePet_C = Base:Extend("UMG_FreePet_C")

function UMG_FreePet_C:OnConstruct()
end

function UMG_FreePet_C:OnDestruct()
end

function UMG_FreePet_C:OnItemUpdate(_data, datalist, index)
  self.PetList = _data
  self:SetData()
end

function UMG_FreePet_C:SetData()
  local petList = self.PetList
  if petList then
    if petList.IsTeamPet == false then
      if petList then
        self.NumText:SetText(petList.IconListInfo)
        self.HeadIcon:SetIconPathAndMaterial(petList.PetBaseId, petList.mutation_typ, petList.glass_info)
      end
    elseif petList.IsHasPet and petList then
      self.NumText:SetText(petList.IconListInfo)
      self.HeadIcon:SetIconPathAndMaterial(petList.PetBaseId, petList.mutation_typ, petList.glass_info)
    end
  end
end

function UMG_FreePet_C:OnItemSelected(_bSelected)
end

function UMG_FreePet_C:OnDeactive()
end

return UMG_FreePet_C
