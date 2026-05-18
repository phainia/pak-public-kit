local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local HelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local MainAbilityHelper = Base:Extend("MainAbilityHelper")

function MainAbilityHelper:GetHelper(caster)
  if not caster then
    return nil
  end
  local player = caster
  if not UE.UObject.IsValid(player.viewObj) then
    return HelperManager.GetHelper(AbilityID.DASH)
  end
  local movementComponent = player.viewObj.CharacterMovement
  if not movementComponent then
    return nil
  end
  if movementComponent.MovementMode == UE4.EMovementMode.MOVE_Swimming then
    return HelperManager.GetHelper(AbilityID.SWIM_DASH)
  elseif movementComponent:IsMovingOnGround() or movementComponent:IsJumping() then
    return HelperManager.GetHelper(AbilityID.DASH)
  end
  return nil
end

function MainAbilityHelper:CanCastAbility(caster)
  if not caster or not UE.UObject.IsValid(caster.viewObj) then
    return AbilityErrorCode.NO_CASTER
  end
  local player = caster.viewObj
  if player.CharacterMovement:GetLastInputVector():Size() <= 0 then
    return AbilityErrorCode.NO_MOVE_INPUT
  end
  local helper = self:GetHelper(caster)
  if helper then
    return helper:CanCastAbility(caster)
  else
    return AbilityErrorCode.CAN_NOT_FIND_ABILITY
  end
end

function MainAbilityHelper:GetIcon(caster, isBlock)
  local helper = self:GetHelper(caster) or HelperManager.GetHelper(AbilityID.DASH)
  return helper and helper:GetIcon(caster, isBlock) or nil
end

function MainAbilityHelper:GetPressIcon(caster)
  local helper = self:GetHelper(caster)
  if helper then
    return helper:GetPressIcon(caster)
  end
  return nil
end

function MainAbilityHelper:HandleStatus(caster, remove)
  if not caster then
    return
  end
  local statusComponent = caster.statusComponent
  local status = self.config.add_status
  if remove then
    for _, v in pairs(status) do
      statusComponent:RemoveStatus(v)
    end
  else
    local firstStatus = status[1]
    if not firstStatus or not statusComponent:HasStatus(firstStatus) then
      Base.HandleStatus(self, caster)
    else
      for _, v in pairs(status) do
        statusComponent:RemoveStatus(v)
      end
    end
  end
end

function MainAbilityHelper:GetMaintainTime(caster)
  local helper = self:GetHelper(caster)
  if helper then
    local maintainTime = helper.typedConfig.maintain_press_time
    maintainTime = maintainTime and maintainTime or 9999.0
    return maintainTime
  end
end

return MainAbilityHelper
