local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local RideWolfHelper = Base:Extend("RideWolfHelper")

function RideWolfHelper:CanCastAbility(caster)
  if caster.buffComponent:HasBuff("RideBuff") then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  local ability = caster.abilityComponent:GetAbility(self.config.id)
  if ability and ability:IsCasting() then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  return Base.CanCastAbility(self, caster)
end

return RideWolfHelper
