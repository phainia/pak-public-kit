local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RideAllBuff_Dash = Base:Extend("RideAllBuff_Dash")
local DashStage = {
  Start = 1,
  PlayDashFx = 2,
  StopDashFx = 3
}

function RideAllBuff_Dash:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  self:AnalyPropertyModify(SkillConf)
  self._curTime = 0
  self._curMaxSpeed = 0
  self._isPlayingDashFX = false
  self.WalkComp = self.RidePet.VehicleWalkMovement
  self._oldBaseMaxSpeed = self.WalkComp.BaseMaxSpeed
  self._oldAngularCurve = self.WalkComp.LinerAngularSpeedCurve
  self._oldAccelerateCurve = self.WalkComp.AccelerateCurve
  self._oldDeAccelerateCurve = self.WalkComp.DeAccelerateCurve
  self._oldBrakingFriction = self.WalkComp.BrakingFriction
  self._oldBrakingDecelerationWalking = self.WalkComp.BrakingDecelerationWalking
  self._oldGroundFriction = self.WalkComp.GroundFriction
  self._oldMaxSpeedDeacc = self.WalkComp.MaxSpeedDeAcceleration
  self.WalkComp.AccelerateCurve = nil
  self.WalkComp.DeAccelerateCurve = nil
  self.WalkComp.BrakingFriction = 0
  self.WalkComp.BrakingDecelerationWalking = 0
  self.WalkComp.GroundFriction = 0
  self.WalkComp.MaxSpeedDeAcceleration = 99999
  self.DashAcc = tonumber(SkillConf.move_param_1)
  self.DashDeAcc = tonumber(SkillConf.move_param_2)
  self.HoldDashMinSpeed = tonumber(SkillConf.move_param_5)
  self.ReStartMinTime = tonumber(SkillConf.move_param_6)
  self.MaxSpeedCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_3)
  local _min
  _min, self._endTime = self.MaxSpeedCurve:GetTimeRange()
  if SkillConf.move_param_4 then
    self.WalkComp.LinerAngularSpeedCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_4)
  end
  self.moveComp = self.RidePet.CharacterMovement
  self.LineSpeed = self.moveComp.Velocity:Size()
  if not self:HasInput() then
    self:StartFail()
    return
  end
  local SendVitality = self.owner.vitalityComponent:GetVitalityCostRatio() * self.SkillConf.vitality_cost.start_cost
  if SendVitality > self.owner.vitalityComponent:GetCurVitality() then
    SendVitality = self.owner.vitalityComponent:GetCurVitality()
  end
  self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_INIT, SendVitality, self._endTime)
  self:StartCostVitality()
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID, self._endTime)
  self.NormalEnd = false
end

function RideAllBuff_Dash:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  self._remote_isPlayingDashFX = false
  self.WalkComp = self.RidePet.VehicleWalkMovement
  self._remote_baseMaxSpeed = self.WalkComp.BaseMaxSpeed
end

function RideAllBuff_Dash:OnRemotePlayEffect(stage)
  if stage == DashStage.PlayDashFx then
    self:StartOrStopDashFx(true)
  elseif stage == DashStage.StopDashFx then
    self:StartOrStopDashFx(false)
  end
end

function RideAllBuff_Dash:OnPlayerStatusRefresh(status, value, opCode)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY then
    local customParams = self.owner.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY)
    self:OnRemotePlayEffect(customParams.ride_skill_param.skill_stage)
  end
end

function RideAllBuff_Dash:OnRemotePlayerBuffFinish(param)
  Base.OnRemotePlayerBuffFinish(self, param)
  self:StartOrStopDashFx(false)
end

function RideAllBuff_Dash:OnRemotePlayerBuffUpdate(deltaTime)
  if not UE.UObject.IsValid(self.RidePet) then
    return
  end
  local moveComp = self.RidePet.CharacterMovement
  if not moveComp then
    return
  end
  local curSpeed = moveComp.Velocity:Size()
  local shouldPlayFx = curSpeed > self._remote_baseMaxSpeed
  if self._remote_isPlayingDashFX ~= shouldPlayFx then
    self:StartOrStopDashFx(shouldPlayFx)
    self._remote_isPlayingDashFX = shouldPlayFx
  end
end

function RideAllBuff_Dash:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    Log.Debug("Dash Begin!")
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_BEGIN)
  else
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
    self:StartFail()
  end
end

function RideAllBuff_Dash:OnReStartFinish(StartCostSuccess)
  if StartCostSuccess then
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID, self._endTime, true)
    self._curTime = 0
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
    local SendVitality = self.owner.vitalityComponent:GetVitalityCostRatio() * self.SkillConf.vitality_cost.start_cost
    if self.cachedReStartVitality and SendVitality > self.cachedReStartVitality then
      SendVitality = self.cachedReStartVitality
    end
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_INIT, SendVitality, self._endTime)
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_BEGIN)
  end
end

function RideAllBuff_Dash:OnBuffUpdate(deltaTime)
  if not self:CanDash() then
    self:StopActiveSKill()
    return
  end
  self._curTime = self._curTime + deltaTime
  if self._curTime > self._endTime then
    self:StopActiveSKill()
    return
  end
  local initValue = self.MaxSpeedCurve:GetFloatValue(self._curTime)
  if self.propertyModify[3] then
    if 0 == self.modifyMode then
      self._curMaxSpeed = initValue * self.owner.statComponent:GetValue(StatType.SKILL_RUN_SPEED) + self.modifyValue
    elseif 1 == self.modifyMode then
      self._curMaxSpeed = initValue * self.owner.statComponent:GetValue(StatType.SKILL_RUN_SPEED) + initValue * self.modifyValue / 10000
    else
      self._curMaxSpeed = initValue * self.owner.statComponent:GetValue(StatType.SKILL_RUN_SPEED)
    end
  else
    self._curMaxSpeed = initValue * self.owner.statComponent:GetValue(StatType.SKILL_RUN_SPEED)
  end
  if not self._curMaxSpeed or not self.LineSpeed then
    Log.DebugFormat("RideAllBuff_Dash:OnBuffUpdate failed _curMaxSpeed or LineSpeed is nil")
    return
  end
  local hasInput = self:HasInput()
  if hasInput and self.LineSpeed < self._curMaxSpeed then
    self.LineSpeed = self.LineSpeed + self.DashAcc * deltaTime
    if self.LineSpeed > self._curMaxSpeed then
      self.LineSpeed = self._curMaxSpeed
    end
  else
    self.LineSpeed = self.LineSpeed - self.DashDeAcc * deltaTime
    if hasInput and self.LineSpeed < self._curMaxSpeed then
      self.LineSpeed = self._curMaxSpeed
    end
    if not hasInput and self.LineSpeed <= self.HoldDashMinSpeed then
      self:StopActiveSKill()
      return
    end
  end
  local OldVelocity = self.moveComp.Velocity
  local NewVelocity = UE.UKismetMathLibrary.Normal(OldVelocity) * self.LineSpeed
  local Delta = UE.UKismetMathLibrary.Subtract_VectorVector(NewVelocity, OldVelocity)
  Delta.Z = 0
  self.WalkComp.OverrideMaxSpeed = self._curMaxSpeed
  if self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_GROUND then
    self.moveComp:ApplyVelocity(UE.EApplyMovementStatType.ImpulseAdditive, Delta)
  end
  local shouldPlayFx = self.LineSpeed > self._oldBaseMaxSpeed
  if self._isPlayingDashFX ~= shouldPlayFx then
    self:StartOrStopDashFx(shouldPlayFx)
    if shouldPlayFx then
      self:OnRefreshRideallAbilityPlayerStatus(DashStage.PlayDashFx)
    else
      self:OnRefreshRideallAbilityPlayerStatus(DashStage.StopDashFx)
    end
    self._isPlayingDashFX = shouldPlayFx
  end
end

function RideAllBuff_Dash:CanDash()
  if self.RideComp.RideMoveType ~= ProtoEnum.SceneRideAllType.SRAT_GROUND and self.RideComp.RideMoveComp.MovementMode ~= UE.EMovementMode.MOVE_Falling then
    return false
  end
  return true
end

function RideAllBuff_Dash:HandleRePress()
  if not self:HasInput() then
    return true
  end
  if self._curTime < self.ReStartMinTime then
    return true
  end
  self.cachedReStartVitality = self.owner.vitalityComponent:GetCurVitality()
  self.owner:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY, self.SkillId, self, self.OnReStartFinish)
  return true
end

function RideAllBuff_Dash:OnBuffFinish(param)
  Log.Debug("Dash End!")
  self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
  self:StartOrStopDashFx(false)
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, self._abilityID)
  self.WalkComp.LinerAngularSpeedCurve = self._oldAngularCurve
  self.WalkComp.AccelerateCurve = self._oldAccelerateCurve
  self.WalkComp.DeAccelerateCurve = self._oldDeAccelerateCurve
  self.WalkComp.BrakingFriction = self._oldBrakingFriction
  self.WalkComp.BrakingDecelerationWalking = self._oldBrakingDecelerationWalking
  self.WalkComp.GroundFriction = self._oldGroundFriction
  self.WalkComp.MaxSpeedDeAcceleration = self._oldMaxSpeedDeacc
  self.WalkComp.OverrideMaxSpeed = 0
  Base.OnBuffFinish(self, param)
end

function RideAllBuff_Dash:SimCurve(time)
  local BaseMax = 2200
  local BasMin = 200
  local StartDe = 4.5
  local EndDe = 5
  if time < StartDe then
    return BaseMax
  end
  if time >= StartDe then
    return BasMin + (EndDe - time) * (BaseMax - BasMin) / (EndDe - StartDe)
  end
end

function RideAllBuff_Dash:StopActiveSKill()
  self.NormalEnd = true
  Base.StopActiveSKill(self)
end

function RideAllBuff_Dash:OnRidePetChangeMoveType()
  if self:CanDash() then
    return
  end
  self:StopActiveSKill()
end

function RideAllBuff_Dash:StartOrStopDashFx(bStart)
  if not UE.UObject.IsValid(self.RidePet) then
    Log.Warning("RideAllBuff_Dash:StartOrStopDashFx No RidePet")
    if not bStart and self.DashFxs then
      for i, fx in ipairs(self.DashFxs:ToTable()) do
        fx:K2_DestroyActor()
      end
    end
    return
  end
  local Comp = self.RidePet.RocoMoveFx
  if bStart then
    if not self.DashFxs then
      self.DashFxs = UE4.TArray(UE4.AActor)
      Comp:LuaPlayMoveFxByStatus("Ground_Spurt", self.DashFxs)
    end
  elseif self.DashFxs then
    for i, fx in ipairs(self.DashFxs:ToTable()) do
      Comp:LuaStopMoveFx(fx, 0.5)
    end
    self.DashFxs:Clear()
    self.DashFxs = nil
  end
end

return RideAllBuff_Dash
