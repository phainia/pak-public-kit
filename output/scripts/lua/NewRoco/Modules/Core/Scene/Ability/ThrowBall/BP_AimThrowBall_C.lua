require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Ability.ThrowBall.BP_ThrowBallBase_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local BP_AimThrowBall_C = Base:Extend("BP_AimThrowBall_C")

function BP_AimThrowBall_C:CanCastAbility()
  if self:IsPreCasting() or self:IsCasting() then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  self:RefreshThrowAbility()
  local AnimInstance = self.caster.viewObj.Mesh:GetAnimInstance()
  if self.throwStat == ProtoEnum.SceneThrowAbilityType.STAT_NORMAL then
    if not AnimInstance or 0 ~= AnimInstance.AnimMode then
      return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
    end
  elseif self.throwStat == ProtoEnum.SceneThrowAbilityType.STAT_RIDE_WOLF then
    if not AnimInstance or 1 ~= AnimInstance.AnimMode then
      return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
    end
  elseif self.throwStat == ProtoEnum.SceneThrowAbilityType.STAT_RIDE_LANNIAO or self.throwStat == ProtoEnum.SceneThrowAbilityType.STAT_RIDE_LANNIAO3 then
    if not AnimInstance or 2 ~= AnimInstance.AnimMode then
      return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
    end
  elseif self.throwStat == ProtoEnum.SceneThrowAbilityType.STAT_RIDE_BALLON and (not AnimInstance or 3 ~= AnimInstance.AnimMode) then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  return Base.CanCastAbility(self)
end

return BP_AimThrowBall_C
