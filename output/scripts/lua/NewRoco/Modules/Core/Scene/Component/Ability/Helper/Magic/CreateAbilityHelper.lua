local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.Helper.Magic.MagicAbilityBaseHelper")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local CreateAbilityHelper = Base:Extend("CreateAbilityHelper")

function CreateAbilityHelper:Ctor(abilityConfig)
  Base.Ctor(self, abilityConfig)
  self._buffName = "PrepareCreateBuff"
end

function CreateAbilityHelper:CanCastAbility(caster)
  if _G.DataModelMgr.PlayerDataModel:IsVisitState() and not _G.DataModelMgr.PlayerDataModel:IsVisitOwner() then
    return AbilityErrorCode.VISIT_BAN
  end
  if caster and caster.statusComponent then
    local handInHand2P = caster.statusComponent:HasStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
    if handInHand2P then
      return AbilityErrorCode.HAND_IN_HAND_BAN
    end
  end
  if _G.NRCModuleManager:DoCmd(_G.MiniGameModuleCmd.IsPlaying) then
    return AbilityErrorCode.GAME_BAN
  end
  return Base.CanCastAbility(self, caster)
end

return CreateAbilityHelper
