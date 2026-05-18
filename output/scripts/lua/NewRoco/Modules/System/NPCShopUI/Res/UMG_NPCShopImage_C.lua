local UMG_NPCShopImage_C = _G.NRCViewBase:Extend("UMG_NPCShopImage_C")

function UMG_NPCShopImage_C:OnConstruct()
  self.Actor:DestroyActor()
end

function UMG_NPCShopImage_C:OnActive(actor, cameraTransform)
  self.Actor = actor
  self:SetWorldView(actor, cameraTransform)
  Log.Debug("UE4Helper.SetEnableWorldRendering false")
  UE4Helper.SetEnableWorldRendering(false)
  local CameraActor = self.previewWorld:getActorByName("MainCamera")
  self.previewWorld:SetCameraActor(CameraActor)
  self.captureComponent.bCaptureEveryFrame = true
  self.captureComponent.bCaptureOnMovement = true
end

function UMG_NPCShopImage_C:OnDeactive()
end

function UMG_NPCShopImage_C:OnDestruct()
end

function UMG_NPCShopImage_C:CaptureActorAndRemove()
  self:Log("CaptureActorAndRemove")
  self.captureComponent.bCaptureEveryFrame = false
  self.captureComponent.bCaptureOnMovement = false
  self.captureComponent:CaptureScene()
end

function UMG_NPCShopImage_C:RemoveActor()
  self.PreviewWorld:RemoveActor(self.Actor, self.Actor:GetTransform())
  self.Actor:ReleaseVisibleLevel()
  self.Actor:SetInSignificance(true)
end

function UMG_NPCShopImage_C:OnAddEventListener()
end

function UMG_NPCShopImage_C:SetWorldView(actor, cameraTransform)
  if actor then
    local transform = actor:GetTransform()
    self:AddActorToScene(actor, transform, cameraTransform)
  end
end

function UMG_NPCShopImage_C:AddActorToScene(actor, transform, cameraTransform)
  self.PreviewWorld:AddActor(actor, transform)
  local camera = self.PreviewWorld:getActorByName("DefaultSceneCapture_zong")
  camera:K2_SetActorTransform(cameraTransform)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.StreamingDistanceMultiplier = 999
  self.captureComponent = camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.captureComponent.FOVAngle = 50
  self.captureComponent.showOnlyActors:Clear()
  self.captureComponent.showOnlyActors:Add(actor)
  actor:ForceVisible()
  actor:SetInSignificance(false)
  self.previewWorld:SetCapturePostProcessing(self.captureComponent)
  UE4.UNRCStatics.ChangeTextureToMatchScreen(self.captureComponent.TextureTarget, UE4Helper.GetCurrentWorld(), 0)
end

return UMG_NPCShopImage_C
