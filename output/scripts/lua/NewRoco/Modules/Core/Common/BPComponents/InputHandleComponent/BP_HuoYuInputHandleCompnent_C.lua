local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
require("UnLuaEx")
local BP_HuoYuInputHandleCompnent_C = NRCClass()

function BP_HuoYuInputHandleCompnent_C:Ctor()
end

function BP_HuoYuInputHandleCompnent_C:ReceiveBeginPlay()
  self.OwnerMovement = self:GetOwner().CharacterMovement
end

function BP_HuoYuInputHandleCompnent_C:CastAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  return abilityComponent:CastAbility(ability)
end

function BP_HuoYuInputHandleCompnent_C:StopAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  abilityComponent:StopAbility(false)
end

function BP_HuoYuInputHandleCompnent_C:OnInputTurn(dir, isRate)
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

function BP_HuoYuInputHandleCompnent_C:UpdateDirection()
  local ueCtrl = self:GetOwner():GetController()
  local Rotation = ueCtrl:GetControlRotation()
  Rotation:Set(0, Rotation.Yaw, 0)
  self.Forward = Rotation:ToVector()
  self.Right = Rotation:GetRightVector()
end

function BP_HuoYuInputHandleCompnent_C:OnInputMove(dir, axis)
  if self.OwnerMovement == nil then
    return
  end
  local ueCtrl = self:GetOwner():GetController()
  if ueCtrl then
    self:UpdateDirection()
    local Direction = -self.Forward * dir.Y + self.Right * dir.X
    Speed = self.OwnerMovement.MaxWalkSpeed
    self:Move(Direction, axis)
    local GetForward = self:GetOwner():GetActorForwardVector()
    if self.OwnerMovement.MovementMode == UE4.EMovementMode.MOVE_Falling then
      self.OwnerMovement.Velocity = UE4.FVector(Direction.X * Speed * axis, Direction.Y * Speed * axis, self.OwnerMovement.Velocity.Z)
    end
  end
end

function BP_HuoYuInputHandleCompnent_C:Move(dir, axis)
  self:GetOwner().AddMovementInput(self:GetOwner(), dir, axis)
end

return BP_HuoYuInputHandleCompnent_C
