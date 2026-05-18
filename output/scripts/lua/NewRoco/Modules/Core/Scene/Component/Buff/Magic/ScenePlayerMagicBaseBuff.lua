local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local ScenePlayerMagicBaseBuff = Base:Extend("ScenePlayerMagicBaseBuff")

function ScenePlayerMagicBaseBuff:NewMagicBuffInfo()
  return {
    abilityHelper = nil,
    customMagicInfo = nil,
    skillTypedConfig = {limit_pitch = false, limit_yaw = false},
    magicBaseConfig = nil,
    maxSpeedCurve = nil,
    fastThrowAngleOffset = nil,
    throwSpeedOffset = nil,
    throwStrength = nil,
    mozhangBP = nil
  }
end

function ScenePlayerMagicBaseBuff:Ctor(owner, ...)
  Base.Ctor(self, owner)
  self.LocalMode = false
end

function ScenePlayerMagicBaseBuff:OnBegin(owner, MagicInfo, ...)
  self.magicInfo = MagicInfo
  self.inAimState = false
  self.chargedLevel = 0
  self.chargedTime = 0
  self.currentLevelProcess = 0
  self.longPressTime = 0
  self.waitCasting = false
  self.SyncCastSuccess = false
  if not self.owner.isLocal then
    self.owner.viewObj.AimRotation = self.owner.viewObj:K2_GetActorRotation()
    self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
    return
  end
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_RETURN_MAGIC_COST, self.OnReturnMagicCost)
  self.owner:SendEvent(PlayerModuleEvent.ON_INIT_MAGIC_COST, self)
  self.ChargedSuccess = false
  self.ChargedEnd = false
  self.lazySyncTime = _G.DataConfigManager:GetGlobalConfigNumByKeyType("lazy_move_sync_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 100)
  self:UpdateDirection()
  self.owner.viewObj.BP_ALSComponent:SetAimThrowState(true, not self.inAimState, self.FaceDirection, true)
  _G.NRCAudioManager:PlaySound2DAuto(40008023, "MagicInAim")
  self:ClampViewYaw()
  self.owner:SetActorRotation(UE4.FRotator(0, self:GetController():GetControlRotation().Yaw, 0))
  self:ClampViewPitch()
  self._beginRotation = self:GetController():GetControlRotation()
  if self.magicInfo.magicBaseConfig then
    self.chargedCost = self.magicInfo.magicBaseConfig.charge_time
  end
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.owner.movementComponent:SetIsMoving(true, "Aim")
end

function ScenePlayerMagicBaseBuff:OnStatusRefresh(status, subStatus, opCode, params)
  if status ~= ProtoEnum.WorldPlayerStatusType.WPST_MAGIC then
    return
  end
  local ActionType = params.throw_aim_param.aim_type
  if ActionType == ProtoEnum.AimSyncType.AST_END_THROW then
    self:SyncCastMagic(params.throw_aim_param.is_throw_success, params.throw_aim_param.throw_velocity, params.throw_aim_param.throw_start_pos)
  end
  if ActionType == ProtoEnum.AimSyncType.AST_MODE_CHANGE then
    self:OnCharged(params.throw_aim_param.charged_level)
  end
end

function ScenePlayerMagicBaseBuff:OnUpdate(deltaTime)
  if not self.owner.isLocal then
    local ctrlRotation = self.owner.movementComponent.ctrlRot
    ctrlRotation = ctrlRotation or self.owner.viewObj:K2_GetActorRotation()
    self.owner.viewObj.AimRotation = ctrlRotation
    return
  end
  self:ClampViewYaw()
  if self.ChargedSuccess and not self.ChargedEnd and not self.waitCasting then
    self.chargedTime = self.chargedTime + deltaTime * 1000
    if #self.chargedCost >= self.chargedLevel + 1 and self.chargedTime > self.chargedCost[self.chargedLevel + 1] then
      self.chargedLevel = self.chargedLevel + 1
      self.chargedTime = self.chargedTime - self.chargedCost[self.chargedLevel]
      self:OnCharged(self.chargedLevel)
    end
    if self.chargedLevel < #self.chargedCost then
      self.currentLevelProcess = self.chargedTime / self.chargedCost[self.chargedLevel + 1]
    else
      self.currentLevelProcess = 1
    end
  end
  if self.waitCasting or self.chargedLevel >= #self.chargedCost then
    self.ChargedEnd = true
  end
  if self.inAimState == false and not self.waitCasting then
    self.longPressTime = self.longPressTime - deltaTime
    if self.longPressTime <= 0 then
      self:SwitchAimState(true)
    end
  end
  self:TrySnycRotation()
end

function ScenePlayerMagicBaseBuff:TrySnycRotation()
  if NRCEnv:IsLocalMode() then
    return
  end
end

function ScenePlayerMagicBaseBuff:OnCharged(newChargedLevel)
end

function ScenePlayerMagicBaseBuff:OnFinish(param)
  if not self.owner.isLocal then
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
    if self.magicInfo.mozhangBP then
      self.magicInfo.mozhangBP:ClearFX()
      self.magicInfo.mozhangBP:OnDisappear()
    end
    self.magicInfo = nil
    self.owner = nil
    return
  end
  NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, false)
  self.owner:SendEvent(PlayerModuleEvent.ON_INIT_MAGIC_COST, nil)
  if not self.is_magic_cancel then
    self:RecoverView()
    self.owner.viewObj.BP_ALSComponent:SetAimThrowState(false, nil, nil, false)
    self:GetController().PlayerCameraManager.bOverRotator = false
    self:GetController():ChangeThrowAimStat(false)
  end
  local statComponent = self.owner.statComponent
  if self.magicInfo.maxSpeedCurve and nil ~= self._statMaxSpeedCurveID then
    local characterMovement = self.owner.viewObj.CharacterMovement
    statComponent:RemoveStat(StatType.MAX_WALK_SPEED_CURVE, self._statMaxSpeedCurveID, characterMovement)
    self._statMaxSpeedCurveID = nil
  end
  if self.magicInfo.mozhangBP then
    self.magicInfo.mozhangBP:ClearFX()
    self.magicInfo.mozhangBP:OnDisappear()
  end
  local module = _G.NRCModuleManager:GetModule("MainUIModule")
  if module then
    module:DispatchEvent(MainUIModuleEvent.UI_SHOW_AIM_JOYSTICK, false)
  end
  self.owner.movementComponent:SetIsMoving(false, "Aim")
  self.magicInfo = nil
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_RETURN_MAGIC_COST, self.OnReturnMagicCost)
  self.owner = nil
end

function ScenePlayerMagicBaseBuff:OnRefresh()
end

function ScenePlayerMagicBaseBuff:SwitchAimState(state)
  self.inAimState = state
  if self.inAimState then
    self:UpdateDirection()
    self.owner.viewObj.BP_ALSComponent:SetAimThrowState(true, not self.inAimState, self.FaceDirection, true)
    self._beginRotation = self:GetController():GetControlRotation()
    self:GetController():ChangeThrowAimStat(true)
    self:ClampViewPitch()
    local statComponent = self.owner.statComponent
    if self.magicInfo.maxSpeedCurve then
      local characterMovement = self.owner.viewObj.CharacterMovement
      self._statMaxSpeedCurveID = statComponent:ApplyStat(StatType.MAX_WALK_SPEED_CURVE, self.magicInfo.maxSpeedCurve, nil, characterMovement)
    end
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_SHOW_AIM_JOYSTICK, true)
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_SHOW_AIM_JOYSTICK_CHECK, true)
  end
end

function ScenePlayerMagicBaseBuff:OnCastMagic(...)
  if self.waitCasting then
    return
  end
  Log.Debug("ScenePlayerMagicBaseBuff:OnCastMagic")
  if 0 == self.chargedLevel then
    self.owner:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, self.chargedTime)
  end
  self.waitCasting = true
  if self.magicInfo.abilityHelper then
    self:UpdateDirection()
    local Id = ProtoEnum.WorldPlayerStatusType.WPST_MAGIC
    local customParams = self.owner.statusComponent._statusParams[Id]
    customParams = customParams or ProtoMessage:newPlayerStatusCustomParams()
    customParams.throw_aim_param.aim_type = ProtoEnum.AimSyncType.AST_END_THROW
    customParams.throw_aim_param.is_throw_success = true
    customParams.throw_aim_param.throw_start_pos = SceneUtils.ClientPos2ServerPos(self:GetStartPos())
    customParams.throw_aim_param.throw_velocity = SceneUtils.ClientPos2ServerPos(self:CalculateVelocity())
    self.owner.statusComponent:RefreshStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, self.magicInfo.abilityHelper.config.add_status[1], ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, customParams)
    local statusComponent = self.owner.statusComponent
    for _, v in pairs(self.magicInfo.abilityHelper.config.add_status) do
      Log.DebugFormat("WindTest RemoveStatus %d SubStatus %d", v, self.magicInfo.abilityHelper.config.add_sub_status)
      statusComponent:RemoveStatus(v, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, self.magicInfo.abilityHelper.config.add_sub_status, true, ...)
    end
  end
end

function ScenePlayerMagicBaseBuff:ClampViewPitch()
  if self.magicInfo.skillTypedConfig.limit_pitch then
    self:GetController().PlayerCameraManager.ViewPitchMin = self.magicInfo.skillTypedConfig.pitch_min
    self:GetController().PlayerCameraManager.ViewPitchMax = self.magicInfo.skillTypedConfig.pitch_max
  end
end

function ScenePlayerMagicBaseBuff:ClampViewYaw()
  if self.magicInfo.skillTypedConfig.limit_yaw and GlobalConfig.YawLimit.UseLimit then
    self:GetController().PlayerCameraManager.bOverRotator = true
    local YawMin = self.magicInfo.skillTypedConfig.yaw_min
    local YawMax = self.magicInfo.skillTypedConfig.yaw_max
    if GlobalConfig.YawLimit.UseLimit then
      YawMin = GlobalConfig.YawLimit.yaw_min or self.magicInfo.skillTypedConfig.yaw_min
      YawMax = GlobalConfig.YawLimit.yaw_max or self.magicInfo.skillTypedConfig.yaw_max
    end
    local PetRotation
    if self.owner.viewObj.RidePet then
      PetRotation = self.owner.viewObj.RidePet:K2_GetActorRotation()
    else
      PetRotation = self._beginRotation
    end
    self:GetController().PlayerCameraManager.ViewYawMin = PetRotation.Yaw + YawMin
    self:GetController().PlayerCameraManager.ViewYawMax = PetRotation.Yaw + YawMax
  end
end

function ScenePlayerMagicBaseBuff:RecoverView()
  if self.magicInfo.skillTypedConfig.limit_pitch then
    self:GetController().PlayerCameraManager.ViewPitchMin = -89.9
    self:GetController().PlayerCameraManager.ViewPitchMax = 89.9
  end
  if self.magicInfo.skillTypedConfig.limit_yaw then
    self:GetController().PlayerCameraManager.ViewYawMin = 0
    self:GetController().PlayerCameraManager.ViewYawMax = 359.999
  end
end

function ScenePlayerMagicBaseBuff:UpdateDirection()
  if self.owner and self.owner.viewObj and self.owner.isLocal then
    local cameraRoatation = self:GetController().PlayerCameraManager:GetCameraRotation()
    self.Direction = UE4.UKismetMathLibrary.GetForwardVector(cameraRoatation)
    self.FaceDirection = self.Direction
    if self.inAimState then
      self.AngleOffset = -5
    else
      local pitch = self:GetThrowAngle()
      self.AngleOffset = -5
      if self.magicInfo.fastThrowAngleOffset then
        self.AngleOffset = self.magicInfo.fastThrowAngleOffset:GetFloatValue(pitch)
      end
    end
  end
end

function ScenePlayerMagicBaseBuff:GetController()
  local ctrl = self.owner:GetUEController()
  if nil == ctrl then
    ctrl = UE4.UGameplayStatics.GetPlayerControllerFromID(self.owner.viewObj, 0)
  end
  return ctrl
end

function ScenePlayerMagicBaseBuff:GetThrowAngle()
  local pitch = self:GetController().PlayerCameraManager:GetCameraRotation().Pitch
  if pitch > 180 then
    pitch = pitch - 360
  end
  return pitch
end

function ScenePlayerMagicBaseBuff:GetStartPos()
  if not self.owner.isLocal then
    if self.SyncCastStartPos then
      return self.SyncCastStartPos
    end
    local handLocation = self.owner.viewObj.Mesh:Abs_GetSocketLocation("locator_right_hand")
    local forward = self.owner.viewObj:GetActorForwardVector()
    return handLocation + forward * UE.FVector(30, 0, 0)
  end
  local PlayerCameraManager = self:GetController().PlayerCameraManager
  local cameraLocation = PlayerCameraManager:Abs_GetCameraLocation()
  local playerlocation = self.owner.viewObj:Abs_K2_GetActorLocation()
  local Distence = UE4.UKismetMathLibrary.Vector_Distance(playerlocation, cameraLocation)
  Distence = Distence + 50
  local cameraForward = UE4.UKismetMathLibrary.GetForwardVector(PlayerCameraManager:GetCameraRotation())
  local CameraDelta = UE4.UKismetMathLibrary.Multiply_VectorFloat(cameraForward, Distence)
  return UE4.UKismetMathLibrary.Add_VectorVector(CameraDelta, cameraLocation)
end

function ScenePlayerMagicBaseBuff:CalculateVelocity()
  if not self.owner.isLocal then
    return self.SyncCastVelocity
  end
  self.Strength = self.magicInfo.throwStrength or 2400
  local PlayerCameraManager = self:GetController().PlayerCameraManager
  local RightVector = PlayerCameraManager:GetCameraRotation():GetRightVector()
  local Direction = UE4.UKismetMathLibrary.RotateAngleAxis(self.Direction, self.AngleOffset, RightVector)
  local pitch = self:GetThrowAngle()
  local offsetPitch = pitch + self.AngleOffset
  local strengthOffset = 1
  if self.magicInfo.throwSpeedOffset then
    strengthOffset = self.magicInfo.throwSpeedOffset:GetFloatValue(offsetPitch)
  end
  return Direction * self.Strength * strengthOffset
end

function ScenePlayerMagicBaseBuff:SyncCastMagic(Success, Velocity, StartPos)
  self.SyncCastSuccess = Success
  if nil ~= Velocity then
    self.SyncCastVelocity = UE.FVector(Velocity.x, Velocity.y, Velocity.z)
  end
  if nil ~= StartPos then
    self.SyncCastStartPos = UE.FVector(StartPos.x, StartPos.y, StartPos.z)
  end
end

function ScenePlayerMagicBaseBuff:OnStatusChanged(status, value, opCode)
end

function ScenePlayerMagicBaseBuff:OnReturnMagicCost()
  self.is_magic_cancel = true
  local Id = ProtoEnum.WorldPlayerStatusType.WPST_MAGIC
  local customParams = self.owner.statusComponent._statusParams[Id]
  customParams = customParams or ProtoMessage:newPlayerStatusCustomParams()
  customParams.throw_aim_param.is_magic_cancel = true
  self.owner.statusComponent:RefreshStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC, self.magicInfo.abilityHelper.config.add_status[1], ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, customParams)
end

return ScenePlayerMagicBaseBuff
