local Base = require("NewRoco.Modules.Core.Scene.Component.FSM.Player.States.ScenePlayerStateBase")
local ScenePlayerCastAbilityState = Base:Extend("ScenePlayerCastAbilityState")

function ScenePlayerCastAbilityState:CanExit(nextState)
  local currentAbility = self.Player.abilityComponent.CurrentAbility
  if currentAbility and currentAbility:IsCasting() then
    return false
  end
  return true
end

return ScenePlayerCastAbilityState
