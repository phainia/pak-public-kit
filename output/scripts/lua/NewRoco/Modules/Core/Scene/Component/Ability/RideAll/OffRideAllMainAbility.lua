local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local OffRideAllMainAbility = Base:Extend("OffRideAllMainAbility")

function OffRideAllMainAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "RideAll_Main_Buff"
end

function OffRideAllMainAbility:Start(onFinished)
  Log.Debug("OffRideAllMainAbility Start")
  Base.Start(self, onFinished)
  if self.caster.buffComponent:HasBuff(self._buffName) then
    self.caster.buffComponent:RemoveBuff(self._buffName)
  end
end

function OffRideAllMainAbility:Recover(owner)
  self:Start()
end

return OffRideAllMainAbility
