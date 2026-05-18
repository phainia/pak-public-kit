local UMG_WorldViewUI_C = _G.NRCPanelBase:Extend("UMG_WorldViewUI_C")

function UMG_WorldViewUI_C:OnConstruct()
end

function UMG_WorldViewUI_C:OnDestruct()
end

function UMG_WorldViewUI_C:OnActive(actor, cameraTransform)
  if actor then
    local transform = actor:Abs_GetTransform()
    self:AddActorToScene(actor, transform, cameraTransform)
  end
end

function UMG_WorldViewUI_C:OnTick()
end

function UMG_WorldViewUI_C:SetPreviewByPath(modelPath, location, rotation, num)
  location = UE4.FVector(0, 0, 0)
  rotation = UE4.FVector(0, 0, 180)
  num = 2
  self.isResetRotate = false
  self.previewWorld:LockLocation(location.X, location.Y, location.Z)
  self.previewWorld:LockRotation(rotation.X, rotation.Y, rotation.Z)
  local resRequest = NRCResourceManager:LoadResAsync(self, modelPath, 255, 0, function(caller, resRequest, modelClass)
    local transform = UE4.FTransform(rotation, location)
    if not modelClass then
      Log.ErrorFormat("UMG_PetEvoImage3D_C:SetPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", modelPath or "")
      return
    end
    if 1 == num then
      if self._refActor1 then
        self.previewWorld:DestroyActor(self._refActor1)
        self._refActor1 = nil
      end
      self._refActor1 = self.previewWorld:Abs_SpawnActor(modelClass, transform)
      self._refActor1Ref = UnLua.Ref(self._refActor1)
      self._originRotation = self._refActor1:K2_GetActorRotation()
      self._refActor1.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
      self._refActor1:InitOutScene()
      local mesh = self._refActor1:GetComponentByClass(UE4.USkeletalMeshComponent)
      mesh.StreamingDistanceMultiplier = 999
      mesh.bForceMipStreaming = true
      local height = self._refActor1:GetHalfHeight()
      self._refActor1:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(location.X, location.Y, height))
    elseif 2 == num then
      if self._refActor2 then
        self.previewWorld:DestroyActor(self._refActor2)
        self._refActor2 = nil
      end
      self._refActor2 = self.previewWorld:Abs_SpawnActor(modelClass, transform)
      self._refActor2Ref = UnLua.Ref(self._refActor2)
      self._originRotation = self._refActor2:K2_GetActorRotation()
      self._refActor2.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
      self._refActor2:InitOutScene()
      local mesh = self._refActor2:GetComponentByClass(UE4.USkeletalMeshComponent)
      mesh.StreamingDistanceMultiplier = 999
      mesh.bForceMipStreaming = true
      local height = self._refActor2:GetHalfHeight()
      self._refActor2:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(location.X, location.Y, height))
    end
  end, function()
  end, nil)
end

function UMG_WorldViewUI_C:AddActorToScene(actor, transform, cameraTransform)
  self.PreviewWorld:AddActor(actor, transform)
  local camera = self.PreviewWorld:getActorByName("DefaultSceneCapture_zong")
  camera:Abs_K2_SetActorTransform_WithoutHit(cameraTransform)
end

function UMG_WorldViewUI_C:OnDeactive()
end

return UMG_WorldViewUI_C
