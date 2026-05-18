local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MiracleDropDownListltem_C = Base:Extend("UMG_MiracleDropDownListltem_C")

function UMG_MiracleDropDownListltem_C:OnConstruct()
end

function UMG_MiracleDropDownListltem_C:OnDestruct()
end

function UMG_MiracleDropDownListltem_C:OnActive()
end

function UMG_MiracleDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self:SetData(_data)
end

function UMG_MiracleDropDownListltem_C:SetData(data)
  self.NRCImage_54:SetVisibility(UE4.ESlateVisibility.Hidden)
  local sortId = data
  local PetBagSequence = _G.DataConfigManager:GetPetBagSequence(sortId)
  self.SelectState:SetActiveWidgetIndex(1)
  self.TText:SetText(PetBagSequence.sequence_desc)
  self.TText_1:SetText(PetBagSequence.sequence_desc)
end

function UMG_MiracleDropDownListltem_C:OnItemSelected(selected)
  Log.Trace(self.index, 6, "UMG_PetDropDownListItem_C:SetData")
  if selected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1090, "UMG_PetSkillChange_C:BackBtn_1")
    self.NRCImage_54:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SelectState:SetActiveWidgetIndex(0)
    _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnMiracleMainSortTypeChanged, self.index)
  else
    self.NRCImage_54:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SelectState:SetActiveWidgetIndex(1)
  end
end

function UMG_MiracleDropDownListltem_C:OnDeactive()
end

return UMG_MiracleDropDownListltem_C
