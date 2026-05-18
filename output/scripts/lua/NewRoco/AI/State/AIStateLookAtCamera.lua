local AIStateSpec = require("NewRoco.AI.State.AIStateSpec")
local TakePhotosModuleEvent = require("NewRoco.Modules.System.TakePhotos.TakePhotosModuleEvent")
local AIStateLookAtCamera = AIStateSpec:Extend("AIStateLookAtCamera")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")

function AIStateLookAtCamera:OnStateAdd(owner, Immediately, Fallback)
  self.isValid = false
  if not self.PreCheck(owner) then
    return
  end
  self.isValid = true
  self.owner = owner
  self.FallbackActor = Fallback or nil
  local TakePhotosModule = _G.NRCModuleManager:GetModule("TakePhotosModule")
  TakePhotosModule:RegisterEvent(self, TakePhotosModuleEvent.OnTogglePetLookLens, self.OnTogglePetLookLens)
  TakePhotosModule:RegisterEvent(self, TakePhotosModuleEvent.OnSpawnPetLookLensTarget, self.OnSpawnPetLookLensTarget)
  TakePhotosModule:RegisterEvent(self, TakePhotosModuleEvent.OnDestroyPetLookLensTarget, self.OnDestroyPetLookLensTarget)
  self.CameraTargetActor = TakePhotosModule:GetPetLookLensTarget()
  self.EnabledPetLookLens = TakePhotosModule:IsPetLookLensTargetEnabled()
  self.state_ShouldLookAtCamera = false
  self:ApplyLookAtState(Immediately)
end

function AIStateLookAtCamera:OnStateRemoved(reason)
  if not self.isValid then
    return
  end
  self.FallbackActor = nil
  self.state_ShouldLookAtCamera = false
  if self.owner then
    self.owner:SetHeadLookAtActor(nil)
  end
  local TakePhotosModule = _G.NRCModuleManager:GetModule("TakePhotosModule")
  TakePhotosModule:UnRegisterEvent(self, TakePhotosModuleEvent.OnTogglePetLookLens, self.OnTogglePetLookLens)
  TakePhotosModule:UnRegisterEvent(self, TakePhotosModuleEvent.OnSpawnPetLookLensTarget, self.OnSpawnPetLookLensTarget)
  TakePhotosModule:UnRegisterEvent(self, TakePhotosModuleEvent.OnDestroyPetLookLensTarget, self.OnDestroyPetLookLensTarget)
  self.owner = nil
end

function AIStateLookAtCamera.PreCheck(owner)
  local PlayerUIN = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_UIN)
  return owner and owner:IsAThrownPet() and owner:GetWorldOwnerID() == PlayerUIN
end

function AIStateLookAtCamera:OnTogglePetLookLens(enabled)
  if self.EnabledPetLookLens == enabled then
    return
  end
  self.EnabledPetLookLens = enabled
  self:ApplyLookAtState()
end

function AIStateLookAtCamera:OnSpawnPetLookLensTarget(target)
  self:SetPetLookLensTarget(target)
end

function AIStateLookAtCamera:OnDestroyPetLookLensTarget()
  self:SetPetLookLensTarget(nil)
end

function AIStateLookAtCamera:SetPetLookLensTarget(target)
  if self.CameraTargetActor == target then
    return
  end
  self.CameraTargetActor = target
  self:ApplyLookAtState()
end

function AIStateLookAtCamera:ApplyLookAtState(Immediately)
  local state_ShouldLookAtCamera = self.EnabledPetLookLens and self.CameraTargetActor ~= nil
  if self.state_ShouldLookAtCamera == state_ShouldLookAtCamera then
    return
  end
  self.state_ShouldLookAtCamera = state_ShouldLookAtCamera
  if self.state_ShouldLookAtCamera then
    self.owner:SetHeadLookAtActor(self.CameraTargetActor, Immediately)
  else
    if self.FallbackActor and not UE.UObject.IsValid(self.FallbackActor) then
      self.FallbackActor = nil
    end
    self.owner:SetHeadLookAtActor(self.FallbackActor)
  end
end

return AIStateLookAtCamera
