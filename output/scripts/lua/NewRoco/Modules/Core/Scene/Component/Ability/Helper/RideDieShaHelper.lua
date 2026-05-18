local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local RideDieShaHelper = Base:Extend("RideWolfHelper")

function RideDieShaHelper:CanCastAbility(caster)
  if not self:CheckInWater(caster) then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  if caster.buffComponent:HasBuff("RideDieshaBuff") then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  return Base.CanCastAbility(self, caster)
end

function RideDieShaHelper:CheckInWater(caster)
  local movement = caster.viewObj.CharacterMovement
  return caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING)
end

function RideDieShaHelper:IsBlock(caster)
  if not self:CheckInWater(caster) then
    return true
  end
  return Base.IsBlock(self, caster)
end

return RideDieShaHelper
