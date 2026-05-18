local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local ClimbDashHelper = Base:Extend("ClimbDashHelper")

function ClimbDashHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self.basic_movement_conf = DataConfigManager:GetRideBasicMovement(6)
end

function ClimbDashHelper:IsVitalityEnough(caster)
  if not caster then
    return false
  end
  local vitalityCost = self.basic_movement_conf.vitality_cost.min_start
  if not caster.vitalityComponent:IsVitalityEnough(vitalityCost) then
    return false
  end
  return true
end

function ClimbDashHelper:CanCastAbility(caster)
  if not caster then
    return false
  end
  if not self:IsVitalityEnough(caster) then
    return AbilityErrorCode.VITALITY_NOT_ENOUGH
  end
  return Base.CanCastAbility(self, caster)
end

return ClimbDashHelper
