local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StopMainAbility = Base:Extend("StopMainAbility")

function StopMainAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "PlayerDashBuff"
end

function StopMainAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function StopMainAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return StopMainAbility
