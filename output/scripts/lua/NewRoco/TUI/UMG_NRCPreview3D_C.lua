local UMG_NRCPreview3D_C = _G.NRCViewBase:Extend("UMG_NRCPreview3D_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_NRCPreview3D_C:OnConstruct()
  self._refActorIsolateWorld = nil
  self._startLocation = nil
  self._playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  self._canRotate = false
  self._originRotation = nil
  self:SetPreviewByID(1400042)
  if nil == _G.DebugPreview then
    _G.DebugPreview = {}
  end
  table.insert(_G.DebugPreview, self)
end

function UMG_NRCPreview3D_C:Tick(MyGeometry, InDeltaTime)
  if self.PreviewWorld.m_unlock_z and self._refActorIsolateWorld then
    local offsetRot = InDeltaTime * 360
    local curRot = self._refActorIsolateWorld:K2_GetActorRotation()
    if curRot.Yaw == self._originRotation.Yaw then
      self.PreviewWorld.m_unlock_z = false
      return
    end
    if curRot.Yaw > self._originRotation.Yaw then
      if offsetRot < curRot.Yaw - self._originRotation.Yaw then
        curRot.Yaw = curRot.Yaw - offsetRot
      else
        curRot.Yaw = self._originRotation.Yaw
        self.PreviewWorld.m_unlock_z = false
      end
    else
      offsetRot = offsetRot * -1
      if offsetRot > curRot.Yaw - self._originRotation.Yaw then
        curRot.Yaw = curRot.Yaw - offsetRot
      else
        curRot.Yaw = self._originRotation.Yaw
        self.PreviewWorld.m_unlock_z = false
      end
    end
    self._refActorIsolateWorld:K2_SetActorRotation(curRot, false)
  end
end

function UMG_NRCPreview3D_C:HandleTouchMove(position)
  if self._canRotate then
    local mouseLocation = position
    local deltaLocationX = mouseLocation.X - self._startLocation.X
    local deltaRot = UE4.FRotator(0, -deltaLocationX, 0)
    self.PreviewWorld:UnlockScroll(false, false, false)
    if self._refActorIsolateWorld then
      self._refActorIsolateWorld:K2_AddActorWorldRotation(deltaRot)
    end
    self._startLocation = UE4.FVector2D(position.X, 0)
  end
end

function UMG_NRCPreview3D_C:HandleTouchStart(position)
  self._canRotate = true
  self._startLocation = UE4.FVector2D(position.X, 0)
end

function UMG_NRCPreview3D_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self._canRotate = false
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_NRCPreview3D_C:SetPreviewByPath(modelPath)
  self.isResetRotate = false
  if self._refActorIsolateWorld then
    self.PreviewWorld:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld = nil
  end
  self:LoadPanelRes(modelPath, 255, self.OnPetClassLoaded, nil, nil)
end

function UMG_NRCPreview3D_C:OnPetClassLoaded(resRequest, modelClass)
  if not modelClass then
    Log.ErrorFormat("UMG_NRCPreview3D_C:SetPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175.")
    return
  end
  self._refActorIsolateWorld = self.PreviewWorld:SetPreview(modelClass)
  self._originRotation = self._refActorIsolateWorld:K2_GetActorRotation()
  self._refActorIsolateWorld.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
  self._refActorIsolateWorld:InitOutScene()
  local mesh = self._refActorIsolateWorld:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh:SetLightingChannels(false, true, false)
  mesh.bForceMipStreaming = true
end

function UMG_NRCPreview3D_C:SetPreviewByID(modelID)
  local modelConf = _G.DataConfigManager:GetModelConf(modelID)
  self:SetPreviewByPath(modelConf.path)
end

function UMG_NRCPreview3D_C:OnDestruct()
  if self._refActorIsolateWorld then
    self.PreviewWorld:DestroyActor(self._refActorIsolateWorld)
    local remainActorsNum = self.PreviewWorld.SpawnedActors:Length()
    self._refActorIsolateWorld = nil
  end
end

return UMG_NRCPreview3D_C
