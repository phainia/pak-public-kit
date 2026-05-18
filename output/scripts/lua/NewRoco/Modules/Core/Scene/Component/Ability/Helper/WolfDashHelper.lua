local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local WolfDashHelper = Base:Extend("WolfDashHelper")

function WolfDashHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self.basic_movement_conf = DataConfigManager:GetRideBasicMovement(2)
end

function WolfDashHelper:CanCastAbility(caster)
  local ability = caster.abilityComponent:GetAbility(self.config.id)
  if ability and ability:IsCasting() then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  if not self:HasMovementInput(caster) then
    return AbilityErrorCode.NO_MOVE_INPUT
  end
  local vitalityCost = self.basic_movement_conf.vitality_cost.min_start
  if not caster.vitalityComponent:IsVitalityEnough(vitalityCost) then
    return AbilityErrorCode.VITALITY_NOT_ENOUGH
  end
  return Base.CanCastAbility(self, caster)
end

function WolfDashHelper:HasMovementInput(caster)
  local playerBP = caster.viewObj
  local wolfBP = playerBP.RidePet
  if wolfBP then
    local movementComponent = wolfBP.characterMovement
    local lastInputVector = movementComponent:GetLastInputVector()
    return lastInputVector:Size() > 0
  end
  return false
end

function WolfDashHelper:HandleStatus(caster, remove)
  if remove then
    local statusComponent = caster.statusComponent
    for _, v in pairs(self.helper.config.add_status) do
      statusComponent:RemoveStatus(v)
    end
    return
  end
  Base.HandleStatus(self, caster, remove)
end

return WolfDashHelper
