local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MyTeamPetTempate_C = Base:Extend("UMG_MyTeamPetTempate_C")

function UMG_MyTeamPetTempate_C:OnConstruct()
end

function UMG_MyTeamPetTempate_C:OnDestruct()
end

function UMG_MyTeamPetTempate_C:OnItemUpdate(_data, datalist, index)
  if "nil" == _data then
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Normal:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.petData = _data
    if self.petData then
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Normal:SetVisibility(UE4.ESlateVisibility.Visible)
      self.PetLevel:SetText(self.petData.level)
      self.HeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
    end
  end
end

function UMG_MyTeamPetTempate_C:OnItemSelected(_bSelected)
end

function UMG_MyTeamPetTempate_C:OnDeactive()
end

return UMG_MyTeamPetTempate_C
