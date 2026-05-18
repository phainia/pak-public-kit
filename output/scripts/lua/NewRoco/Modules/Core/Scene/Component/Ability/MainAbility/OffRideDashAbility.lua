local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local OffRideDashAbility = Base:Extend("OffRideDashAbility")

function OffRideDashAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "WolfDashBuff"
end

function OffRideDashAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function OffRideDashAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return OffRideDashAbility
