local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
require("UnLuaEx")
local BP_WolfInputHandleCompnent_C = NRCClass()

function BP_WolfInputHandleCompnent_C:Ctor()
end

function BP_WolfInputHandleCompnent_C:CastAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  return abilityComponent:CastAbility(ability)
end

function BP_WolfInputHandleCompnent_C:StopAbility(ability)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local abilityComponent = Player.abilityComponent
  abilityComponent:StopAbility(false)
end

function BP_WolfInputHandleCompnent_C:OnInputTurn(dir, isRate)
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

function BP_WolfInputHandleCompnent_C:UpdateDirection()
  local ueCtrl = self:GetOwner():GetController()
  local Rotation = ueCtrl:GetControlRotation()
  Rotation:Set(0, Rotation.Yaw, 0)
  self.forward = Rotation:ToVector()
  self.right = Rotation:GetRightVector()
end

function BP_WolfInputHandleCompnent_C:OnInputMove(dir, axis)
  local ueCtrl = self:GetOwner():GetController()
  if ueCtrl then
    self:UpdateDirection()
    local Direction = -self.forward * dir.Y + self.right * dir.X
    self:Move(Direction, axis)
  end
end

function BP_WolfInputHandleCompnent_C:Move(dir, axis)
  self:GetOwner().AddMovementInput(self:GetOwner(), dir, axis)
end

return BP_WolfInputHandleCompnent_C
