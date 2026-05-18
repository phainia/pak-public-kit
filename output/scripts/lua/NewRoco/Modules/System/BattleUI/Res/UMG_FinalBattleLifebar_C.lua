local UMG_FinalBattleLifebar_C = _G.NRCPanelBase:Extend("UMG_FinalBattleLifebar_C")

function UMG_FinalBattleLifebar_C:OnActive(pet)
  self.Text_Name:SetText(pet.card.name)
  self.UMG_Pet_ProgressBar_Big:InitView(pet)
  self.BossHead:SetIconPathAndMaterial(pet.card.petInfo.battle_common_pet_info.base_conf_id, pet.card.petInfo.battle_common_pet_info.mutation_type, pet.card.petInfo.battle_common_pet_info.glass_info)
  local level = 99
  self.TxtLevel:SetText(level .. LuaText.umg_nourish_2)
end

function UMG_FinalBattleLifebar_C:OnDeactive()
end

function UMG_FinalBattleLifebar_C:OnAddEventListener()
end

return UMG_FinalBattleLifebar_C
