local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AscendingAbilityHelper = Base:Extend("AscendingAbilityHelper")

function AscendingAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self.basic_movement_conf = DataConfigManager:GetRideBasicMovement(self.typedConfig.basic_movement_id)
end

function AscendingAbilityHelper:CanCastAbility(caster)
  local vitalityCost = self.basic_movement_conf and self.basic_movement_conf.vitality_cost.min_start or 0
  if not caster.vitalityComponent:IsVitalityEnough(vitalityCost) then
    return AbilityErrorCode.VITALITY_NOT_ENOUGH
  end
  if not caster.buffComponent:HasBuff("GlidingBuff") then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  return Base.CanCastAbility(self, caster)
end

function AscendingAbilityHelper:HandleStatus(caster, remove, opCode, ...)
  local statusComponent = caster.statusComponent
  local status = self.config.add_status
  if remove then
    for _, v in pairs(status) do
      statusComponent:RemoveStatus(v, opCode, ...)
    end
    return
  end
  if not statusComponent:HasStatus(status[1]) then
    Base.HandleStatus(self, caster, caster, remove, opCode, ...)
  else
    for _, v in pairs(status) do
      statusComponent:RemoveStatus(v)
    end
  end
end

return AscendingAbilityHelper
