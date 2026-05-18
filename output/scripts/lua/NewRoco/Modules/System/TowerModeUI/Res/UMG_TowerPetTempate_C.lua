local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TowerPetTempate_C = Base:Extend("UMG_TowerPetTempate_C")

function UMG_TowerPetTempate_C:OnConstruct()
end

function UMG_TowerPetTempate_C:OnDestruct()
end

function UMG_TowerPetTempate_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetPetInfo()
end

function UMG_TowerPetTempate_C:SetPetInfo()
  local petData = self.uiData
  self.PetLevel_1:SetText(petData.PetLevel)
  self.PetIconImg:SetPath(petData.modelConf.icon)
end

function UMG_TowerPetTempate_C:OnItemSelected(_bSelected)
end

function UMG_TowerPetTempate_C:OnDeactive()
end

return UMG_TowerPetTempate_C
