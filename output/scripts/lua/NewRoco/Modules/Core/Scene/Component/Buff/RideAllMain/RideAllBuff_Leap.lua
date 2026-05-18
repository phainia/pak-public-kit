local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RideAllBuff_Leap = Base:Extend("RideAllBuff_Leap")

function RideAllBuff_Leap:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf, false)
  self:AnalyPropertyModify(SkillConf)
  self.curSkillStage = 1
  self.RidePet.InLeap = true
  self.secondStageSkillProtectTime = tonumber(SkillConf.move_param_1)
  self._curRunTime = 0
  self.inWindVolume = false
  self.firstSkillStageAngle = tonumber(SkillConf.move_param_2) / 180 * math.pi
  self.firstSkillStageSpeed = tonumber(SkillConf.move_param_3)
  if self.propertyModify[3] then
    if 0 == self.modifyMode then
      self.firstSkillStageSpeed = self.firstSkillStageSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.firstSkillStageSpeed = self.firstSkillStageSpeed + self.firstSkillStageSpeed * self.modifyValue / 10000
    end
  end
  self.secondSkillStageMaxAngle = tonumber(SkillConf.move_param_4)
  self.secondSkillStageSpeed = tonumber(SkillConf.move_param_5)
  if self.propertyModify[5] then
    if 0 == self.modifyMode then
      self.secondSkillStageSpeed = self.secondSkillStageSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.secondSkillStageSpeed = self.secondSkillStageSpeed + self.secondSkillStageSpeed * self.modifyValue / 10000
    end
  end
  self.maxSpeed = tonumber(SkillConf.move_param_6)
  if self.propertyModify[6] then
    if 0 == self.modifyMode then
      self.maxSpeed = self.maxSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.maxSpeed = self.maxSpeed + self.maxSpeed * self.modifyValue / 10000
    end
  end
  self.maxUpSpeed = tonumber(SkillConf.move_param_7)
  if self.propertyModify[7] then
    if 0 == self.modifyMode then
      self.maxUpSpeed = self.maxUpSpeed + self.modifyValue
    elseif 1 == self.modifyMode then
      self.maxUpSpeed = self.maxUpSpeed + self.maxUpSpeed * self.modifyValue / 10000
    end
  end
  self.gravityRatio = tonumber(SkillConf.move_param_8)
  self._oldGravityScale = tonumber(self.RidePet.CharacterMovement:GetMovementParamByName(3, "GravityScale"))
  self._oldMaxSpeed = tonumber(self.RidePet.CharacterMovement:GetMovementParamByName(3, "OverrideMaxSpeed"))
  self._oldMaxUpSpeed = tonumber(self.RidePet.CharacterMovement:GetMovementParamByName(3, "OverrideMaxUpSpeed"))
  self._oldMaxJumpApexAttemptsPerSimulation = tonumber(self.RidePet.CharacterMovement:GetMovementParamByName(3, "MaxJumpApexAttemptsPerSimulation"))
  self.owner.inputComponent:SetMoveEnable(self, false)
  self:StartCostVitality()
end

function RideAllBuff_Leap:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    self.RidePet.RocoAudio:PlayAudioToSelf(3530061)
    self.RidePet.RocoAudio:PlayAudioToSelf(3530062)
    local vectorData = self.RidePet:GetActorForwardVector()
    vectorData.Z = 0
    vectorData:Normalize()
    vectorData.X = vectorData.X * math.cos(self.firstSkillStageAngle)
    vectorData.Y = vectorData.Y * math.cos(self.firstSkillStageAngle)
    vectorData.Z = math.sin(self.firstSkillStageAngle)
    self.RidePet.CharacterMovement:ApplyVelocity(UE.EApplyMovementStatType.ImpulseAdditive, UE.UKismetMathLibrary.Multiply_VectorFloat(vectorData, self.firstSkillStageSpeed))
    self.RidePet.CharacterMovement:SetMovementMode(3)
    self.leapTrailFxID = self.RidePet.RocoFX:PlayFx_Type_Setting2(self.RidePet.LeapTrailFX, UE4.EFXAttachPointType.Pos, true, UE4.FTransform(), true)
    self.RideComp:ChangeMoveType(0, 0)
    self.RidePet.CharacterMovement:SetMovementParamByName(3, "GravityScale", tostring(self._oldGravityScale * self.gravityRatio))
    self.RidePet.CharacterMovement:SetMovementParamByName(3, "OverrideMaxSpeed", tostring(self.maxSpeed))
    self.RidePet.CharacterMovement:SetMovementParamByName(3, "OverrideMaxUpSpeed", tostring(self.maxUpSpeed))
    self.RidePet.CharacterMovement:SetMovementParamByName(3, "MaxJumpApexAttemptsPerSimulation", tostring(-1))
    self:OnRefreshRideallAbilityPlayerStatus(0)
  else
    self:StartFail()
  end
end

function RideAllBuff_Leap:OnBuffUpdate(deltaTime)
  self._curRunTime = self._curRunTime + deltaTime
  if self.RidePet.BP_WindResponseComponent then
    if self.inWindVolume and self.RidePet.BP_WindResponseComponent.WindVolumeCount <= 0 then
      self.RidePet.CharacterMovement:SetMovementParamByName(3, "GravityScale", tostring(self._oldGravityScale * self.gravityRatio))
      self.inWindVolume = false
    elseif not self.inWindVolume and self.RidePet.BP_WindResponseComponent.WindVolumeCount > 0 then
      self.RidePet.CharacterMovement:SetMovementParamByName(3, "GravityScale", tostring(self._oldGravityScale))
      self.inWindVolume = true
    end
  end
end

function RideAllBuff_Leap:OnRidePetChangeMoveType()
  if self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_FLY or 0 == self.RideComp.RideMoveType and self.RideComp.RideMoveComp.MovementMode == UE.EMovementMode.MOVE_Falling then
    return
  end
  if self.RideComp.RideMoveType == ProtoEnum.SceneRideAllType.SRAT_GROUND then
    self.RidePet.RocoAudio:PlayAudioToSelf(1220003274)
  end
  self:StopActiveSKill()
end

function RideAllBuff_Leap:VitalityNotEnoughCanPlay()
  return 1 == self.curSkillStage
end

function RideAllBuff_Leap:CanHandleRePress()
  if 2 == self.curSkillStage then
    return false
  end
  return true
end

function RideAllBuff_Leap:HandleRePress()
  if 2 == self.curSkillStage then
    return true
  end
  if self._curRunTime < self.secondStageSkillProtectTime then
    return true
  end
  self:OnStartSceondSkillStage(true)
  return true
end

function RideAllBuff_Leap:OnStartSceondSkillStage(StartCostSuccess)
  if StartCostSuccess then
    self.RidePet.BP_RidePetRoleHpComponent:IgnoreFallingDamage()
    self.curSkillStage = 2
    local cameraRotate = self.owner.viewObj.sceneCharacter:GetUEController().playerCameraManager:GetCameraRotation()
    if cameraRotate.Pitch == nil then
      Log.Error("cameraRotate.Pitch is nil")
      return
    end
    if nil == self.secondSkillStageMaxAngle then
      Log.Error("secondSkillStageMaxAngle is nil")
      return
    end
    if cameraRotate.Pitch > 90 or cameraRotate.Pitch < self.secondSkillStageMaxAngle then
    else
      cameraRotate.Pitch = self.secondSkillStageMaxAngle
    end
    local cameraForwardVector = cameraRotate:GetForwardVector()
    cameraForwardVector:Normalize()
    local OldVelocity = self.RidePet.CharacterMovement.Velocity
    local NewVelocity = UE.UKismetMathLibrary.Multiply_VectorFloat(cameraForwardVector, self.secondSkillStageSpeed)
    local Delta = UE.UKismetMathLibrary.Subtract_VectorVector(NewVelocity, OldVelocity)
    self.RidePet.CharacterMovement:ApplyVelocity(UE.EApplyMovementStatType.ImpulseAdditive, Delta)
  end
end

function RideAllBuff_Leap:OnRemotePlayerBuffBegin(Owner, SkillConf)
  Base.OnRemotePlayerBuffBegin(self, Owner, SkillConf, false)
  self.RidePet.RocoAudio:PlayAudioToSelf(3530061)
  self.RidePet.RocoAudio:PlayAudioToSelf(3530062)
end

function RideAllBuff_Leap:OnRemotePlayEffect(stage, target_pos)
  if UE.UObject.IsValid(self.RidePet) and UE.UObject.IsValid(self.RidePet.RocoFX) then
    self.leapTrailFxID = self.RidePet.RocoFX:PlayFx_Type_Setting2(self.RidePet.LeapTrailFX, UE4.EFXAttachPointType.Pos, true, UE4.FTransform(), true)
  end
end

function RideAllBuff_Leap:OnRemotePlayerBuffFinish(param)
  Base.OnRemotePlayerBuffFinish(self, param)
  if UE.UObject.IsValid(self.RidePet) then
    if self.leapTrailFxID then
      self.RidePet.RocoFX:StopFx(self.leapTrailFxID)
    end
    self.RidePet.RocoAudio:StopAudioToSelf(3530062, 0.2)
  end
end

function RideAllBuff_Leap:OnPlayerStatusRefresh(status, value, opCode)
  if status == ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY then
    local customParams = self.owner.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL_ABILITY)
    self:OnRemotePlayEffect(customParams.ride_skill_param.skill_stage, customParams.ride_skill_param.target_pos)
  end
end

function RideAllBuff_Leap:OnBuffFinish(param)
  Log.Debug("RideAllBuff_Leap End!")
  if self.leapTrailFxID then
    self.RidePet.RocoFX:StopFx(self.leapTrailFxID)
  end
  self.RidePet.RocoAudio:StopAudioToSelf(3530062, 0.2)
  self.owner.inputComponent:SetMoveEnable(self, true)
  self.curSkillStage = 1
  self.inWindVolume = false
  self.RidePet.CharacterMovement:SetMovementParamByName(3, "GravityScale", tostring(self._oldGravityScale))
  self.RidePet.CharacterMovement:SetMovementParamByName(3, "OverrideMaxSpeed", tostring(self._oldMaxSpeed))
  self.RidePet.CharacterMovement:SetMovementParamByName(3, "OverrideMaxUpSpeed", tostring(self._oldMaxUpSpeed))
  self.RidePet.CharacterMovement:SetMovementParamByName(3, "MaxJumpApexAttemptsPerSimulation", tostring(self._oldMaxJumpApexAttemptsPerSimulation))
  Base.OnBuffFinish(self, param)
end

return RideAllBuff_Leap
