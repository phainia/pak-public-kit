local TaskIdentify = require("NewRoco.Modules.System.TakePhotos.Helper.CameraIdentify.TaskIdentify")
local PetIdentify = require("NewRoco.Modules.System.TakePhotos.Helper.CameraIdentify.PetIdentify")
local IdentifyProxy = Class("IdentifyProxy")

function IdentifyProxy:Ctor(Panel)
  self.Panel = Panel
  Panel.OnDestroyMultiDelegate:Add(self, self.OnDestroy)
  Panel.OnTickMultiDelegate:Add(self, self.OnTick)
  Panel.OnModeChangedDelegate:Add(self, self.OnModeChanged)
  self.PetIdentify = PetIdentify(self)
  self.TaskIdentify = TaskIdentify(self)
  self.Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.PlayerController = self.Player:GetUEController()
  self.PlayerCameraManager = self.PlayerController.PlayerCameraManager
  self.IdentifyPitchAngleLimits = TakePhotosEnum.TPGlobalNum("takephoto_visual_angle")
  self.OriginalViewPitchMin = self.PlayerCameraManager.ViewPitchMin
  self.OriginalViewPitchMax = self.PlayerCameraManager.ViewPitchMax
  self.bEnableIdentify = true
  self.OutlineClass = nil
  self.OutlineClassRef = nil
  self:InitOutline()
end

function IdentifyProxy:InitOutline()
  local OutlineClassPath = self.Panel.outline_soft_class.AssetPathName
  self.OutlineClassRequest = NRCResourceManager:LoadResAsync(self, OutlineClassPath, 255, -1, function(_, Request, Res)
    self.OutlineClassRequest = nil
    if Res then
      self.OutlineClass = Res
      self.OutlineClassRef = UnLua.Ref(Res)
    end
    self.PetIdentify:OnOutlineClassLoaded(Res)
    self.TaskIdentify:OnOutlineClassLoaded(Res)
  end, function()
    self.OutlineClassRequest = nil
  end)
end

function IdentifyProxy:OnDestroy()
  if UE.UObject.IsValid(self.PlayerCameraManager) then
    self.PlayerCameraManager.ViewPitchMin = self.OriginalViewPitchMin
    self.PlayerCameraManager.ViewPitchMax = self.OriginalViewPitchMax
  end
  self.PetIdentify:OnDestroy()
  self.TaskIdentify:OnDestroy()
  if self.OutlineClassRequest then
    NRCResourceManager:UnLoadRes(self.OutlineClassRequest)
    self.OutlineClassRequest = nil
  end
  self.OutlineClassRef = nil
  self.OutlineClass = nil
end

function IdentifyProxy:OnModeChanged()
  if self.Panel.CurrMode.Mgr:IsWorldMode() then
    self.TaskIdentify:CaptureCandidates()
  else
    self.TaskIdentify:CancelCandidates()
  end
end

function IdentifyProxy:CanDisplayOutline()
  return not self.Panel.CurrMode.Mgr:IsWorldMode()
end

function IdentifyProxy:GetDistanceScale()
  local Mode = self.Panel.CurrMode
  return self.PlayerCameraManager.FOV / Mode:GetBaseFov()
end

function IdentifyProxy:ContainsPitchAngles(Mode)
  local bCameraPitchConstraints = true
  if Mode.Mgr:Is1PMode() and self.Player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    bCameraPitchConstraints = true
  end
  if bCameraPitchConstraints then
    self.PlayerCameraManager.ViewPitchMin = -self.IdentifyPitchAngleLimits
    self.PlayerCameraManager.ViewPitchMax = self.IdentifyPitchAngleLimits
  else
    self.PlayerCameraManager.ViewPitchMin = self.OriginalViewPitchMin
    self.PlayerCameraManager.ViewPitchMax = self.OriginalViewPitchMax
  end
end

function IdentifyProxy:SetIdentifyEnabled(bEnabled)
  if self.bEnableIdentify ~= bEnabled then
    self.bEnableIdentify = bEnabled
    if not bEnabled then
      self.PetIdentify:TryStopPetIdentify()
      self.TaskIdentify:TryStopTaskIdentify()
    end
  end
end

function IdentifyProxy:TryUpload()
  Log.Debug("[TakePhoto] TryUpload")
  self.PetIdentify:TryUploadPetFound()
  self.TaskIdentify:TryUploadCondition()
end

function IdentifyProxy:OnShared(PhotoData)
  Log.Debug("[TakePhoto] OnShared", PhotoData)
  self.TaskIdentify:OnShared(PhotoData)
  self.PetIdentify:OnShared(PhotoData)
end

function IdentifyProxy:GetPetIdentifyInfo()
  return self.PetIdentify:GetPetIdentifyInfo()
end

function IdentifyProxy:GetTaskIdentifyInfo()
  return self.TaskIdentify:GetTaskIdentifyInfo()
end

function IdentifyProxy:OnTick(Dt)
  local Mode = self.Panel.CurrMode
  if not Mode then
    return
  end
  self:ContainsPitchAngles(Mode)
  if not self.bEnableIdentify then
    return
  end
  if self.TaskIdentify:TryTaskIdentify(Mode) then
    self.PetIdentify:TryStopPetIdentify()
    return
  end
  if not Mode.Mgr:IsWorldMode() then
    self.PetIdentify:TryPetIdentify(Mode)
  else
    self.PetIdentify:TryStopPetIdentify()
  end
end

return IdentifyProxy
