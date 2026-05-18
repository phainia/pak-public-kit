local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ThrowBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerThrowBuff")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local PerceptionBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerPerceptionBuff")
local EndPerceptionAbility = Base:Extend("EndPerceptionAbility")

function EndPerceptionAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "PerceptionBuff"
end

function EndPerceptionAbility:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  Log.TraceFormat("EndPerceptionAbility AwakeFromPool")
end

function EndPerceptionAbility:Start(onFinished, success)
  Log.Debug("EndPerceptionAbility Start")
  Base.Start(self, onFinished)
  local player = self.caster
  self.buff = player.buffComponent:GetBuff(self._buffName)
  if self.buff == nil then
    return
  end
  player.buffComponent:RemoveBuff(self._buffName)
end

function EndPerceptionAbility:Interrupt()
end

function EndPerceptionAbility:Recover()
  Log.Debug("EndPerceptionAbility Recover")
  self:Start()
end

function EndPerceptionAbility:Finish(Force)
end

return EndPerceptionAbility
