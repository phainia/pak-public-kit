require("UnLuaEx")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local BP_MovePhysComponent_C = NRCClass()
local LocalUE4 = UE4
local LocalUE4Helper = UE4Helper
local linetraceDebugtype = UE4.EDrawDebugTrace.None

function BP_MovePhysComponent_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:Init()
end

function BP_MovePhysComponent_C:Init()
  self.pawn = self:GetScenePlayer()
  self.characterMovement = self.pawn:GetMovementComponent()
  self.state = ABEnum.AbilityState.PreCasting
  self._hitPositionNormal = self.characterMovement.CurrentFloor.HitResult.ImpactNormal
  self._slipDetectThreshold = LocalUE4.UKismetMathLibrary.Cos(self.SlipDetectThresholdAngle * math.pi / 180)
  self._slipThresholdUp = LocalUE4.UKismetMathLibrary.Cos(self.SlipThresholdAngleUp * math.pi / 180)
  self._slipThresholdDown = LocalUE4.UKismetMathLibrary.Cos(self.SlipThresholdAngleDown * math.pi / 180)
  self._slipStopAngle = LocalUE4.UKismetMathLibrary.Cos(self.SlipStopAngle * math.pi / 180)
  self._RWStopAngle = LocalUE4.UKismetMathLibrary.Cos(self.RWStopAngle * math.pi / 180)
  self:InitialParameters()
end

function BP_MovePhysComponent_C:InitialParameters()
  self._lerpAlpha = 0
  self.GroundFriction = 0
  self._gradientVector = LocalUE4.FVector(0, 0, 0)
  self._originSpeedVector = LocalUE4.FVector(0, 0, 0)
  self._currentSpeedVector = LocalUE4.FVector(0, 0, 0)
  self._bBeginDetectSlop = false
  self._bIsInStopSpeedPhase = false
  self._bIsInTurnPhase = false
  self._bIsInSlipPhase = false
  self._bIsInRunWallPhase = false
  self._initialRotation = LocalUE4.FRotator(0, 0, 0)
  self._initialGradientRotation = LocalUE4.FRotator(0, 0, 0)
  self._bIsPlayAnim = false
  self._bIsWaitingStopAnim = false
  self._lastAngle = 1
  self._curMoveDis = 0
  self.SlipeMontage = nil
  self._curStopSlipAnimTime = 0.0
  self.LastMovementState = 0
  self._RunWallInit = false
end

function BP_MovePhysComponent_C:GetScenePlayer()
  return self:GetOwner()
end

function BP_MovePhysComponent_C:StopSpeed(Speed, DeltaSeconds)
  if self._bIsInStopSpeedPhase then
    if self._lerpAlpha < 1 then
      self._lerpAlpha = self._lerpAlpha + Speed * DeltaSeconds * (1 - self._hitPositionNormal.Z) + DeltaSeconds * self.GroundFriction * self._hitPositionNormal.Z
      if self._lerpAlpha > 1 then
        self._lerpAlpha = 1
      end
      local vector = UE4.UKismetMathLibrary.VLerp(self._originSpeedVector, UE4.FVector(10, 10, 0), self._lerpAlpha)
      self.characterMovement.Velocity = vector
    else
      self._bIsInStopSpeedPhase = false
      self._lerpAlpha = 0
      self:SetGroundGradient()
      if self._hitPositionNormal.Z < self._slipThresholdUp then
        self:StartSlip()
        self._bIsInTurnPhase = true
        self._bIsInSlipPhase = true
      else
        self:WaitingAnimStop()
      end
    end
  end
end

function BP_MovePhysComponent_C:TurnBack(DeltaSeconds, Speed)
  if self._bIsInTurnPhase then
    if self._lerpAlpha <= 1 then
      self._lerpAlpha = self._lerpAlpha + Speed * DeltaSeconds
      local targetRotator
      if self._lerpAlpha > 1 then
        targetRotator = LocalUE4.UKismetMathLibrary.RLerp(self._initialRotation, self._initialGradientRotation, 1)
      else
        targetRotator = LocalUE4.UKismetMathLibrary.RLerp(self._initialRotation, self._initialGradientRotation, self._lerpAlpha)
      end
      self:SafeSetRotation(targetRotator)
    else
      self._bIsInTurnPhase = false
      self._lerpAlpha = 0
    end
  end
end

function BP_MovePhysComponent_C:StartSlip()
  self:PlaySlipAnimition()
  self._curMoveDis = 0
end

function BP_MovePhysComponent_C:SlipToGround(DeltaSeconds)
  local detaVelocity = 0
  local upDown
  if self.characterMovement.CurrentFloor.bBlockingHit == true then
    upDown = UE4.UKismetMathLibrary.Dot_VectorVector(self._gradientVector, self._hitPositionNormal)
    if upDown >= 0 then
      detaVelocity = DeltaSeconds * self.AccelerateSlipFactor * (math.sqrt(math.max(0, 1 - self._hitPositionNormal.Z ^ 2)) - self.GroundFriction * self._hitPositionNormal.Z)
    else
      detaVelocity = -1 * DeltaSeconds * self.AccelerateSlipFactor * (math.sqrt(math.max(0, 1 - self._hitPositionNormal.Z ^ 2)) + self.GroundFriction * self._hitPositionNormal.Z)
    end
  else
    self:Finish()
    return
  end
  if UE4.UKismetMathLibrary.Vector_IsZero(self._gradientVector) then
    self:WaitingAnimStop()
  end
  self:ChangeVelocity(detaVelocity)
  self:StickToTheGround()
  local speed = UE4.UKismetMathLibrary.Dot_VectorVector(self._currentSpeedVector, self._gradientVector)
  if UE4.UKismetMathLibrary.Dot_VectorVector(self._gradientVector, UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)) < 0 and speed <= 0 then
    self:WaitingAnimStop()
    return
  end
  self._curMoveDis = self._curMoveDis + speed * DeltaSeconds
  if self._curMoveDis < self.StopSlipeDistance then
    if upDown >= 0 and detaVelocity < 0 and speed <= 0 then
      self:WaitingAnimStop()
    end
    return
  end
  if 1 == self._lastAngle and self._hitPositionNormal.Z < self._slipStopAngle then
    self._lastAngle = self._hitPositionNormal.Z
  end
  self._lastAngle = UE4.UKismetMathLibrary.Lerp(self._lastAngle, self._hitPositionNormal.Z, self.StoplerpAlpha)
  if self._lastAngle > self._slipStopAngle then
    if speed < self.SlipStopSpeed then
      self:WaitingAnimStop()
    else
      self.characterMovement.Velocity = FVectorZero
      self:Finish()
    end
    return
  end
  if self._hitPositionNormal.Z > self._slipThresholdDown and speed <= 0 or self:VCheck(60) then
    self:WaitingAnimStop()
    return
  end
  if 0 == self._lerpAlpha or 1 == self._lerpAlpha then
    local rotation = UE4.UKismetMathLibrary.FindLookAtRotation(FVectorZero, UE4.FVector(self._currentSpeedVector.X, self._currentSpeedVector.Y, 0))
    self:SafeSetRotation(rotation)
  end
end

function BP_MovePhysComponent_C:Finish()
  if self.state ~= ABEnum.AbilityState.Casting then
    return
  end
  if self._bIsInTurnPhase then
    return
  end
  self:CancelStickToTheGround()
  self:StopSlipAnimition()
  self._bIsInStopSpeedPhase = false
  self._bIsInTurnPhase = false
  self._bIsInSlipPhase = false
end

function BP_MovePhysComponent_C:WaitingAnimStop()
  if self.pawn.Sliding == true then
    self.pawn.Sliding = false
  end
  local AnimInstance = self.pawn.Mesh:GetAnimInstance()
  if self.SlipeMontage ~= nil and AnimInstance:Montage_IsPlaying(self.SlipeMontage) then
    if self._curStopSlipAnimTime < self.MinStopSlipAnimTime then
      return
    else
      self:SetInputState(true)
      local player = self.pawn
      if player.sceneCharacter and player.sceneCharacter.movementComponent:HasMoveInput() then
        AnimInstance:Montage_Stop(self.StopSlipAnimBlendOutTime, self.SlipeMontage)
      else
        return
      end
    end
  end
  self.state = ABEnum.AbilityState.PreCasting
  self:InitialParameters()
  self:SetInputState(true)
end

function BP_MovePhysComponent_C:SetGroundFriction()
  self._groundFriction = self.characterMovement.GroundFriction
  self.GroundFriction = self._groundFriction * self.GroundFrictionFactor
end

function BP_MovePhysComponent_C:SetGroundGradient()
  self._gradientVector = UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)
  self._initialGradientRotation = UE4.UKismetMathLibrary.FindLookAtRotation(FVectorZero, self._gradientVector)
  if math.abs(self._initialGradientRotation.Yaw - self._initialRotation.Yaw) > 180 then
    if self._initialGradientRotation.Yaw > self._initialRotation.Yaw then
      self._initialGradientRotation.Yaw = self._initialGradientRotation.Yaw - 360
    else
      self._initialGradientRotation.Yaw = self._initialGradientRotation.Yaw + 360
    end
  end
end

function BP_MovePhysComponent_C:ChangeVelocity(DetaVeloctity)
  if self:IsLocal() == false then
    return
  end
  local temp
  local curGradient = UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)
  if UE4.UKismetMathLibrary.Dot_VectorVector(self._gradientVector, curGradient) >= 0 then
    temp = curGradient * DetaVeloctity
  else
    temp = curGradient * -1 * DetaVeloctity
  end
  self._currentSpeedVector = self._currentSpeedVector + temp
  self.characterMovement.Velocity = LocalUE4.FVector(self._currentSpeedVector.X, self._currentSpeedVector.Y, self._currentSpeedVector.Z)
end

function BP_MovePhysComponent_C:StickToTheGround()
end

function BP_MovePhysComponent_C:CancelStickToTheGround()
end

function BP_MovePhysComponent_C:PlaySlipAnimition()
  if self._bIsPlayAnim == false then
    self.pawn.Sliding = true
    self._bIsPlayAnim = true
  end
end

function BP_MovePhysComponent_C:StopSlipAnimition()
  self.pawn.Sliding = false
  if self.pawn.Mesh ~= nil and self.characterMovement.CurrentFloor.bBlockingHit then
    if self._curMoveDis >= self.MinStopSlipDistance then
      self.SlipeMontage = self.pawn:GetAnimComponent():PrepareMontageByName("SlipeStop")
      local AnimInstance = self.pawn.Mesh:GetAnimInstance()
      AnimInstance:Montage_Play(self.SlipeMontage)
      self._curStopSlipAnimTime = 0.0
    end
    self._bIsPlayAnim = false
    self._bIsWaitingStopAnim = true
    return
  end
  self:WaitingAnimStop()
end

function BP_MovePhysComponent_C:FloorCanSlope()
  local floor = self.characterMovement.CurrentFloor.HitResult.Actor
  if nil == floor then
    return false
  end
  if nil == floor:Cast(LocalUE4.ALandscape) and nil == floor:Cast(LocalUE4.ALandscapeStreamingProxy) then
    if floor:ActorHasTag("NoSlope") then
      return false
    else
      return true
    end
  end
  return true
end

function BP_MovePhysComponent_C:StairCheck()
  self.StairCheckDistance = 50
  self.StairCheckDensity = 3
  local curLocation = self.pawn:Abs_K2_GetActorLocation()
  curLocation = self.characterMovement.CurrentFloor.HitResult.ImpactPoint
  local projectForward = UE4.FVector(-self._hitPositionNormal.X, -self._hitPositionNormal.Y, 0)
  if UE4.UKismetMathLibrary.Dot_VectorVector(self.pawn:GetActorForwardVector(), UE4.FVector(-self._hitPositionNormal.X, -self._hitPositionNormal.Y, 0)) < 0 then
    projectForward = UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)
  end
  local locationOffset
  self.StairCheckDensity = UE4.UKismetMathLibrary.Clamp(self.StairCheckDensity, 1, 10)
  local slipThreshold = self:GetSlipThreshold()
  for index = 1, self.StairCheckDensity do
    local checkLocation = UE4.UKismetMathLibrary.Add_VectorVector(projectForward * self.StairCheckDistance * index / self.StairCheckDensity, curLocation)
    local HitResult, bHit = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self.pawn, checkLocation + UE4.FVector(0, 0, 200), checkLocation + UE4.FVector(0, 0, -200), UE4.ETraceTypeQuery.TraceTypeQuery2, false, nil, linetraceDebugtype, nil, true)
    if bHit then
      if slipThreshold <= HitResult.ImpactNormal.Z then
        return true
      end
      locationOffset = UE4.UKismetMathLibrary.Subtract_VectorVector(HitResult.Location, curLocation)
    else
      return true
    end
  end
  locationOffset = UE4.UKismetMathLibrary.Normal(locationOffset)
  local Zoffset = math.sqrt(1 - locationOffset.Z ^ 2)
  if slipThreshold <= Zoffset then
    return true
  end
  return false
end

function BP_MovePhysComponent_C:VCheck(distance)
  self.VCheckDistance = distance or 100
  local curLocation = self.pawn:Abs_K2_GetActorLocation()
  local checkH = curLocation.Z + math.tan(self.SlipDetectThresholdAngle * math.pi / 180) * self.VCheckDistance
  curLocation.Z = checkH
  local projectForward = self.pawn:GetActorForwardVector()
  local checkLocation1 = UE4.UKismetMathLibrary.Add_VectorVector(projectForward * self.VCheckDistance, curLocation)
  local checkLocation2 = UE4.UKismetMathLibrary.Add_VectorVector(projectForward * self.VCheckDistance * -1, curLocation)
  local HitResult, bHit = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self.pawn, curLocation, checkLocation1, UE4.ETraceTypeQuery.TraceTypeQuery2, false, nil, linetraceDebugtype, nil, true)
  local HitResult2, bHit2 = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self.pawn, curLocation, checkLocation2, UE4.ETraceTypeQuery.TraceTypeQuery2, false, nil, linetraceDebugtype, nil, true)
  if bHit2 and bHit then
    return true
  end
  return false
end

function BP_MovePhysComponent_C:CanSlip()
  local slipThreshold = self:GetSlipThreshold()
  return slipThreshold > self._hitPositionNormal.Z
end

function BP_MovePhysComponent_C:GetSlipThreshold()
  local faceSlope = self:IsFaceToUpGrade(self.pawn:GetActorForwardVector(), self._hitPositionNormal)
  if faceSlope then
    return self._slipThresholdUp
  end
  return self._slipThresholdDown
end

function BP_MovePhysComponent_C:IsLocal()
  self.executer = self.pawn.sceneCharacter
  if self.executer.isLocal then
    return self.executer.isLocal
  end
  return false
end

function BP_MovePhysComponent_C:SetInputState(bCanInput)
  self.executer = self.pawn.sceneCharacter
  if self.executer.inputComponent then
    self.executer.inputComponent:SetInputEnable(self, bCanInput, "BP_MovePhysComponent")
  end
end

function BP_MovePhysComponent_C:IsFaceToUpGrade(PlayerFaceTowards, LandGradientTowards)
  local cosValue = LocalUE4.UKismetMathLibrary.Vector_CosineAngle2D(PlayerFaceTowards, LandGradientTowards)
  return cosValue < LocalUE4.UKismetMathLibrary.Cos(90 * math.pi / 180)
end

function BP_MovePhysComponent_C:IsPreCasting()
  return self.state == ABEnum.AbilityState.PreCasting
end

function BP_MovePhysComponent_C:IsCasting()
  return self.state == ABEnum.AbilityState.Casting
end

function BP_MovePhysComponent_C:ReceiveTick(DeltaSeconds)
  if self:IsCasting() then
    if self._bIsInStopSpeedPhase then
      self:StopSpeed(self.UpStopFactor, DeltaSeconds)
    end
    if self._bIsInTurnPhase then
      self:TurnBack(DeltaSeconds, self.TurnSpeed)
    end
    if self._bIsInSlipPhase then
      self:SlipToGround(DeltaSeconds)
    end
    if self._bIsWaitingStopAnim then
      self:WaitingAnimStop()
      self._curStopSlipAnimTime = self._curStopSlipAnimTime + DeltaSeconds
    end
    if self._bIsInRunWallPhase then
      self:RunWall(DeltaSeconds)
    end
  end
  if self:IsPreCasting() and self.characterMovement.CurrentFloor.bBlockingHit then
    self._bBeginDetectSlop = false
    if self._hitPositionNormal.Z < self._slipDetectThreshold then
      if false == self:FloorCanSlope() then
        return
      end
      local friction = self.characterMovement.GroundFriction * self.GroundFrictionFactor
      if friction > math.tan(math.acos(self._hitPositionNormal.Z)) then
        Log.Warning("\229\157\161\233\157\162\232\135\170\233\148\129!!!\229\189\147\229\137\141\232\167\146\229\186\166\239\188\154" .. tostring(math.acos(self._hitPositionNormal.Z) * 180 / math.pi) .. "\232\135\170\233\148\129\232\167\146\229\186\166\239\188\154" .. tostring(math.atan(friction) * 180 / math.pi))
        return
      end
      if false == (self:StairCheck() or self:VCheck(100)) then
        self._bBeginDetectSlop = true
      end
    end
    if self._bBeginDetectSlop and self:CanSlip() then
      self:SetGroundFriction()
      Log.Debug("zzh friction: " .. tostring(self.GroundFriction))
      local speed = self.characterMovement.Velocity
      self._originSpeedVector = LocalUE4.FVector(speed.X, speed.Y, speed.Z)
      self:SetInputState(false)
      self.state = ABEnum.AbilityState.Casting
      local playerRotation = self.pawn:K2_GetActorRotation()
      self._initialRotation = LocalUE4.FRotator(playerRotation.Pitch, playerRotation.Yaw, playerRotation.Roll)
      self:SetGroundGradient()
      if self:IsFaceToUpGrade(self.pawn:GetActorForwardVector(), self._hitPositionNormal) then
        if self.pawn.MovementState == self.LastMovementState then
          self._bIsInRunWallPhase = true
        else
          self._bIsInStopSpeedPhase = true
        end
      else
        self:StartSlip()
        self._bIsInTurnPhase = true
        self._bIsInSlipPhase = true
      end
    end
  end
  self.LastMovementState = self.pawn.MovementState
  self._LastLocation = self.pawn:Abs_K2_GetActorLocation()
end

function BP_MovePhysComponent_C:RunWall(DeltaSeconds)
  if self:IsLocal() == false then
    local AnimInstance = self.pawn.Mesh:GetAnimInstance()
    if false == self._RunWallInit then
      self.SlipeMontage = self.pawn:GetAnimComponent():PrepareMontageByName("RunWallStart")
      AnimInstance:Montage_Play(self.SlipeMontage)
      self:PlayOrStopRunWallFx(true)
      self._RunWallInit = true
      return
    end
    if self.SlipeMontage ~= nil and AnimInstance:Montage_IsPlaying(self.SlipeMontage) then
      return
    elseif self.SlipeMontage ~= nil then
      self.MTG_RunWall = self.pawn:GetAnimComponent():PrepareMontageByName("RunWallLoop")
      AnimInstance:Montage_Play(self.MTG_RunWall)
      AnimInstance:Montage_SetNextSection("Default", "Default", self.MTG_RunWall)
      self.SlipeMontage = nil
    end
    if self.pawn:Abs_K2_GetActorLocation().Z == self._LastLocation.Z then
      self:RunWallStop()
    end
    if false == self.characterMovement.CurrentFloor.bBlockingHit and self.pawn:Abs_K2_GetActorLocation().Z - self._LastLocation.Z > -10 * DeltaSeconds then
      self:RunWallStop()
    end
    return
  end
  local AnimInstance = self.pawn.Mesh:GetAnimInstance()
  if false == self._RunWallInit then
    self._RWrotator = self.pawn:K2_GetActorRotation()
    self.SlipeMontage = self.pawn:GetAnimComponent():PrepareMontageByName("RunWallStart")
    AnimInstance:Montage_Play(self.SlipeMontage)
    self._RWspeed = self.RunWallDownSpeed
    self:PlayOrStopRunWallFx(true)
    self._RunWallInit = true
    return
  end
  local gradientRotator
  if 0 == self._currentSpeedVector.X and 0 == self._currentSpeedVector.Y then
    gradientRotator = UE4.UKismetMathLibrary.FindLookAtRotation(FVectorZero, UE4.FVector(-self._hitPositionNormal.X, -self._hitPositionNormal.Y, 0))
  else
    gradientRotator = UE4.UKismetMathLibrary.FindLookAtRotation(FVectorZero, UE4.FVector(-self._currentSpeedVector.X, -self._currentSpeedVector.Y, 0))
  end
  self._RWrotator = UE4.UKismetMathLibrary.RInterpTo(self._RWrotator, gradientRotator, DeltaSeconds, 10)
  self:SafeSetRotation(self._RWrotator)
  if self.SlipeMontage ~= nil and AnimInstance:Montage_IsPlaying(self.SlipeMontage) then
    return
  elseif self.SlipeMontage ~= nil then
    self.MTG_RunWall = self.pawn:GetAnimComponent():PrepareMontageByName("RunWallLoop")
    AnimInstance:Montage_Play(self.MTG_RunWall)
    AnimInstance:Montage_SetNextSection("Default", "Default", self.MTG_RunWall)
    self.SlipeMontage = nil
  end
  if false == self.characterMovement.CurrentFloor.bBlockingHit then
    self:RunWallStop()
    return
  end
  self._RWspeed = self._RWspeed + self.RunWallDownSpeedRate * DeltaSeconds
  local curGradient = UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)
  self._currentSpeedVector = curGradient * self._RWspeed
  self.characterMovement.Velocity = LocalUE4.FVector(self._currentSpeedVector.X, self._currentSpeedVector.Y, self._currentSpeedVector.Z)
  if self._hitPositionNormal.z > self._RWStopAngle or self:VCheck(60) then
    self.pawn:GetMovementComponent():StopMovementImmediately()
    self:RunWallStop()
    return
  end
  if UE4.UKismetMathLibrary.Dot_VectorVector(self._gradientVector, UE4.FVector(self._hitPositionNormal.X, self._hitPositionNormal.Y, 0)) < 0 then
    self.pawn:GetMovementComponent():StopMovementImmediately()
    self:RunWallStop()
    return
  end
end

function BP_MovePhysComponent_C:SafeSetRotation(Rotator)
  if 0 == Rotator.Pitch then
    self.pawn:K2_SetActorRotation(Rotator, false)
  else
    Log.Warning("should not rotator pitch!")
  end
end

function BP_MovePhysComponent_C:RunWallStop()
  self._bIsInRunWallPhase = false
  self:PlayOrStopRunWallFx(false)
  local AnimInstance = self.pawn.Mesh:GetAnimInstance()
  AnimInstance:Montage_Stop(self.StopSlipAnimBlendOutTime, self.MTG_RunWall)
  self:WaitingAnimStop()
end

return BP_MovePhysComponent_C
