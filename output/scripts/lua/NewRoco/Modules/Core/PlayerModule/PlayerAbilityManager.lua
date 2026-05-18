local PlayerAbilityManager = NRCClass:Extend("PlayerAbilityManager")

function PlayerAbilityManager:Ctor(module)
  self.playerModule = module
end

function PlayerAbilityManager:GetAbility()
end

function PlayerAbilityManager:CastAbility()
end

return PlayerAbilityManager
