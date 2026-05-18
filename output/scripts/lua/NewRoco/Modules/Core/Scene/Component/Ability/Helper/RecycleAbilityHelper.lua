local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local RecycleAbilityHelper = Base:Extend("RecycleAbilityHelper")

function RecycleAbilityHelper:HandleStatus(caster, ...)
  local ability = caster.abilityComponent:GetAbilityFromPool(AbilityID.RECYCLE_THROW)
  local success = caster.inputComponent:CastAbility(ability, nil, ...)
  caster.abilityComponent:ReturnAbilityToPool(ability)
  return success
end

function RecycleAbilityHelper:CanCastAbility(caster)
  local gid = NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  local session = ThrowSession.GetWithGID(gid)
  if not session then
    return Base.CanCastAbility(self, caster)
  end
  if session.canBeRecycle == false then
    return AbilityErrorCode.INPUT_DISABLED
  end
  return Base.CanCastAbility(self, caster)
end

return RecycleAbilityHelper
