local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local OffDieShaDashAbility = Base:Extend("OffDieShaDashAbility")

function OffDieShaDashAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "DieShaDashBuff"
end

function OffDieShaDashAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function OffDieShaDashAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return OffDieShaDashAbility
