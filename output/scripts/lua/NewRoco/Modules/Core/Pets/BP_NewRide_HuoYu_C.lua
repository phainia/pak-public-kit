require("UnLuaEx")
local BP_NewRide_HuoYu_C = NRCClass()

function BP_NewRide_HuoYu_C:ReceiveBeginPlay()
  self.TargetRotation = self:K2_GetActorRotation()
  self.CurrentChargedCD = self.ChargedPointCD
  self.CurrentDoubleJumpCD = self.DoubleJumpCD
  self.ChargedPoint = self.MaxChargedPoint
  self.IsDoubleJump = true
end

function BP_NewRide_HuoYu_C:ChargedPointFinishCoolDown()
  self.ChargedPoint = self.ChargedPoint + 1
  if self.ChargedPoint >= self.MaxChargedPoint then
    self.ChargedPoint = self.MaxChargedPoint
  end
  self.CurrentChargedCD = self.ChargedPointCD
end

function BP_NewRide_HuoYu_C:DoubleJumpFinishCoolDown()
  self.IsDoubleJump = true
  self.CurrentDoubleJumpCD = self.DoubleJumpCD
end

function BP_NewRide_HuoYu_C:HandleOnAirMovement()
  if self.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Falling then
    self.CharacterMovement.RotationRate = UE4.FRotator(0, self.RotateSpeedOnAir, 0)
    local FallingSpeed = -self.CharacterMovement.Velocity.Z
    if FallingSpeed > self.MaxFallingSpeed then
      self.CharacterMovement.Velocity.Z = -self.MaxFallingSpeed
    end
  else
    self.CharacterMovement.RotationRate = UE4.FRotator(0, self.RotateSpeed, 0)
  end
end

function BP_NewRide_HuoYu_C:HandleCoolDown(DeltaSeconds)
  self.CurrentChargedCD = self.CurrentChargedCD - DeltaSeconds
  self.CurrentDoubleJumpCD = self.CurrentDoubleJumpCD - DeltaSeconds
  if self.CurrentChargedCD <= 0 then
    self:ChargedPointFinishCoolDown()
  end
  if self.CurrentDoubleJumpCD <= 0 then
    self:DoubleJumpFinishCoolDown()
  end
end

function BP_NewRide_HuoYu_C:ReceiveTick(DeltaSeconds)
  if self.CurrentChargedCD == nil or nil == self.CharacterMovement then
    return
  end
  self:HandleCoolDown(DeltaSeconds)
  self:HandleOnAirMovement()
end

function BP_NewRide_HuoYu_C:JumpEvent()
  local movement = self.CharacterMovement
  if movement.MovementMode == UE4.EMovementMode.MOVE_Falling then
    self:DoubleJump()
  else
    self:OneStageJump()
  end
end

function BP_NewRide_HuoYu_C:OneStageJump()
  self:SetJumpSpeed(540)
  self:Jump()
end

function BP_NewRide_HuoYu_C:DoubleJump()
  if 0 == self.ChargedPoint or self.ChargedPoint == nil or self.IsDoubleJump == false or self.CurrentDoubleJumpCD < 0 then
    return
  end
  self.ChargedPoint = self.ChargedPoint - 1
  self.IsDoubleJump = false
  self:SetJumpSpeed(680)
  self:Jump()
end

return BP_NewRide_HuoYu_C
