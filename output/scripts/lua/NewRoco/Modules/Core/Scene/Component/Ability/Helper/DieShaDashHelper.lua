local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local DieShaDashHelper = Base:Extend("DieShaDashHelper")

function DieShaDashHelper:CanCastAbility(caster)
  if not self:HasMovementInput(caster) then
    return AbilityErrorCode.NO_MOVE_INPUT
  end
  local vitalityCost = self.typedConfig.dash_start_vitality_cost
  if not caster.vitalityComponent:IsVitalityEnough(vitalityCost) then
    return AbilityErrorCode.VITALITY_NOT_ENOUGH
  end
  if caster.buffComponent:HasBuff(self._buffName) then
    return true
  end
  return Base.CanCastAbility(self, caster)
end

function DieShaDashHelper:HasMovementInput(caster)
  local playerBP = caster.viewObj
  local petBP = playerBP.RidePet
  if petBP then
    local movementComponent = petBP.characterMovement
    local lastInputVector = movementComponent:GetLastInputVector()
    return lastInputVector:Size() > 0
  end
  return false
end

function DieShaDashHelper:HandleStatus(caster, remove)
  if remove then
    local statusComponent = caster.statusComponent
    for _, v in pairs(self.config.add_status) do
      statusComponent:RemoveStatus(v)
    end
    return
  elseif self:CanCastAbility(caster) then
    local ability = caster.abilityComponent:GetAbilityFromPool(AbilityID.DIESHA_DASH)
    caster.inputComponent:CastAbility(ability)
    caster.abilityComponent:ReturnAbilityToPool(ability)
    return
  end
  Base.HandleStatus(self, caster)
end

return DieShaDashHelper
