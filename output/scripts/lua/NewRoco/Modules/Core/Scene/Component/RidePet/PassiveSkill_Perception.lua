local Base = require("NewRoco.Modules.Core.Scene.Component.RidePet.PassiveSkill_Base")
local PassiveSkill_Perception = Base:Extend("PassiveSkill_Perception")
local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")

function PassiveSkill_Perception:Ctor(owner, config)
  Base.Ctor(self, owner, config)
end

function PassiveSkill_Perception:Start()
  local bInTakePhoto = _G.TakePhotosModuleCmd and _G.NRCModuleManager:DoCmd(_G.TakePhotosModuleCmd.IfInTakePhotoState)
  if bInTakePhoto then
    Log.Debug("PassiveSkill_Perception is forbidden in TakePhoto mode")
    return
  end
  local TakePhotoModule = _G.NRCModuleManager:GetModule("TakePhotosModule")
  if TakePhotoModule then
    TakePhotoModule:RegisterEvent(self, TakePhotosModuleEvent.OnEnterTakePhotos, self.OnEnterTakePhotos)
    TakePhotoModule:RegisterEvent(self, TakePhotosModuleEvent.OnExitTakePhotos, self.OnExitTakePhotos)
  end
  self.bStarted = true
end

function PassiveSkill_Perception:OnSetViewObj()
  self:Active()
end

function PassiveSkill_Perception:Active()
  if self.bStarted and self.owner.viewObj then
    local klass = UE4.UNRCStatics.ResolveClass(UEPath.BPPerceptionPath)
    if klass then
      local identityXfm = UE4.FTransform()
      self.bp_trigger = UE4Helper.GetCurrentWorld():Abs_SpawnActor(klass, identityXfm, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
      self.bp_trigger:K2_AttachToActor(self.owner.viewObj)
      self.bp_trigger:K2_SetActorRelativeTransform(identityXfm, false, nil, false)
      self.bp_trigger:Init(self.config, self.owner)
    end
  end
end

function PassiveSkill_Perception:DeActive()
  if self.bp_trigger then
    self.bp_trigger:OnDestroy()
    self.bp_trigger:K2_DestroyActor()
    self.bp_trigger = nil
  end
end

function PassiveSkill_Perception:Stop()
  self:DeActive()
  self.bStarted = false
  local TakePhotoModule = _G.NRCModuleManager:GetModule("TakePhotosModule")
  if TakePhotoModule then
    TakePhotoModule:UnRegisterEvent(self, TakePhotosModuleEvent.OnEnterTakePhotos)
    TakePhotoModule:UnRegisterEvent(self, TakePhotosModuleEvent.OnExitTakePhotos)
  end
end

function PassiveSkill_Perception:OnEnterTakePhotos()
  Log.Debug("PassiveSkill_Perception OnEnterTakePhotos DeActive")
  self:DeActive()
end

function PassiveSkill_Perception:OnExitTakePhotos()
  Log.Debug("PassiveSkill_Perception OnExitTakePhotos Active")
  self:Active()
end

return PassiveSkill_Perception
