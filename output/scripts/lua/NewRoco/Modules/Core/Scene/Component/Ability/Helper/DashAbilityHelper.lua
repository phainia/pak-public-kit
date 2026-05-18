local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local DashAbilityHelper = Base:Extend("DashAbilityHelper")

function DashAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self.basic_movement_conf = DataConfigManager:GetRideBasicMovement(self.typedConfig.basic_movement_id)
end

function DashAbilityHelper:CanCastAbility(caster)
  if not caster then
    return AbilityErrorCode.CAN_NOT_FIND_ABILITY
  end
  local vitalityComp = caster.vitalityComponent
  local vitalityCost = self.basic_movement_conf and self.basic_movement_conf.vitality_cost.min_start
  if vitalityComp and not vitalityComp:IsVitalityEnough(vitalityCost) then
    return AbilityErrorCode.VITALITY_NOT_ENOUGH
  end
  if caster.viewObj then
    local isOnGround = caster.viewObj.CharacterMovement:IsMovingOnGround()
    if isOnGround then
      return AbilityErrorCode.NO_ERROR
    end
    local isSwimming = caster.viewObj.CharacterMovement:IsSwimming()
    if isSwimming then
      return AbilityErrorCode.NO_ERROR
    end
    return AbilityErrorCode.CAN_NOT_FIND_ABILITY
  end
  return Base.CanCastAbility(self, caster)
end

function DashAbilityHelper:CanContinue(caster)
  local viewObj = caster.viewObj
  local characterMovement = viewObj.CharacterMovement
  return characterMovement:IsMovingOnGround() or characterMovement:IsJumping() or characterMovement.MovementMode == UE4.EMovementMode.MOVE_Swimming
end

function DashAbilityHelper:IsBlock(caster)
  local statusComponent = caster.statusComponent
  if statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_FALLING) and not statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DASHING) then
    return true
  end
  return Base.IsBlock(self, caster)
end

return DashAbilityHelper
