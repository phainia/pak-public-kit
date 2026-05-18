local UMG_EggIncubatePanel_C = _G.NRCPanelBase:Extend("UMG_EggIncubatePanel_C")

function UMG_EggIncubatePanel_C:OnActive(eggConfId)
  self.RootPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Close:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local petId = _G.DataConfigManager:GetPetEggConf(eggConfId).pet_id
  local name = _G.DataConfigManager:GetPetConf(petId).name
  local desc = _G.DataConfigManager:GetPetGlobalConfig("pet_hatch_text").str
  self.dialogueText = string.format(desc, name)
  self:OnAddEventListener()
end

function UMG_EggIncubatePanel_C:ShowText()
  self.RootPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_TypeWritter.Dialogue:SetJustification(UE4.ETextJustify.Center)
  self.UMG_TypeWritter:Writer(self.dialogueText, 1.0E-5, 1)
  self.UMG_TypeWritter:Initiate()
end

function UMG_EggIncubatePanel_C:OnDeactive()
end

function UMG_EggIncubatePanel_C:OnAddEventListener()
  self:AddButtonListener(self.BtnConfirm.btnLevelUp, self.OnFinshPerform)
  self:AddButtonListener(self.Close, self.OnFinshPerform)
end

function UMG_EggIncubatePanel_C:OnFinshPerform()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1220002038, "UMG_EggIncubatePanel_C:OnFinshPerform")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.CloseEggIncubatePanel)
end

return UMG_EggIncubatePanel_C
