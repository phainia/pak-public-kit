local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RideAllBuff_Fly = Base:Extend("RideAllBuff_Fly")

function RideAllBuff_Fly:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf)
  self:AnalyPropertyModify(SkillConf)
  self.FlyComp = self.RidePet.CharacterFlyMovement
  self._holdTime = 0
  self._curTime = 0
  self._inLoop = false
  self._oldAngularSpeedLossRatioCurve = self.FlyComp.AngularSpeedLossRatioCurve
  self._oldLinerAngularSpeedCurve = self.FlyComp.LinerAngularSpeedCurve
  self._oldAcc = self.FlyComp.MaxAcceleration
  self._oldGravity = self.FlyComp.GravityRatio
  self._oldGlidingBreakingAcceleration = self.FlyComp.GlidingBreakingAcceleration
  self._oldGlidingFriction = self.FlyComp.GlidingFriction
  if SkillConf.move_param_3 then
    self.FlyComp.AngularSpeedLossRatioCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_3)
  end
  if SkillConf.move_param_4 then
    self.FlyComp.LinerAngularSpeedCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_4)
  end
  self.FlyComp.MaxAcceleration = SkillConf.move_param_1
  local OverrideMaxSpeed = tonumber(SkillConf.move_param_2)
  if self.propertyModify[2] then
    if 0 == self.modifyMode then
      self.FlyComp.OverrideMaxSpeed = OverrideMaxSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.FlyComp.OverrideMaxSpeed = OverrideMaxSpeed * (1 + self.modifyValue / 10000)
    else
      self.FlyComp.OverrideMaxSpeed = OverrideMaxSpeed
    end
  else
    self.FlyComp.OverrideMaxSpeed = OverrideMaxSpeed
  end
  self.FlyComp.GravityRatio = SkillConf.move_param_5
  self.FlyComp.GravityRatio = self.FlyComp.GravityRatio * -1
  self.FlyComp.GlidingBreakingAcceleration = SkillConf.move_param_7
  self.FlyComp.GlidingFriction = SkillConf.move_param_8
  self._endTime = tonumber(SkillConf.move_param_11)
  self.MaxSpeedCurve = _G.PlayerResourceManager:GetStaticResource(SkillConf.move_param_6)
  local _min
  _min, self._endTime = self.MaxSpeedCurve:GetTimeRange()
  local initValue = self.MaxSpeedCurve:GetFloatValue(self._curTime)
  local SkillFlyUpSpeed = self.owner.statComponent:GetValue(StatType.SKILL_FLY_UP_SPEED)
  if self.propertyModify[6] then
    if 0 == self.modifyMode then
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + initValue * self.modifyValue / 10000
    else
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
    end
  else
    self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
  end
  self._isJump = false
  self._isGroundMode = self.RideComp.RideMoveType ~= ProtoEnum.SceneRideAllType.SRAT_FLY
  local SendVitality = self.owner.vitalityComponent:GetVitalityCostRatio() * self.SkillConf.vitality_cost.start_cost
  if SendVitality > self.owner.vitalityComponent:GetCurVitality() then
    SendVitality = self.owner.vitalityComponent:GetCurVitality()
  end
  self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_INIT, SendVitality, self._endTime)
end

function RideAllBuff_Fly:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_BEGIN)
    if self._isGroundMode then
      local SkillConf = self.SkillConf
      self.RidePet.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Custom, UE.ERocoCustomMovementMode.MOVE_Gliding)
      self._isJump = true
    else
      if self.RidePet and self.RidePet.Mesh then
        self.RidePet.Mesh:GetAnimInstance().isFlyUp = true
      end
      Log.Debug("Fly Begin!")
    end
  else
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
    self:StartFail()
  end
end

function RideAllBuff_Fly:OnBuffUpdate(deltaTime)
  if not self:CanFly() then
    self:StopActiveSKill()
    return
  end
  self._curTime = (self._curTime or 0) + deltaTime
  if not self._inLoop and self._curTime > self._holdTime then
    self._inLoop = true
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID, self._endTime)
  end
  if self._curTime > self._endTime then
    self:StopActiveSKill()
    return
  end
  local initValue = self.MaxSpeedCurve:GetFloatValue(self._curTime)
  local SkillFlyUpSpeed = self.owner.statComponent:GetValue(StatType.SKILL_FLY_UP_SPEED)
  if self.propertyModify[6] then
    if 0 == self.modifyMode then
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + initValue * self.modifyValue / 10000
    else
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
    end
  else
    self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
  end
end

function RideAllBuff_Fly:OnRidePetChangeMoveType()
  if self._isJump then
    return
  end
  Base.OnRidePetChangeMoveType(self)
end

function RideAllBuff_Fly:OnBuffFinish(param)
  Log.Debug("Fly End!")
  self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
  if UE.UObject.IsValid(self.RidePet) and UE.UObject.IsValid(self.RidePet.Mesh) and UE.UObject.IsValid(self.RidePet.Mesh:GetAnimInstance()) then
    self.RidePet.Mesh:GetAnimInstance().isFlyUp = false
  end
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, self._abilityID)
  if UE.UObject.IsValid(self.FlyComp) then
    self.FlyComp.AngularSpeedLossRatioCurve = self._oldAngularSpeedLossRatioCurve
    self.FlyComp.LinerAngularSpeedCurve = self._oldLinerAngularSpeedCurve
    self.FlyComp.MaxAcceleration = self._oldAcc
    self.FlyComp.OverrideMaxSpeed = self._oldBaseMaxSpeed
    self.FlyComp.GravityRatio = self._oldGravity
    self.FlyComp.OverrideMaxUpSpeed = 0
    self.FlyComp.GlidingBreakingAcceleration = self._oldGlidingBreakingAcceleration
    self.FlyComp.GlidingFriction = self._oldGlidingFriction
  end
  Base.OnBuffFinish(self, param)
end

function RideAllBuff_Fly:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  self._isGroundMode = self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_GROUND
  if self.RidePet and self.RidePet.Mesh then
    self.RidePet.Mesh:GetAnimInstance().isFlyUp = true
  end
end

function RideAllBuff_Fly:OnRemotePlayerBuffFinish(param)
  Base.OnRemotePlayerBuffFinish(self, param)
  if UE.UObject.IsValid(self.RidePet) and UE.UObject.IsValid(self.RidePet.Mesh) and UE.UObject.IsValid(self.RidePet.Mesh:GetAnimInstance()) then
    self.RidePet.Mesh:GetAnimInstance().isFlyUp = false
  end
end

function RideAllBuff_Fly:CanFly()
  if self.RideComp and self.RideComp.RideMoveType ~= ProtoEnum.SceneRideAllType.SRAT_FLY then
    return false
  end
  return true
end

function RideAllBuff_Fly:HandleRePress()
  local requiredVitality = self.owner.vitalityComponent:GetVitalityCostRatio() * self.SkillConf.vitality_cost.start_cost
  local curVitality = self.owner.vitalityComponent:GetCurVitality()
  if requiredVitality > curVitality then
    return true
  end
  self._cachedReStartVitality = curVitality
  self.owner:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY, self.SkillId, self, self.OnReStartFinish)
  return true
end

function RideAllBuff_Fly:OnReStartFinish(StartCostSuccess)
  if StartCostSuccess then
    self._curTime = 0
    self._inLoop = false
    local initValue = self.MaxSpeedCurve:GetFloatValue(self._curTime)
    local SkillFlyUpSpeed = self.owner.statComponent:GetValue(StatType.SKILL_FLY_UP_SPEED)
    if self.propertyModify[6] then
      if 0 == self.modifyMode then
        self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + self.modifyValue
      elseif 1 == self.modifyMode then
        self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed + initValue * self.modifyValue / 10000
      else
        self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
      end
    else
      self.FlyComp.OverrideMaxUpSpeed = initValue * SkillFlyUpSpeed
    end
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID, self._endTime, true)
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_END)
    local SendVitality = self.owner.vitalityComponent:GetVitalityCostRatio() * self.SkillConf.vitality_cost.start_cost
    if self._cachedReStartVitality and SendVitality > self._cachedReStartVitality then
      SendVitality = self._cachedReStartVitality
    end
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_INIT, SendVitality, self._endTime)
    self.owner:SendEvent(PlayerModuleEvent.ON_PRE_VITALITY_COST_BEGIN)
    Log.Debug("Fly RePress - Restart flying!")
  end
end

return RideAllBuff_Fly
