local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetReport_Heterochrome_C = _G.NRCPanelBase:Extend("UMG_PetReport_Heterochrome_C")

function UMG_PetReport_Heterochrome_C:OnActive()
end

function UMG_PetReport_Heterochrome_C:OnDeactive()
end

function UMG_PetReport_Heterochrome_C:OnAddEventListener()
end

function UMG_PetReport_Heterochrome_C:SetMutationIcon(pet_brief)
  if pet_brief then
    local mutation_type = pet_brief.mutation_type
    if PetUtils.CheckIsShiningChaos(mutation_type) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(8)
    elseif PetUtils.CheckIsCHAOS(mutation_type) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(3)
    elseif PetUtils.CheckIsHiddenShiningGlass(pet_brief.mutation_type, pet_brief.glass_info) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(6)
      local path = self:GetHiddenGlassLongIcon(pet_brief.glass_info, true)
      if "" ~= path then
        self.DifferentColorsDazzling_Hide:SetPath(path)
      end
    elseif PetUtils.CheckIsShiningGlass(mutation_type) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(4)
    elseif PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(1)
    elseif PetUtils.CheckIsHiddenGlass(pet_brief.mutation_type, pet_brief.glass_info) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(5)
      local path = self:GetHiddenGlassLongIcon(pet_brief.glass_info, false)
      if "" ~= path then
        self.DazzlingColors_Hide:SetPath(path)
      end
    elseif PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_47:SetActiveWidgetIndex(0)
    else
      self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.NRCSwitcher_47:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetReport_Heterochrome_C:GetHiddenGlassLongIcon(glass_info, bShiningGlass)
  if glass_info then
    local HiddenGlassID = glass_info.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf then
        if bShiningGlass and HiddenGlassConf.yise_long_icon then
          return HiddenGlassConf.yise_long_icon
        elseif HiddenGlassConf.long_icon then
          return HiddenGlassConf.long_icon
        end
      end
    end
  end
  return ""
end

return UMG_PetReport_Heterochrome_C
