require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Ability.ThrowBall.BP_ThrowBallBase_C")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local BP_LanNiaoThrThrowBall_C = Base:Extend("BP_LanNiaoThrThrowBall_C")

function BP_LanNiaoThrThrowBall_C:CanCastAbility()
  if self:IsPreCasting() or self:IsCasting() then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  local canApply, overrideValues, opCode = self.caster.statusComponent:PreApplyStatus(Enum.WorldPlayerStatusType.WPST_LANNIAO_THR_THROWING)
  if not canApply then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  local AnimInstance = self.caster.viewObj.Mesh:GetAnimInstance()
  if not AnimInstance or 2 ~= AnimInstance.AnimMode then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  return Base.CanCastAbility(self)
end

return BP_LanNiaoThrThrowBall_C
