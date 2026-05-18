local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_Handbook_Preview3D_C = _G.NRCViewBase:Extend("UMG_Handbook_Preview3D_C")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")

function UMG_Handbook_Preview3D_C:OnConstruct()
  self._refActorIsolateWorld = nil
  self._startLocation = nil
  self._playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  self._canRotate = false
  self._originRotation = UE4.FRotator(0, 0, 0)
  self._resetRotate = false
  self._repeatSelection = false
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(3)
end

function UMG_Handbook_Preview3D_C:InitSceneCapture()
  local camera = self.previewWorld:getActorByName("DefaultSceneCapture")
  if camera then
    self.captureComponent = camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
    self.captureComponent.showOnlyActors:Clear()
    UE4.UNRCStatics.ChangeTextureToCustomSize(self.captureComponent.TextureTarget, 960, 600)
  else
    Log.Error("UMG_Handbook_Preview3D_C:InitSceneCapture  camera is nil")
  end
end

function UMG_Handbook_Preview3D_C:ResetRotate()
  self._resetRotate = true
end

function UMG_Handbook_Preview3D_C:Tick(MyGeometry, InDeltaTime)
  if self._resetRotate and self._refActorIsolateWorld then
    local offsetRot = InDeltaTime * 360
    local curRot = self._refActorIsolateWorld:K2_GetActorRotation()
    if curRot.Yaw == self._originRotation.Yaw then
      self._canRotate = true
      self._resetRotate = false
      return
    end
    if curRot.Yaw > self._originRotation.Yaw then
      if offsetRot < curRot.Yaw - self._originRotation.Yaw then
        curRot.Yaw = curRot.Yaw - offsetRot
      else
        curRot.Yaw = self._originRotation.Yaw
        self._resetRotate = false
      end
    else
      offsetRot = offsetRot * -1
      if offsetRot > curRot.Yaw - self._originRotation.Yaw then
        curRot.Yaw = curRot.Yaw - offsetRot
      else
        curRot.Yaw = self._originRotation.Yaw
        self._resetRotate = false
      end
    end
    self._canRotate = false
    self._refActorIsolateWorld:K2_SetActorRotation(curRot, false)
  end
end

function UMG_Handbook_Preview3D_C:HandleTouchMove(position)
  if self._canRotate and self._startLocation then
    local mouseLocation = position
    local deltaLocationX = mouseLocation.X - self._startLocation.X
    local deltaRot = UE4.FRotator(0, -deltaLocationX, 0)
    self.PreviewWorld:UnlockScroll(false, false, false)
    if self._refActorIsolateWorld then
      self._refActorIsolateWorld:K2_AddActorWorldRotation(deltaRot, false, nil, false)
    end
    self._startLocation = UE4.FVector2D(position.X, 0)
  end
end

function UMG_Handbook_Preview3D_C:HandleTouchStart(position)
  self._canRotate = true
  self._startLocation = UE4.FVector2D(position.X, 0)
end

function UMG_Handbook_Preview3D_C:OnTouchEnded(MyGeometry, InTouchEvent)
  self._canRotate = false
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Handbook_Preview3D_C:DeepEqual(t1, t2)
  if t1 == t2 then
    return true
  end
  if type(t1) ~= type(t2) then
    return false
  end
  if type(t1) ~= "table" then
    return t1 == t2
  end
  if #t1 ~= #t2 then
    return false
  end
  for k, v1 in pairs(t1) do
    local v2 = t2[k]
    if not self:DeepEqual(v1, v2) then
      return false
    end
  end
  for k, v2 in pairs(t2) do
    if nil == t1[k] then
      return false
    end
  end
  return true
end

function UMG_Handbook_Preview3D_C:CheckRepeatSelection(mutationType, glass_info)
  if self._repeatSelection then
    if self.mutationType == mutationType then
      return self:DeepEqual(self.GlassInfo, glass_info)
    end
    return false
  end
end

function UMG_Handbook_Preview3D_C:SetPreviewByPetBaseId(Parent, petbaseId, mutationType, glass_info, nature, successCallBack)
  self._repeatSelection = petbaseId == self.oldPetbasId
  if self:CheckRepeatSelection(mutationType, glass_info) then
    return
  end
  self.GlassInfo = glass_info
  self.mutationType = mutationType
  self.nature = nature
  self.successCallBack = successCallBack
  self.isResetRotate = false
  self.Parent = Parent
  self.oldPetbasId = petbaseId
  self:InitSceneCapture()
  if UE.UObject.IsValid(self._refActorIsolateWorld) then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.laseRot = self._refActorIsolateWorld:K2_GetActorRotation()
    self.PreviewWorld:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld = nil
  end
  if nil == petbaseId then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  local moduleConfId = petBaseConf.model_conf
  local moduleConf = _G.DataConfigManager:GetModelConf(moduleConfId)
  local modelPath = moduleConf.path
  local scale = petBaseConf.handbook_ui_percentage
  local is_boss = 1 == petBaseConf.is_boss and true or false
  self.scale = scale
  self:UnLoad()
  self.RequestModel = _G.NRCResourceManager:LoadResAsync(self, modelPath, 255, 0, self.OnLoadModuelFinished, self.OnLoadModuelFailed)
end

function UMG_Handbook_Preview3D_C:OnLoadModuelFinished(resRequest, modelClass)
  if not modelClass then
    Log.ErrorFormat("UMG_Handbook_Preview3D_C:OnLoadModuelFinished \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", resRequest or "")
    return
  end
  if UE4.UObject.IsValid(self.PreviewWorld) then
    self._refActorIsolateWorld = self.PreviewWorld:SetPreview(modelClass)
  end
  if UE4.UObject.IsValid(self._refActorIsolateWorld) then
    self._refActorIsolateWorld:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
    PetMutationUtils.PrepareMutationAssets(self._refActorIsolateWorld, self:GetMutationPetData())
    self._refActorIsolateWorld:InitOutSceneAsync(self, self.OnPetLoaded)
    self:DelaySeconds(0.2, function()
      if UE4.UObject.IsValid(self) then
        self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end)
  end
end

function UMG_Handbook_Preview3D_C:OnLoadModuelFailed(Request, Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

function UMG_Handbook_Preview3D_C:UnLoad()
  if self.RequestModel then
    _G.NRCResourceManager:UnLoadRes(self.RequestModel)
    self.RequestModel = nil
  end
end

function UMG_Handbook_Preview3D_C:OnPetLoaded(actor)
  if actor.RibbonState then
    actor.RibbonState = UE4.ENPCRibbonState.Open
  end
  self.captureComponent.showOnlyActors:Add(actor)
  local location = UE4.FVector(0, 0, -46)
  local scale = self.scale
  actor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.bForceMipStreaming = true
  mesh:SetForcedLOD(1)
  mesh.bNRCUseFixedSkelBounds = false
  mesh.bNRCAlwaysUpdateKinematicBonesToAnim = true
  mesh.bEabledAuxiliaryAnimGraphThread = false
  self.SkeletalMesh = mesh
  actor:SetActorScale3D(UE4.FVector(scale, scale, scale))
  local headPos = mesh:GetSocketLocation("Head")
  self.height = actor:GetHalfHeight() * scale + location.Z
  actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(location.X, location.Y, self.height))
  if self._repeatSelection then
    actor:K2_SetActorRotation(self.laseRot, false)
  end
  if self.Parent then
    self.Parent:SetRuler(headPos)
  end
  PetMutationUtils.DoMutation(actor, self:GetMutationPetData())
  if self.successCallBack then
    self.successCallBack(self.Parent)
  end
end

function UMG_Handbook_Preview3D_C:GetMutationPetData()
  return {
    mutation_type = self.mutationType,
    nature = self.nature or 7,
    glass_info = self.GlassInfo,
    base_conf_id = self.oldPetbasId
  }
end

function UMG_Handbook_Preview3D_C:OnDestruct()
  if UE.UObject.IsValid(self._refActorIsolateWorld) then
    self.PreviewWorld:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld = nil
  end
  if self.captureComponent then
    self.captureComponent.showOnlyActors:Clear()
  end
  self:UnLoad()
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(0)
end

return UMG_Handbook_Preview3D_C
