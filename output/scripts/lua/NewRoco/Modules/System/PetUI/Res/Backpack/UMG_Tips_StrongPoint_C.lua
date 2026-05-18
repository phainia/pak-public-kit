local UMG_Tips_StrongPoint_C = _G.NRCPanelBase:Extend("UMG_Tips_StrongPoint_C")

function UMG_Tips_StrongPoint_C:OnActive(PetData)
  local specialityId = PetData and PetData.speciality_id
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002013, "UMG_Tips_StrongPoint_C:OnActive")
  if specialityId then
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(specialityId)
    if PetTalentConf then
      local hasRideTalent = false
      for _, v in pairs(PetData.real_speciality_ids) do
        local TalentConf = DataConfigManager:GetPetTalentConf(v, true)
        for _, Effect in pairs(TalentConf.effect_group) do
          if Effect.effect == ProtoEnum.PetTalentEffect.PTE_TWO_PLAYER_MOUNT then
            hasRideTalent = true
          end
        end
      end
      self.Pet:SetIconPathAndMaterial(PetData.base_conf_id, PetData.mutation_type, PetData.glass_info)
      self.SkillNameTxt:SetText(PetTalentConf.name)
      local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if localPlayer and localPlayer.viewObj and localPlayer.viewObj.BP_RideComponent and not localPlayer.viewObj.BP_RideComponent:RidePetHasDoubleRideSocket(PetData.base_conf_id) and hasRideTalent then
        self.ChangeText:SetText(PetTalentConf.spec_desc)
      else
        self.ChangeText:SetText(PetTalentConf.desc)
      end
    end
  end
  self:LoadAnimation(0)
  self:OnAddEventListener()
end

function UMG_Tips_StrongPoint_C:OnDeactive()
end

function UMG_Tips_StrongPoint_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnCloseButtonClicked)
end

function UMG_Tips_StrongPoint_C:OnPcClose()
  self:OnCloseButtonClicked()
end

function UMG_Tips_StrongPoint_C:OnCloseButtonClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40002014, "UMG_Tips_StrongPoint_C:OnCloseButtonClicked")
  self:LoadAnimation(2)
end

function UMG_Tips_StrongPoint_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Tips_StrongPoint_C
