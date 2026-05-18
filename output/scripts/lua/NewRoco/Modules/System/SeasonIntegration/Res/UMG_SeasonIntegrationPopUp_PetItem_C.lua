local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SeasonIntegrationPopUp_PetItem_C = Base:Extend("UMG_SeasonIntegrationPopUp_PetItem_C")

function UMG_SeasonIntegrationPopUp_PetItem_C:OnConstruct()
end

function UMG_SeasonIntegrationPopUp_PetItem_C:OnDestruct()
end

function UMG_SeasonIntegrationPopUp_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local pet_id = _data.id
  local bShiny = _data.bShiny
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(pet_id)
  if petBaseConf then
    local pet_type = petBaseConf.unit_type[1]
    local typeConf = _G.DataConfigManager:GetTypeDictionary(pet_type)
    if typeConf then
      self.IconType:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(typeConf.rolecard_favorite_pets_colour))
    end
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      if bShiny then
        self.IconPet:SetPath(modelConf.big_shiny_icon)
        self.IconShiny:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.IconPet:SetPath(modelConf.big_icon)
        self.IconShiny:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_SeasonIntegrationPopUp_PetItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_SeasonIntegrationPopUp_PetItem_C:OnItemSelected")
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.id)
    if petBaseConf then
      _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, self.data.id, true, self.data.bShiny)
    end
  end
end

function UMG_SeasonIntegrationPopUp_PetItem_C:OnDeactive()
end

return UMG_SeasonIntegrationPopUp_PetItem_C
