require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local PlayerDashBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerDashBuff")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local EventDispatcher = require("Common.EventDispatcher")
local BP_MainAbility_C = Base:Extend("BP_MainAbility_C")

function BP_MainAbility_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  self._buffName = "PlayerDashBuff"
  self._checkInterval = 0
  self._maintainTime = self:GetMaintainTime()
  if not self._maintainTime then
    self._maintainTime = 0
  end
  self._castTime = 0
end

function BP_MainAbility_C:Start(onFinished, ...)
  Base.Start(self, onFinished, ...)
  local player = self.caster
  local pawn = player.viewObj
  local characterMovement = pawn.CharacterMovement
  pawn.IsFlailLanding = false
  self._originSpeed = characterMovement.Velocity:Size2D()
  if self._originSpeed <= 0 and pawn.RandomPlayPerformAnim then
    pawn:RandomPlayPerformAnim()
  end
  self._castTime = 0
  local buffLife = 0
  if self._maintainTime and self.helper.typedConfig.dash_duration then
    buffLife = self._maintainTime > self.helper.typedConfig.dash_duration and self._maintainTime or self.helper.typedConfig.dash_duration
  end
  player.buffComponent:AddBuff(self._buffName, PlayerDashBuff, self.caster, buffLife, self.helper.typedConfig, nil, self.helper.config.add_status, self.helper.config.id)
  self:TryLoop(0)
  self:EnterState(ABEnum.AbilityState.Casting)
end

function BP_MainAbility_C:ReturnToPool()
  if self:IsCasting() then
    self:Interrupt()
  end
  Base.ReturnToPool(self)
end

function BP_MainAbility_C:Tick(deltaTime)
  if self.isInPool or not self:IsCasting() then
    return
  end
  self:TryLoop(deltaTime)
end

function BP_MainAbility_C:TryLoop(deltaTime)
  self._castTime = self._castTime + deltaTime
  if self._castTime >= self._maintainTime then
    local buff = self.caster.buffComponent:GetBuff(self._buffName)
    buff:OnLoop()
    self:Finish()
    return
  end
end

function BP_MainAbility_C:Interrupt()
  self.caster.buffComponent:RemoveBuff(self._buffName)
  self:Finish()
end

function BP_MainAbility_C:Finish()
  if self._castTime == nil or nil == self._maintainTime or self._castTime < self._maintainTime then
    local buff = self.caster.buffComponent:GetBuff(self._buffName)
    if buff then
      buff:OnPendingFinish()
    end
  end
  Base.Finish(self)
end

function BP_MainAbility_C:GetMaintainTime()
  if self.helper.GetMaintainTime then
    return self.helper:GetMaintainTime(self.caster)
  end
  local maintainTime = self.helper.typedConfig.maintain_press_time
  maintainTime = maintainTime and maintainTime or 9999.0
  return maintainTime
end

function BP_MainAbility_C:Recover(owner)
  self:Interrupt()
  self.caster.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DASHING)
end

return BP_MainAbility_C
