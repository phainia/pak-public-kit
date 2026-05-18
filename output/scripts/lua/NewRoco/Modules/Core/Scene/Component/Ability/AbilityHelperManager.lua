local BaseHelper = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelper")
_G.AbilityHelperManager = NRCClass:Extend("AbilityHelperManager")
AbilityHelperManager._helperTable = {}

function AbilityHelperManager.GetHelper(abilityID)
  local helper = AbilityHelperManager._helperTable[abilityID]
  if not helper then
    helper = AbilityHelperManager.CreateHelper(abilityID)
    AbilityHelperManager._helperTable[abilityID] = helper
  end
  return helper
end

function AbilityHelperManager.CreateHelper(abilityID)
  local helper
  local abilityConfig = DataConfigManager:GetSceneAbilityConf(abilityID)
  if not abilityConfig then
    Log.Error("Cant find ability config by id ", id)
    return
  end
  if string.IsNilOrEmpty(abilityConfig.helper_path) then
    helper = BaseHelper(abilityConfig)
  else
    local helperClass = require(abilityConfig.helper_path)
    helper = helperClass(abilityConfig)
  end
  return helper
end

return AbilityHelperManager
