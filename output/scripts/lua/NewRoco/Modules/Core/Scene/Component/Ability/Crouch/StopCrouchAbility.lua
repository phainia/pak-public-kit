local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StopCrouchAbility = Base:Extend("StopCrouchAbility")

function StopCrouchAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "PlayerCrouchBuff"
end

function StopCrouchAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function StopCrouchAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return StopCrouchAbility
