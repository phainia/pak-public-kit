local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ThrowBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerThrowBuff")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local CastMagicAbilityBase = Base:Extend("CastMagicAbilityBase")

function CastMagicAbilityBase:Init(AbilityConf)
  Base.Init(self, AbilityConf)
end

function CastMagicAbilityBase:Start(OnFinished, Success, ...)
  Log.Debug("CastMagicAbilityBase Start")
  Base.Start(self, OnFinished)
  local player = self.caster
  self.buff = AbilityHelperManager.GetHelper(self._abilityId):GetBuff(self.caster)
  if self.buff == nil then
    return
  end
  self:EnterState(ABEnum.AbilityState.Casting)
  self.caster:SendEvent(PlayerModuleEvent.ON_THROW_EXPOSED, true)
  if not self.caster.isLocal then
    if self.buff.SyncCastSuccess then
      self:CastMagic(...)
    else
      self:Interrupt()
    end
    return
  end
  if Success or NRCEnv:IsLocalMode() then
    self:CastMagic(...)
  else
    self:Interrupt()
  end
end

function CastMagicAbilityBase:CastMagic(...)
end

function CastMagicAbilityBase:Interrupt()
  Log.Debug("CastMagicAbilityBase:Recover")
end

function CastMagicAbilityBase:Recover()
  Log.Debug("CastMagicAbilityBase:Recover")
end

function CastMagicAbilityBase:OnMozhangDisappear()
  Log.Debug("CastMagicAbilityBase:OnMozhangDisappear")
  if self.buff and self.buff.magicInfo and self.buff.magicInfo.mozhangBP then
    self.buff.magicInfo.mozhangBP:ClearFX()
    self.buff.magicInfo.mozhangBP:OnDisappear()
    self.buff.magicInfo.mozhangBP = nil
  end
end

function CastMagicAbilityBase:Finish(Force)
  Log.Debug("CastMagicAbilityBase:Finish")
  if self.buff == nil then
    return
  end
  self:OnMozhangDisappear()
  self.buff = nil
  local player = self.caster
  player.buffComponent:RemoveBuff(AbilityHelperManager.GetHelper(self._abilityId):GetBuffName())
  if self.caster.isLocal then
    self.caster.viewObj:ChangeThrowAnim(0)
    self.caster:SendEvent(PlayerModuleEvent.ON_THROW_EXPOSED, false)
  else
    self.caster.viewObj:SetAimMode(false, 0)
  end
  Base.Finish(self)
end

return CastMagicAbilityBase
