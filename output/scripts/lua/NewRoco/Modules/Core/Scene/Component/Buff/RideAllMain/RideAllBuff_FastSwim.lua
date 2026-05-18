local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RideAllBuff_FastSwim = Base:Extend("RideAllBuff_FastSwim")
local FastSwimStage = {PreStart = 1, StartDashFx = 2}

function RideAllBuff_FastSwim:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  self.MoveComp = self.RidePet.CharacterSwimMovement
  self.NormalEnd = false
  self:AnalyPropertyModify(SkillConf)
  if self:HasInput() then
    self:StartCostVitality()
  else
    self:StartFail()
  end
end

function RideAllBuff_FastSwim:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  if UE.UObject.IsValid(self.RidePet) then
    if not self.OnRemoteRidePetChangeMoveType then
      function self.OnRemoteRidePetChangeMoveType()
        self:CheckDashFx()
      end
    end
    self.RidePet.MovementModeChangedDelegate:Add(self.RidePet, self.OnRemoteRidePetChangeMoveType)
  end
end

function RideAllBuff_FastSwim:OnRemotePlayEffect(stage)
  if stage == FastSwimStage.StartDashFx and UE.UObject.IsValid(self.RidePet) then
    local FxPlayer = self.RidePet.RocoMoveFx.CurrentPlayer
    if FxPlayer and FxPlayer.StartDashFx then
      FxPlayer:StartDashFx(true)
    end
  end
end

function RideAllBuff_FastSwim:OnRemotePlayerBuffFinish(param)
  Base.OnRemotePlayerBuffFinish(self, param)
  if UE.UObject.IsValid(self.RidePet) then
    local FxPlayer = self.RidePet.RocoMoveFx.CurrentPlayer
    if FxPlayer and FxPlayer.StopDashFx then
      FxPlayer:StopDashFx(false)
    end
  end
  if UE.UObject.IsValid(self.RidePet) then
    self.RidePet.MovementModeChangedDelegate:Remove(self.RidePet, self.OnRemoteRidePetChangeMoveType)
  end
end

function RideAllBuff_FastSwim:OnPlayerStatusRefresh(status, value, opCode)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY then
    local customParams = self.owner.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY)
    self:OnRemotePlayEffect(customParams.ride_skill_param.skill_stage)
  end
end

function RideAllBuff_FastSwim:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    Log.Debug("FastSwim Start!")
    local moveParam1 = tonumber(self.SkillConf.move_param_1)
    if self.propertyModify[1] then
      if 0 == self.modifyMode then
        moveParam1 = moveParam1 + self.modifyValue
      elseif 1 == self.modifyMode then
        moveParam1 = moveParam1 + moveParam1 * self.modifyValue / 10000
      end
    end
    self.MoveComp.OverrideMaxSpeed = moveParam1 * self.MoveComp.BaseMaxSpeed
    local finalSpeed = moveParam1 * self.MoveComp.BaseMaxSpeed
    local maxDashSpeed = tonumber(self.SkillConf.move_param_2)
    if maxDashSpeed and maxDashSpeed > 0 and finalSpeed > maxDashSpeed then
      finalSpeed = maxDashSpeed
      Log.Debug("FastSwim speed clamped to max: " .. maxDashSpeed)
    end
    self.MoveComp.OverrideMaxSpeed = finalSpeed
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID)
    local FxPlayer = self.RidePet.RocoMoveFx.CurrentPlayer
    if FxPlayer and FxPlayer.StartDashFx then
      FxPlayer:StartDashFx(false)
    end
    self:OnRefreshRideallAbilityPlayerStatus(FastSwimStage.StartDashFx)
  else
    self:StartFail()
  end
end

function RideAllBuff_FastSwim:OnBuffUpdate(deltaTime)
  if _G.AppMain and _G.AppMain.isEnterBackground then
    self:StopActiveSKill()
    return
  end
  if not self:CanSwim() or not self:HasInput() then
    self:StopActiveSKill()
    return
  end
end

function RideAllBuff_FastSwim:CanSwim()
  return self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_SWIM or self.RideComp.RideMoveComp.MovementMode == UE.EMovementMode.MOVE_Falling
end

function RideAllBuff_FastSwim:OnBuffFinish(param)
  Log.Debug("FastSwim End!")
  Base.OnBuffFinish(self, param)
  local stopFxImmediate = not self.NormalEnd
  local FxPlayer = self.RidePet.RocoMoveFx.CurrentPlayer
  if FxPlayer and FxPlayer.StopDashFx then
    FxPlayer:StopDashFx(stopFxImmediate)
  end
  self.MoveComp.OverrideMaxSpeed = 0
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, self._abilityID)
end

function RideAllBuff_FastSwim:StopActiveSKill()
  self.NormalEnd = true
  Base.StopActiveSKill(self)
end

function RideAllBuff_FastSwim:OnRidePetChangeMoveType()
  if self:CanSwim() then
    self:CheckDashFx()
    return
  end
  self:StopActiveSKill()
end

function RideAllBuff_FastSwim:CheckDashFx()
  local customParams = self.owner.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY)
  local bStart = customParams and customParams.ride_skill_param.skill_stage == FastSwimStage.StartDashFx
  local FxPlayer = UE.UObject.IsValid(self.RidePet) and self.RidePet.RocoMoveFx.CurrentPlayer
  if FxPlayer then
    if bStart then
      if FxPlayer.StartDashFx then
        FxPlayer:StartDashFx(false)
      end
    elseif FxPlayer.StopDashFx then
      FxPlayer:StopDashFx(true)
    end
  end
end

return RideAllBuff_FastSwim
