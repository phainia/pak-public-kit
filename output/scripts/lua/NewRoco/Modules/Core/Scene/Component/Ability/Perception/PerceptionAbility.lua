local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ThrowBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerThrowBuff")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local PerceptionBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerPerceptionBuff")
local PerceptionAbility = Base:Extend("PerceptionAbility")

function PerceptionAbility:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._buffName = "PerceptionBuff"
end

function PerceptionAbility:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  Log.TraceFormat("PerceptionAbility AwakeFromPool")
  local vitalityComponent = self.caster.vitalityComponent
  if vitalityComponent then
    self.vitality = vitalityComponent:GetVitality(self.helper.typedConfig.vitality_id)
  end
end

function PerceptionAbility:Start(OnFinished, Success)
  if not self.caster.isLocal then
    return
  end
  Log.Debug("PerceptionAbility Start")
  Base.Start(self, OnFinished)
  local player = self.caster
  self.buff = player.buffComponent:GetBuff(self._buffName)
  if self.buff ~= nil then
    return
  end
  player.buffComponent:AddBuff(self._buffName, PerceptionBuff, player)
  self.Caster = self.caster.viewObj
end

function PerceptionAbility:Interrupt()
end

function PerceptionAbility:Recover()
  self.caster.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_GANZHI)
end

function PerceptionAbility:Finish(Force)
end

return PerceptionAbility
