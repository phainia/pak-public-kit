local AbilityCD = NRCClass:Extend("AbilityCD")

function AbilityCD:Ctor(abilityID)
  self.id = abilityID
  self.config = DataConfigManager:GetSceneAbilityConf(abilityID)
  self._leftCD = 0
end

function AbilityCD:StartCD()
  self._leftCD = self.config.cooldown
end

function AbilityCD:IsInCD()
  return self._leftCD > 0
end

function AbilityCD:TickCD(deltaTime)
  if self._leftCD > 0 then
    self._leftCD = self._leftCD - deltaTime
  end
end

return AbilityCD
