local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_HomePetPreview_C = _G.NRCPanelBase:Extend("UMG_HomePetPreview_C")

function UMG_HomePetPreview_C:OnConstruct()
  self.actorIsolateWorld = nil
  self.originRotation = UE4.FRotator(0, 0, 0)
  self._resetRotate = false
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(3)
end

function UMG_HomePetPreview_C:OnActive()
end

function UMG_HomePetPreview_C:OnDeactive()
end

function UMG_HomePetPreview_C:OnAddEventListener()
end

function UMG_HomePetPreview_C:SetPetPreview(parent, baseConfId, mutationType, glassInfo)
  if not parent or not baseConfId then
    return
  end
  self.parent = parent
  self:InitSceneCapture()
  if UE.UObject.IsValid(self.actorIsolateWorld) then
    self.lastRotation = self.actorIsolateWorld:K2_GetActorRotation()
    self.PreviewWorld:DestroyActor(self.actorIsolateWorld)
    self.actorIsolateWorld = nil
  end
  self.petbaseId = baseConfId
  self.mutationType = mutationType
  self.glassInfo = glassInfo
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseConfId)
  if not petBaseConf then
    return
  end
  local modelConfId = petBaseConf.model_conf
  local modelConf = _G.DataConfigManager:GetModelConf(modelConfId)
  local modelPath = modelConf.path
  self.scale = nil ~= petBaseConf.handbook_ui_percentage and petBaseConf.handbook_ui_percentage
  self:LoadPanelRes(modelPath, 255, self.OnLoadModelFinish, self.OnLoadFail, nil)
end

function UMG_HomePetPreview_C:OnLoadFail(resRequest, errMsg)
  if errMsg then
    Log.Error("UMG_HomePetPreview_C OnLoadFail" .. errMsg)
  end
end

function UMG_HomePetPreview_C:OnLoadNestModelFinish(resRequest, modelClass)
  if not modelClass then
    Log.Error("UMG_HomePetPreview_C:OnLoadNestModelFinish model path wrong [%s]", resRequest or "")
    return
  end
end

function UMG_HomePetPreview_C:OnLoadModelFinish(resRequest, modelClass)
  if not modelClass then
    Log.ErrorFormat("UMG_HomePetPreview_C:OnLoadModelFinish \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", resRequest or "")
    return
  end
  self.actorIsolateWorld = self.PreviewWorld:SetPreview(modelClass)
  self.actorIsolateWorld:InitOutSceneAsync(self, self.OnPetLoaded)
end

function UMG_HomePetPreview_C:InitSceneCapture()
  local camera = self.PreviewWorld:getActorByName("DefaultSceneCapture")
  self.captureComponent = camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.captureComponent.showOnlyActors:Clear()
  UE4.UNRCStatics.ChangeTextureToCustomSize(self.captureComponent.TextureTarget, 960, 600)
end

function UMG_HomePetPreview_C:Tick(MyGeometry, InDeltaTime)
end

function UMG_HomePetPreview_C:OnPetLoaded(actor)
  if not actor then
    Log.Error("no valid actor UMG_HomePetPreview_C:OnPetLoaded")
    return
  end
  if actor.RibbonState then
    actor.RibbonState = UE4.ENPCRibbonState.Open
  end
  self.captureComponent.showOnlyActors:Add(actor)
  local location = UE4.FVector(0, 0, -46)
  local scale = self.scale
  actor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  if mesh then
    mesh.bForceMipStreaming = true
    mesh:SetForcedLOD(1)
    mesh.bNRCUseFixedSkelBounds = false
    mesh.bNRCAlwaysUpdateKinematicBonesToAnim = true
    mesh.bEabledAuxiliaryAnimGraphThread = false
    self.skeletalMesh = mesh
  end
  actor:SetActorScale3D(UE4.FVector(scale, scale, scale))
  local headPos = mesh:GetSocketLocation("Head")
  self.height = actor:GetHalfHeight() * scale + location.Z
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraRotater = localPlayer:GetUEController().playerCameraManager:GetCameraRotation()
  local cameraForwardVec = UE4.UKismetMathLibrary.GetForwardVector(cameraRotater)
  actor:Abs_K2_SetActorLocationAndRotation_WithoutHit(UE4.FVector(location.X, location.Y, self.height), UE4.FRotator())
  PetMutationUtils.DoMutation(actor, self:GetMutationPetData())
end

function UMG_HomePetPreview_C:GetMutationPetData()
  return {
    mutation_type = self.mutationType,
    nature = 7,
    glass_info = self.glassInfo,
    base_conf_id = self.petbaseId
  }
end

function UMG_HomePetPreview_C:HandleTouchStart(position)
  Log.Debug("HandleTouchStart invoked")
end

function UMG_HomePetPreview_C:HandleTouchMove(position)
  Log.Debug("HandleTouchMove invoked")
end

function UMG_HomePetPreview_C:OnTouchEnded(MyGeometry, InTouchEvent)
end

function UMG_HomePetPreview_C:OnDestruct()
  if UE.UObject.IsValid(self.actorIsolateWorld) then
    self.PreviewWorld:DestroyActor(self.actorIsolateWorld)
    self.actorIsolateWorld = nil
  end
  if self.captureComponent then
    self.captureComponent.showOnlyActors:Clear()
  end
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(0)
end

return UMG_HomePetPreview_C
