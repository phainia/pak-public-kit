local UMG_Having_EffectOfResonance_List_C = _G.NRCViewBase:Extend("UMG_Having_EffectOfResonance_List_C")

function UMG_Having_EffectOfResonance_List_C:OnActive()
end

function UMG_Having_EffectOfResonance_List_C:SetInfo(_data)
  local data = _data
  if nil ~= _data and _data.SkillConf then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SkillIcon:SetPath(data.SkillConf.icon)
    self.TxtSkillName:SetText(data.SkillConf.name)
    self.TxtPnum:SetText(data.SkillConf.energy_cost[1])
    self.TxtPower:SetText(data.SkillConf.dam_para[1])
    local TypeDictionary = _G.DataConfigManager:GetTypeDictionary(data.SkillConf.skill_dam_type)
    self.PetTypeIcon1:SetPath(TypeDictionary.tips_res)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Having_EffectOfResonance_List_C:OnDeactive()
end

function UMG_Having_EffectOfResonance_List_C:OnAddEventListener()
end

return UMG_Having_EffectOfResonance_List_C
