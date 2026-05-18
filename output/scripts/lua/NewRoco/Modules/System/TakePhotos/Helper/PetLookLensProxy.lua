local TakePhotosModuleEvent = require("NewRoco.Modules.System.TakePhotos.TakePhotosModuleEvent")
local PetLookLensProxy = Class("PetLookLensProxy")

function PetLookLensProxy:Ctor(MainPanel)
  self.MainPanel = MainPanel
  self.MainPanel.OnDestroyMultiDelegate:Add(self, self.OnDestroy)
  self.MainPanel.OnTickMultiDelegate:Add(self, self.OnTick)
  self.MainPanel.OnReadyDelegate:Add(self, self.OnReady)
  self.Settings = MainPanel:GetPhotoController().TakePhotoSettings
  self.Settings.PetLookCamera.OnValueChanged:Add(self, self.OnPetLookToggled)
  self.PetLookTarget = nil
end

function PetLookLensProxy:OnDestroy()
  if self.PetLookTarget then
    local bValid = UE.UObject.IsValid(self.PetLookTarget)
    self.MainPanel:DispatchEvent(TakePhotosModuleEvent.OnDestroyPetLookLensTarget, bValid and self.PetLookTarget or nil)
    if bValid then
      self.PetLookTarget:K2_DestroyActor()
    end
    self.PetLookTarget = nil
  end
end

function PetLookLensProxy:OnTick()
  if self.MainPanel.CurrMode then
    self:UpdateTransform()
  end
end

function PetLookLensProxy:OnReady()
  if self.Settings.PetLookCamera:IsEnabled() then
    self:OnPetLookToggled(true)
  end
end

function PetLookLensProxy:OnPetLookToggled(bEnable)
  if not self.PetLookTarget then
    self:SpawnPetLookTarget()
  end
  self.MainPanel:DispatchEvent(TakePhotosModuleEvent.OnTogglePetLookLens, bEnable)
end

function PetLookLensProxy:SpawnPetLookTarget()
  self.PetLookTarget = UE4Helper.GetCurrentWorld():Abs_SpawnActor(UE.ANPCSimpleSkillTarget, self:UpdateTransform(true), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
  if not self.PetLookTarget then
    Log.Error("[TakePhoto] Logical Error!!!")
    return
  end
  self.MainPanel:DispatchEvent(TakePhotosModuleEvent.OnSpawnPetLookLensTarget, self.PetLookTarget)
end

function PetLookLensProxy:UpdateTransform(bConstructTransform)
  local Transform
  if self.MainPanel.CurrMode.Mgr:Is1PMode() then
    local LocalPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local Mesh = LocalPlayer.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
    Transform = Mesh:Abs_GetSocketTransform("locator_Head", UE4.ERelativeTransformSpace.RTS_World)
    if self.PetLookTarget then
      self.PetLookTarget:Abs_K2_SetActorTransform_WithoutHit(Transform, false, true)
    end
  elseif self.MainPanel.CurrMode.Mgr:IsSelfieMode() then
    local CameraRotation, CameraLocation = self.MainPanel.CurrMode:GetCameraRotationLocation()
    if bConstructTransform then
      Transform = UE.FTransform(CameraRotation:ToQuat(), CameraLocation, FVectorOne)
    end
    if self.PetLookTarget then
      self.PetLookTarget:Abs_K2_SetActorLocationAndRotation_WithoutHit(CameraLocation, CameraRotation, false, true)
    end
  elseif self.MainPanel.CurrMode.Mgr:IsTripodAvailableMode() then
    local Tripod = self.MainPanel.CurrMode.TripodNpc
    if Tripod then
      Transform = Tripod:Abs_GetTransform()
      if self.PetLookTarget then
        self.PetLookTarget:Abs_K2_SetActorTransform_WithoutHit(Transform, false, true)
      end
    end
  end
  if not Transform and bConstructTransform then
    Transform = UE.FTransform()
  end
  return Transform
end

return PetLookLensProxy
