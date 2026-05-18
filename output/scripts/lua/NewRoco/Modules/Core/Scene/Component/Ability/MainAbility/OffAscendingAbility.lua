local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local OffAscendingAbility = Base:Extend("OffAscendingAbility")

function OffAscendingAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "AscendBuff"
end

function OffAscendingAbility:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
end

function OffAscendingAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:RemoveBuff(self._buffName)
end

function OffAscendingAbility:Recover(owner)
  owner.buffComponent:RemoveBuff(self._buffName)
end

return OffAscendingAbility
