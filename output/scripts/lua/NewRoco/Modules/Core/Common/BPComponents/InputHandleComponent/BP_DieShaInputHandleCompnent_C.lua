require("UnLuaEx")
local BP_DieShaInputHandleCompnent_C = NRCClass()

function BP_DieShaInputHandleCompnent_C:CastAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  return abilityComponent:CastAbility(ability)
end

function BP_DieShaInputHandleCompnent_C:StopAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  abilityComponent:StopAbility(false)
end

function BP_DieShaInputHandleCompnent_C:OnInputTurn(dir, isRate)
  local yaw = dir.X
  local pitch = dir.Y
  if isRate then
    local deltaTime = UE4.UGameplayStatics.GetWorldDeltaSeconds(self:GetOwner())
    yaw = dir.X * deltaTime * self.BaseTurnRate
    pitch = dir.Y * deltaTime * self.BaseLookUpRate
  end
  self.playerController = self:GetOwner():GetController()
  self.playerController:AddYawInput(yaw)
  self.playerController:AddPitchInput(pitch)
end

function BP_DieShaInputHandleCompnent_C:UpdateDirection()
  local ueCtrl = self:GetOwner():GetController()
  local Rotation = ueCtrl:GetControlRotation()
  Rotation:Set(0, Rotation.Yaw, 0)
  self.forward = Rotation:ToVector()
  self.right = Rotation:GetRightVector()
end

function BP_DieShaInputHandleCompnent_C:OnInputMove(dir, axis)
  local ueCtrl = self:GetOwner():GetController()
  if ueCtrl then
    self:UpdateDirection()
    local Direction = -self.forward * dir.Y + self.right * dir.X
    local AxisY = Direction:Dot(-self.forward) * axis
    local AxisX = Direction:Dot(self.right) * axis
    self.MoveforwardValue = UE4.UKismetMathLibrary.FInterpTo(self.MoveforwardValue, AxisY, UE4.UGameplayStatics.GetWorldDeltaSeconds(self), self.InterpSpeed)
    self.MoverightValue = UE4.UKismetMathLibrary.FInterpTo(self.MoverightValue, AxisX, UE4.UGameplayStatics.GetWorldDeltaSeconds(self), self.InterpSpeed)
    local InterpDirection = -self.forward * self.MoveforwardValue + self.right * self.MoverightValue
    local InterpAxis = InterpDirection:Size()
    InterpDirection:Normalize()
    self:Move(InterpDirection, InterpAxis)
  end
end

function BP_DieShaInputHandleCompnent_C:Move(dir, axis)
  self:GetOwner().AddMovementInput(self:GetOwner(), dir, axis)
end

function BP_DieShaInputHandleCompnent_C:HasMovementInput()
  return 0 ~= self.MoveforwardValue or 0 ~= self.MoverightValue
end

function BP_DieShaInputHandleCompnent_C:ReceiveTick(DeltaSeconds)
  local ueCtrl = self:GetOwner():GetController()
  if ueCtrl then
    self:UpdateDirection()
    local lastInput = self:GetOwner():GetMovementComponent():GetLastInputVector()
    if 0 ~= self.MoveforwardValue and 0 == lastInput:Dot(-self.forward) then
      self.MoveforwardValue = UE4.UKismetMathLibrary.FInterpTo(self.MoveforwardValue, 0, DeltaSeconds, self.StopInterpSpeed)
      self:Move(-self.forward, self.MoveforwardValue)
    end
    if 0 ~= self.MoverightValue and 0 == lastInput:Dot(self.right) then
      self.MoverightValue = UE4.UKismetMathLibrary.FInterpTo(self.MoverightValue, 0, DeltaSeconds, self.StopInterpSpeed)
      self:Move(self.right, self.MoverightValue)
    end
  end
end

return BP_DieShaInputHandleCompnent_C
