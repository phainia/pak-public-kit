require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BP_DashAbility_C = Base:Extend("BP_DashAbility_C")

function BP_DashAbility_C:Init(AbilityConf)
  Base.Init(self, AbilityConf)
  self._accCurve = self.AccCurve
  self._deaccCurve = self.DeAccCurve
  _, self._maxAccTime = self._accCurve:GetTimeRange()
  _, self._maxDeaccTime = self._deaccCurve:GetTimeRange()
  self._curDuration = 0
  self._originGroundFriction = 0
  self._originMaxSpeed = 0
  self._curVelocity = 0
  self._pendingFinish = false
  self._curCurveTime = 0
  self._isAccelerating = false
  self._originSpeed = 0
  self._originMaxYawSpeed = 0
end

function BP_DashAbility_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
end

function BP_DashAbility_C:Start(onFinished, ...)
  Base.Start(self, onFinished, ...)
  self:OnStart()
end

function BP_DashAbility_C:OnStart()
  local pawn = self.caster.viewObj
  local characterMovement = pawn.CharacterMovement
  self._curDuration = self.helper.typedConfig.dash_duration
  local statComponent = self.caster.statComponent
  if self.helper.config.id == AbilityID.SWIM_DASH then
    self._statMaxSpeedID = statComponent:ApplyStat(StatType.MAX_SWIM_SPEED, self.helper.typedConfig.dash_max_speed, nil, characterMovement)
  else
    local isRMMode = pawn.UseRMLocomotion and not pawn:ShouldIgnoreRootMotion()
    if not isRMMode then
      if self._maxSpeedCurve then
        self._statMaxSpeedCurveID = statComponent:ApplyStat(StatType.MAX_WALK_SPEED_CURVE, self._maxSpeedCurve, nil, characterMovement)
      end
      self._statMaxSpeedID = statComponent:ApplyStat(StatType.MAX_WALK_SPEED, self.helper.typedConfig.dash_max_speed, nil, characterMovement)
    end
  end
  self._curVelocity = 0
  self._curCurveTime = 0
  self._isAccelerating = true
  self._originSpeed = characterMovement.Velocity:Size()
  if pawn.PlayDashPerform then
    pawn:PlayDashPerform()
  end
  self.caster:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_DASHING, self.helper.basic_movement_conf.id)
  return true
end

function BP_DashAbility_C:OnFinish()
  local caster = self.caster.viewObj
  local characterMovement = caster.CharacterMovement
  local statComponent = self.caster.statComponent
  if self.helper.config.id == AbilityID.SWIM_DASH then
    statComponent:RemoveStat(StatType.MAX_SWIM_SPEED, self._statMaxSpeedID, characterMovement)
  else
    local isRMMode = caster.UseRMLocomotion and not caster:ShouldIgnoreRootMotion()
    if not isRMMode then
      if self._maxSpeedCurve then
        statComponent:RemoveStat(StatType.MAX_WALK_SPEED_CURVE, self._statMaxSpeedCurveID, characterMovement)
      end
      statComponent:RemoveStat(StatType.MAX_WALK_SPEED, self._statMaxSpeedID, characterMovement)
    end
  end
  if caster.PerformParams then
    caster.PerformParams.turnSpeed = self._originMaxYawSpeed
  end
  caster.IsDashing = false
  caster.bIsDashing = false
end

function BP_DashAbility_C:OnStop()
  self:OnFinish()
  local player = self.caster
  local caster = player.viewObj
  if caster.StopDashPerform then
    caster:StopDashPerform()
  end
end

function BP_DashAbility_C:AddSpeed(DeltaSeconds)
  self._curCurveTime = self._curCurveTime + DeltaSeconds
  local targetSpeed = self:GetMaxSpeed()
  if not (targetSpeed and self._originSpeed) or not self._accCurve then
    return false, self._curVelocity
  end
  if self._curCurveTime > self._maxAccTime then
    self._curVelocity = targetSpeed
    return false, self._curVelocity
  end
  self._curVelocity = self._originSpeed + (targetSpeed - self._originSpeed) * self._accCurve:GetFloatValue(self._curCurveTime)
  return true, self._curVelocity
end

function BP_DashAbility_C:SubSpeed(DeltaSeconds)
  if self._curVelocity <= self._originSpeed then
    self:Finish(false)
    return false, self._curVelocity
  end
  self._curCurveTime = self._curCurveTime + DeltaSeconds
  if self._curCurveTime > self._maxDeaccTime then
    self._curVelocity = self._originSpeed
    return false, self._curVelocity
  else
    local maxSpeed = self:GetMaxSpeed()
    self._curVelocity = self._originSpeed + (maxSpeed - self._originSpeed) * self._deaccCurve:GetFloatValue(self._curCurveTime)
    return true, self._curVelocity
  end
end

function BP_DashAbility_C:InterpSpeed(deltaTime)
  local targetSpeed = self:GetMaxSpeed()
  self._curVelocity = targetSpeed
  return false, self._curVelocity
end

function BP_DashAbility_C:ReturnToPool()
  Base.ReturnToPool(self)
end

function BP_DashAbility_C:UnInit()
end

function BP_DashAbility_C:GetMaxSpeed()
  if self._maxSpeedCurve then
    local caster = self.caster.viewObj
    local characterMovement = caster.CharacterMovement
    return 612
  end
  return self.helper.typedConfig.dash_max_speed
end

return BP_DashAbility_C
