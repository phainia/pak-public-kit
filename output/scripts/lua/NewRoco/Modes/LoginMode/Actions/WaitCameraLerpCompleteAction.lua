local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local CreatePlayerUtils = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerUtils")
local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local Base = NRCModeAction
local WaitCameraLerpCompleteAction = Base:Extend("WaitCameraLerpCompleteAction")

function WaitCameraLerpCompleteAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function WaitCameraLerpCompleteAction:OnEnter()
  self:InjectProperties()
  if not self.properties.path then
    self:Finish()
    return
  end
  local CurrentWorld = UE4Helper.GetCurrentWorld()
  self.Controller = CreatePlayerUtils.GetLoginController()
  self.Camera = CurrentWorld:SpawnActor(UE4.ACineCameraActor, self.Controller:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, CurrentWorld)
  self.playerActor = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetPlayerActor)
  self:CheckShouldStopDimoMove()
  if self.properties.LerpCameraType == LoginEnum.SequenceLerpCameraType.LOGIN_ENTER then
    self:OnSwitchLoginEnterLerpCamera()
  else
    self:Finish()
  end
end

function WaitCameraLerpCompleteAction:OnSwitchLoginEnterLerpCamera()
  if self.Camera.GetCineCameraComponent and self.Camera:GetCineCameraComponent() then
    local CineCameraComponent = self.Camera:GetCineCameraComponent()
    CineCameraComponent.Filmback.SensorHeight = 10.0
    CineCameraComponent.Filmback.SensorWidth = 21.5
    CineCameraComponent.Filmback.SensorAspectRatio = 2.15
    CineCameraComponent.CurrentFocalLength = 13.0
    CineCameraComponent.bConstrainAspectRatio = false
  end
  local Loc = UE4.FVector(-2100.919, 398.42, 129.429)
  local Rot = UE4.FRotator(-3.913418, -2.949255, 0.0)
  self.Camera:K2_SetActorRotation(Rot, true)
  self.Camera:Abs_K2_SetActorLocation_WithoutHit(Loc, false, true)
  self.Controller:SetViewTargetWithBlend(self.Camera, 1, UE4.EViewTargetBlendFunction.VTBlend_EaseOut, 2)
  self.delayId = _G.DelayManager:DelaySeconds(1, function()
    self:Finish()
  end)
end

function WaitCameraLerpCompleteAction:CheckShouldStopDimoMove()
  if self.playerActor and (self.properties.path == UEPath.CREATEPLAYER_ENTER or self.properties.path == UEPath.LOGIN_ENTER or self.properties.path == UEPath.GENDER_CONFIRM_ENTER_FEMALE or self.properties.path == UEPath.GENDER_CONFIRM_IDLE_FEMALE or self.properties.path == UEPath.GENDER_CONFIRM_ENTER_MALESetMovementMode or self.properties.path == UEPath.GENDER_CONFIRM_IDLE_MALE) then
    self.playerActor:SetCharacterMovementTickEnabled(false, "WaitCameraLerpCompleteAction")
    self.playerActor.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_None)
  end
end

function WaitCameraLerpCompleteAction:CheckShouldStartDimoMove()
  if self.playerActor and self.properties.path ~= UEPath.CREATEPLAYER_ENTER and self.properties.path ~= UEPath.LOGIN_ENTER and self.properties.path ~= UEPath.GENDER_CONFIRM_ENTER_FEMALE and self.properties.path ~= UEPath.GENDER_CONFIRM_IDLE_FEMALE and self.properties.path ~= UEPath.GENDER_CONFIRM_ENTER_MALESetMovementMode and self.properties.path ~= UEPath.GENDER_CONFIRM_IDLE_MALE then
    self.playerActor:SetCharacterMovementTickEnabled(true, "WaitCameraLerpCompleteAction")
    self.playerActor.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Walking)
  end
end

function WaitCameraLerpCompleteAction:DestroyLerpCamera(DelayFrame)
  DelayFrame = DelayFrame or 1
  self.delayId = _G.DelayManager:DelayFrames(DelayFrame, function()
    if self.Camera then
      self.Camera:K2_DestroyActor()
      self.Camera = nil
    end
  end)
end

function WaitCameraLerpCompleteAction:OnFinish()
  self:CheckShouldStartDimoMove()
  self:DestroyLerpCamera()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

function WaitCameraLerpCompleteAction:OnExit()
  Log.Debug("WaitCameraLerpCompleteAction", self.name)
  self:DestroyLerpCamera()
end

return WaitCameraLerpCompleteAction
