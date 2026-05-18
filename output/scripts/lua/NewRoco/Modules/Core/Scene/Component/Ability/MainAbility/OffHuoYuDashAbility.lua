local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local OffHuoYuDashAbility = Base:Extend("OffRideDashAbility")

function OffHuoYuDashAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._buffName = "HuoYuDashBuff"
end

function OffHuoYuDashAbility:Start(OnFinished)
  Base.Start(self, OnFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function OffHuoYuDashAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return OffHuoYuDashAbility
