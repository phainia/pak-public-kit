local EnterExitContext = require("NewRoco/Modules/System/TakePhotos/Controller/EnterExitContext")
local ModeSwitchContext = require("NewRoco/Modules/System/TakePhotos/Controller/ModeSwitchContext")
local TakePhotoSettings = require("NewRoco.Modules.System.TakePhotos.Controller.TakePhotoSettings")
local PhotoManager = require("NewRoco.Modules.System.TakePhotos.Helper.PhotoManager")
local TakePhotosModuleEvent = require("NewRoco.Modules.System.TakePhotos.TakePhotosModuleEvent")
local TakePhotoControl = Class("TakePhotoControl")

function TakePhotoControl:Ctor(Module)
  self.Module = Module
  self.EnterExitContext = EnterExitContext(Module, self)
  self.ModeSwitchContext = ModeSwitchContext(Module, self)
  self.PhotoManager = PhotoManager()
  Module:RegisterEvent(self, TakePhotosModuleEvent.OnSpawnPetLookLensTarget, self.OnSpawnPetLookLensTarget)
  Module:RegisterEvent(self, TakePhotosModuleEvent.OnDestroyPetLookLensTarget, self.OnDestroyPetLookLensTarget)
  self.IdentifyViewInfo = UE.FMinimalViewInfo()
end

function TakePhotoControl:OnDestroy()
  self.PhotoManager:OnDestroy()
  self.Module:UnRegisterEvent(self, TakePhotosModuleEvent.OnSpawnPetLookLensTarget, self.OnSpawnPetLookLensTarget)
  self.Module:UnRegisterEvent(self, TakePhotosModuleEvent.OnDestroyPetLookLensTarget, self.OnDestroyPetLookLensTarget)
end

function TakePhotoControl:OnSpawnPetLookLensTarget(Target)
  self.PetLookLensTarget = Target
end

function TakePhotoControl:OnDestroyPetLookLensTarget()
  self.PetLookLensTarget = nil
end

function TakePhotoControl:GetIdentifyLookViewInfo()
  if self.Module.ModeMgr:IsWorldMode() then
    local Tripod = self.Module.ModeMgr.TakePhotosModeTripod.TripodNpc
    if Tripod and UE.UObject.IsValid(Tripod) then
      local Location = Tripod:Abs_K2_GetActorLocation()
      local Rotation = Tripod:K2_GetActorRotation()
      local Target = Tripod.SceneCaptureComponent2D
      UE.UNRCStatics.GetFrustumBySceneCapture2D(Target, self.IdentifyViewInfo)
      return Location, Rotation, self.IdentifyViewInfo, self.Module.ModeMgr.TakePhotosModeTripod.SavedFov
    end
  else
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer.viewObj and UE.UObject.IsValid(localPlayer.viewObj) then
      local PlayerCameraManager = localPlayer.viewObj:GetController().PlayerCameraManager
      local CameraLocation = PlayerCameraManager:Abs_GetCameraLocation()
      local CameraRotation = PlayerCameraManager:GetCameraRotation()
      UE.UNRCStatics.GetFrustumByPlayerCameraManager(PlayerCameraManager, self.IdentifyViewInfo)
      return CameraLocation, CameraRotation, self.IdentifyViewInfo, PlayerCameraManager.FOV
    end
  end
end

function TakePhotoControl:GetPetLookLensTarget()
  return self.PetLookLensTarget
end

function TakePhotoControl:IsPetLookLensTargetEnabled()
  return self.TakePhotoSettings and self.TakePhotoSettings.PetLookCamera:IsEnabled()
end

function TakePhotoControl:OnEnterSceneFinish()
  self.PhotoManager:OnEnterSceneFinish()
end

function TakePhotoControl:CanSwitchMode()
  return self.ModeSwitchContext:IsReady()
end

function TakePhotoControl:Enter()
  if not self.TakePhotoSettings then
    self.TakePhotoSettings = TakePhotoSettings()
  end
  return self.EnterExitContext:BeginEnter()
end

function TakePhotoControl:Exit(bImmediately)
  return self.EnterExitContext:BeginExit(bImmediately)
end

function TakePhotoControl:OnEnter()
end

function TakePhotoControl:OnPostEnter()
end

function TakePhotoControl:OnExit()
  self.TakePhotoSettings:Reset(true)
  self.ModeSwitchContext:BeginDestroy()
  self.TakePhotoSettings = nil
end

function TakePhotoControl:InternalTransit(Mode)
  if not self:CanSwitchMode() then
    return false
  end
  local bCanTransit, bDisableTips = Mode:PreCheck()
  if not bCanTransit then
    return false, bDisableTips
  end
  if not self.ModeSwitchContext:BeginTransit(self.Module.ModeMgr.CurrMode, Mode) then
    return false
  end
  return true
end

function TakePhotoControl:TransitTo(Mode)
  local bCanTransit, bDisableTips = self:InternalTransit(Mode)
  if not bCanTransit then
    if not bDisableTips then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_pattern_change_fail)
    end
    return false
  end
  return true
end

return TakePhotoControl
