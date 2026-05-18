local SkillCacheData = NRCClass()

function SkillCacheData:Ctor(skill_id, energy_change_value)
  self.skill_id = skill_id
  self.energy_change_value = energy_change_value
end

return SkillCacheData
