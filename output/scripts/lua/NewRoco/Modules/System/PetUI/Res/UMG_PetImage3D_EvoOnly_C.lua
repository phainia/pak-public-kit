local UMG_PetImage3D_EvoOnly_C = _G.NRCPanelBase:Extend("UMG_PetImage3D_EvoOnly_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_PetImage3D_EvoOnly_C:OnActive(arg)
  _G.NRCAudioManager:BatchSetState("UI_Music;UI_Music;Music_Collect;None;UI_Type;None")
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(1)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.petID = arg.petID
  self.evoPetID = arg.evoPetID
  self.baseInfo = arg.baseInfo
  self.Action = arg.Action
  self._refActorIsolateWorld = nil
  self._evoTargetActor = nil
  self:InitResourcePath()
  self:InitConfig()
  self:InitCineCameraActor()
  self:InitPetModel(self.petID)
end

function UMG_PetImage3D_EvoOnly_C:OnDeactive()
  _G.NRCAudioManager:BatchSetState("UI_Music;None")
  self:CancelDelay()
  if self.loadResRequest then
    for key, request in pairs(self.loadResRequest) do
      NRCResourceManager:UnLoadRes(request)
      self.loadResRequest[key] = nil
    end
  end
  self:StopEvoSkill()
  self:StopPetAudio()
end

function UMG_PetImage3D_EvoOnly_C:OnDestruct()
  self.BgMeshComp = nil
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(0)
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) then
    if self._refActorIsolateWorld.Mesh and UE4.UObject.IsValid(self._refActorIsolateWorld.Mesh) then
      self._refActorIsolateWorld.Mesh:ReleaseResource()
      self._refActorIsolateWorld.Mesh:Release()
    end
    self.PetWorldView:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld:Release()
    if self.SkeletalMesh then
      self.SkeletalMesh:Release()
      self.SkeletalMesh = nil
    end
  end
  if self.BackgroundPlate then
    self.BackgroundPlate:Release()
  end
  if self.CineCamera and UE.UObject.IsValid(self.CineCamera) and UE.UObject.IsValid(self.PetWorldView) then
    self.PetWorldView:DestroyActor(self.CineCamera)
    self.CineCamera = nil
  end
  if self.targetPetModel and UE.UObject.IsValid(self.targetPetModel) and UE.UObject.IsValid(self.PetWorldView) then
    self.PetWorldView:DestroyActor(self.targetPetModel)
    self.targetPetModel = nil
  end
  _G.NRCAudioManager:EndRegisterSpecialPet(self.AudioId)
  _G.NRCAudioManager:EndRegisterSpecialPet(self.AudioIdEvo)
  self.evolutionTypeMaterial = nil
  self.evolutionTypeMaterial_Ref = nil
  self.evolutionTypeIcon = nil
  self.evolutionBgAnim = nil
  self.skillClass = nil
  self.skillClassRef = nil
  self.MainCameraActor = nil
  self.EvoSkillAnim01 = nil
  if self.MaterialInstanceNew then
    self.MaterialInstanceNew:Release()
  end
  if self.MaterialInstance then
    self.MaterialInstance:Release()
  end
  if self.MaterialInstanceNewBottom then
    self.MaterialInstanceNewBottom:Release()
  end
  self.MaterialInstance_Ref = nil
  self.MaterialInstanceNewBottom_Ref = nil
  self:CancelDelay()
  self:SetAnimList(nil, nil)
  self.bPetLoaded = false
  self.LuopanOut:Release()
end

function UMG_PetImage3D_EvoOnly_C:InitResourcePath()
  self.G6_Evolution_UI_FX01 = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Evolution/G6_Evolution_UI_FX01.G6_Evolution_UI_FX01_C'"
  self.G6_Evolution_UI_OutFx = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Evolution/G6_Evolution_UI_OutFx.G6_Evolution_UI_OutFx_C'"
  self.G6_Evolution_Anim01 = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Evolution/G6_Evolution_Anim01.G6_Evolution_Anim01_C'"
  self.OpenDetailsPlaySkillPath = "SkillBlueprint'/Game/NewRoco/Modules/System/PetUI/Raw/G6/G6_OpenPetInfo_UI.G6_OpenPetInfo_UI_C'"
  self.CloseDetailsPlaySkillPath = "SkillBlueprint'/Game/NewRoco/Modules/System/PetUI/Raw/G6/G6_ClosePetInfo_UI.G6_ClosePetInfo_UI_C'"
end

function UMG_PetImage3D_EvoOnly_C:InitConfig()
  if self.petID and self.evoPetID then
    self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petID)
    self.PetEvoConf = _G.DataConfigManager:GetPetbaseConf(self.evoPetID)
  end
end

function UMG_PetImage3D_EvoOnly_C:InitCineCameraActor()
  local CineCameraActor = self.PetWorldView:getActorByName("CineCamera_1")
  self.CineCamera = CineCameraActor
  if CineCameraActor then
    self.CineSceneComponent = CineCameraActor:GetComponentByClass(UE4.UCineCameraComponent)
  end
  local CameraActor = self.PetWorldView:getActorByName("MainCamera")
  self.PetWorldView:SetCameraActor(CameraActor)
  self.MainCameraActor = self.PetWorldView:getActorByName("MainCamera")
  self.MainCameraPosActor = self.PetWorldView:getActorByName("CameraPosActor")
end

function UMG_PetImage3D_EvoOnly_C:InitPetModel()
  local modelPath = self:GetModelPath(self.petID)
  if modelPath and "" ~= modelPath then
    self:SetPath(modelPath, self.baseInfo)
  end
end

function UMG_PetImage3D_EvoOnly_C:GetModelPath(petBaseID)
  if petBaseID then
    local petBaseCfg = _G.DataConfigManager:GetPetbaseConf(petBaseID)
    if petBaseCfg then
      local model_id = petBaseCfg.model_conf
      if model_id then
        local modelConf = _G.DataConfigManager:GetModelConf(model_id)
        if modelConf then
          return modelConf.path
        end
      end
    end
  end
  return nil
end

function UMG_PetImage3D_EvoOnly_C:SetPath(modelPath, petData)
  local showOnlyActors
  do
    local shadowCapture = self.PetWorldView:getActorByName("CWLP_SceneCapture2D")
    if shadowCapture then
      local captureComponent = shadowCapture:GetComponentByClass(UE4.USceneCaptureComponent2D)
      showOnlyActors = captureComponent.ShowOnlyActors
    end
  end
  self.isResetRotate = false
  if self._refActorIsolateWorld then
    if showOnlyActors then
      showOnlyActors:Clear()
    end
    if UE4.UObject.IsValid(self._refActorIsolateWorld) then
      self.PetWorldView:DestroyActor(self._refActorIsolateWorld)
    end
    self._refActorIsolateWorld = nil
  end
  Log.Debug(modelPath, 6, "UMG_PetImage3D_EvoOnly_C:SetPath")
  local isFirstLoadBg = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.IsFirstLoadBackground)
  if nil == isFirstLoadBg then
    isFirstLoadBg = true
  end
  Log.Debug(isFirstLoadBg, 6, "PetUIModuleCmd.IsFirstLoadBackground")
  if self.modelPathLoadReq then
    _G.NRCResourceManager:UnLoadRes(self.modelPathLoadReq)
    self.modelPathLoadReq = nil
  end
  if isFirstLoadBg then
    local modelClass = self.module:GetRes(modelPath, self.ModuleName)
    if modelClass then
      self:PetModelLoadSucceed(nil, modelClass)
    else
      self.modelPathLoadReq = self:LoadPanelRes(modelPath, 255, self.PetModelLoadSucceed, nil, nil)
    end
  else
    self.modelPathLoadReq = self:LoadPanelRes(modelPath, 255, self.PetModelLoadSucceed, nil, nil)
  end
end

function UMG_PetImage3D_EvoOnly_C:PetModelLoadSucceed(resRequest, modelClass)
  if not modelClass then
    Log.ErrorFormat("UMG_PetImage3D_EvoOnly_C:SetPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", resRequest or "")
    return
  end
  Log.Debug("UMG_PetImage3D_EvoOnly_C:PetModelLoadSucceed")
  if UE4.UObject.IsValid(self.targetPetModel) then
    self.PetWorldView:DestroyActor(self.targetPetModel)
    self.targetPetModel = nil
  end
  if self._refActorIsolateWorld then
    self.PetWorldView:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld = nil
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 1.5)
  if not self.PetLocation then
    self.PetLocation = UE4.FVector(0, 0, 0)
  end
  local fTransfom = UE4.FTransform(quat, self.PetLocation, UE4.FVector(1, 1, 1))
  self._refActorIsolateWorld = self.PetWorldView:SpawnActor(modelClass, fTransfom)
  if self.baseInfo then
    self._refActorIsolateWorld:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
    PetMutationUtils.PrepareMutationAssets(self._refActorIsolateWorld, self.baseInfo)
  end
  _G.NRCAudioManager:SetEmitterSwitch("Pet_Switch", "Pet_Show", self._refActorIsolateWorld)
  self._refActorIsolateWorld:SetIsPlayerModel(true)
  self.bPetLoaded = false
  self._refActorIsolateWorld:InitOutSceneAsync(self, self.OnPetLoaded)
  self:SetBagColourByUnitType()
  if self.PetBaseConf then
    local modelScale = self.PetBaseConf.petpage_ui_percentage and self.PetBaseConf.petpage_ui_percentage > 0 and self.PetBaseConf.petpage_ui_percentage or 1
    self:SetModelScale(modelScale)
    if self.PetBaseConf.petpage_capsule_offset and next(self.PetBaseConf.petpage_capsule_offset) then
      local offsetConf = self.PetBaseConf.petpage_capsule_offset
      local modelOffset = UE4.FVector(offsetConf[1] or 0, offsetConf[2] or 0, offsetConf[3] or 0)
      self:SetModelOffset(modelOffset, modelScale)
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:OnPetLoaded(actor)
  if not self.PetWorldView then
    return
  end
  self:SetShowOrHidePet(true)
  Log.Debug("UMG_PetImage3D_EvoOnly_C:OnPetLoaded")
  if actor.RibbonState then
    actor.RibbonState = UE4.ENPCRibbonState.Open
  end
  self.bPetLoaded = true
  actor.IkOverride = false
  actor:SetSelfControlSignificance(true, UE.ESignificanceValue.Highest)
  _G.NRCAudioManager:RegisterSpecialPet(self.AudioId, actor)
  _G.NRCAudioManager:SetListenerToSelf(actor, "SpecialPet")
  local SKMComponent = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  SKMComponent.bNRCUseFixedSkelBounds = false
  SKMComponent.bNRCAlwaysUpdateKinematicBonesToAnim = true
  SKMComponent.bEabledAuxiliaryAnimGraphThread = false
  local height = actor:GetHalfHeight()
  local PetLocation = UE4.FVector(0, 0, 0)
  if self.NotChangeAnim then
    PetLocation = UE4.FVector(0, 0, 0)
  end
  PetLocation.Z = PetLocation.Z + height
  Log.Debug(PetLocation, "UMG_PetImage3D_EvoOnly_C:OnPetLoaded")
  actor:Abs_K2_SetActorLocation_WithoutHit(PetLocation)
  self:UpdateEvoPetMesh(actor)
  if self.PetBaseConf and self.baseInfo then
    PetMutationUtils.DoMutation(actor, self.baseInfo)
  end
  self.idleAnimLen = self:GetAnimLengthByName("Idle")
  self.maxAnimListIdleTime = math.random(5, 10) * self.idleAnimLen
  if not self.evolutionTypeIcon then
    self:GetEvolutionTypeIcon()
  end
  if self.evolutionTypeIcon then
    self.evolutionTypeIcon:SetActorHiddenInGame(not self.bSetPathEvo)
  end
  if self.evolutionBgTex3 then
    self.evolutionBgTex3:SetActorHiddenInGame(not self.bSetPathEvo)
  end
  if self.evolutionBgAnim then
    self.evolutionBgAnim:SetActorHiddenInGame(not self.bSetPathEvo)
  end
  local showOnlyActors
  do
    local shadowCapture = self.PetWorldView:getActorByName("CWLP_SceneCapture2D")
    if shadowCapture then
      local captureComponent = shadowCapture:GetComponentByClass(UE4.USceneCaptureComponent2D)
      showOnlyActors = captureComponent.ShowOnlyActors
    end
  end
  if showOnlyActors then
    showOnlyActors:Add(actor)
  end
  if showOnlyActors and self._TypeFx then
    showOnlyActors:Add(self._TypeFx)
  end
  UE4.UNRCStatics.SetCineCameraInfo(actor, self.CineCamera, self.CineSceneComponent)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsPlayPetSkill, false)
  self:SetModelLocation()
  self:DelaySeconds(0.1, function()
    self:SetShowOrHidePet(false)
    self:OnPreEvo()
  end)
end

function UMG_PetImage3D_EvoOnly_C:SetBagColourByUnitType()
  if not self.PetWorldView then
    return
  end
  self.BackgroundPlate = self.PetWorldView:getActorByName("TestBg_2")
  if self.BackgroundPlate and self.PetBaseConf then
    local modelFxType = self.PetBaseConf.unit_type[1]
    if modelFxType < Enum.SkillDamType.SDT_COMMON then
      modelFxType = Enum.SkillDamType.SDT_COMMON
    end
    if self.OldModelFxType == modelFxType then
      return
    end
    local isFirstLoadBg = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.IsFirstLoadBackground)
    if nil == isFirstLoadBg then
      isFirstLoadBg = true
    end
    local Path = _G.DataConfigManager:GetSkillColorConf(modelFxType).JL_background_colour
    self.Path_1 = _G.DataConfigManager:GetSkillColorConf(modelFxType).JL_background_clear
    self.OldModelFxType = modelFxType
    local module = NRCModuleManager:GetModule("BattlePassModule")
    if module:HasPanel("BattlePassPetDetail") then
      self.mat_bj = self.module:GetRes(Path, self.ModuleName)
      local mat_bj1 = self.module:GetRes(self.Path_1, self.ModuleName)
      if self.mat_bj and mat_bj1 then
        self:OnLoadBackgroundClearSucc(nil, mat_bj1)
        return
      end
    end
    if Path then
      if isFirstLoadBg then
        self.mat_bj = self.module:GetRes(Path, self.ModuleName)
        local mat_bj1 = self.module:GetRes(self.Path_1, self.ModuleName)
        if self.mat_bj and mat_bj1 then
          self:OnLoadBackgroundClearSucc(nil, mat_bj1)
        else
          self:LoadPanelRes(Path, 255, self.OnLoadBackgroundColorSucc, self.OnLoadBackgroundClearFailed, nil)
        end
      else
        self:LoadPanelRes(Path, 255, self.OnLoadBackgroundColorSucc, self.OnLoadBackgroundClearFailed, nil)
      end
    else
      self:OnLoadBackgroundClearFailed()
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:OnLoadBackgroundColorSucc(resRequest, mat_bj)
  self.mat_bj = mat_bj
  self:LoadPanelRes(self.Path_1, 255, self.OnLoadBackgroundClearSucc, self.OnLoadBackgroundClearFailed, nil)
end

function UMG_PetImage3D_EvoOnly_C:OnLoadBackgroundClearSucc(resRequest, mat_bj_1)
  if mat_bj_1:IsA(UE4.UMaterialInstanceConstant) then
    local MeshComponent = self.BackgroundPlate:GetComponentByClass(UE4.UStaticMeshComponent)
    self.BgMeshComp = MeshComponent
    if self.MaterialInstance then
      self.MaterialInstanceNewBottom = self.PetWorldView:CreateDynamicMaterialInstance(self.mat_bj, "")
      self.MaterialInstanceNewBottom_Ref = self.MaterialInstanceNewBottom and UnLua.Ref(self.MaterialInstanceNewBottom)
      self.MaterialInstanceNew = self.PetWorldView:CreateDynamicMaterialInstance(mat_bj_1, "")
      self.MaterialInstanceNew.AdditionalMaterials:Clear()
      self.MaterialInstanceNew.AdditionalMaterials:Add(self.MaterialInstance)
      self.IsGradient = true
      MeshComponent:SetMaterial(0, self.MaterialInstanceNew)
    else
      self.MaterialInstance = self.PetWorldView:CreateDynamicMaterialInstance(self.mat_bj, "")
      self.MaterialInstance_Ref = self.MaterialInstance and UnLua.Ref(self.MaterialInstance)
      self.MaterialInstance_1 = self.PetWorldView:CreateDynamicMaterialInstance(mat_bj_1, "")
      if self.MaterialInstance then
        self.MaterialInstance.AdditionalMaterials:Clear()
      end
      MeshComponent:SetMaterial(0, self.MaterialInstance_1)
    end
    UE4.UNRCStatics.MarkRenderStateDirty(self.BgMeshComp)
  else
    self:LogError("\230\179\168\230\132\143\239\188\140\229\138\160\232\189\189\232\181\132\230\186\144\231\188\186\229\176\145\232\181\132\230\186\144\229\144\141\229\173\151:", self.Path_1)
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsFirstLoadBackground, false)
  self.mat_bj = nil
  self.Path_1 = nil
end

function UMG_PetImage3D_EvoOnly_C:OnLoadBackgroundClearFailed(resRequest, mat_bj_1)
  Log.Error("\231\178\190\231\129\181\232\131\140\230\153\175\229\138\160\232\189\189\229\164\177\232\180\165\228\186\134\239\188\140\228\189\134\230\152\175\232\191\152\230\152\175\229\133\129\232\174\184\230\137\147\229\188\128\231\149\140\233\157\162\239\188\140UMG_PetImage3D_EvoOnly_C:OnLoadBackgroundClearFailed")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsFirstLoadBackground, false)
  self.mat_bj = nil
  self.Path_1 = nil
end

function UMG_PetImage3D_EvoOnly_C:SetModelLocation(_location)
  local location = self._startActorLocation
  if _location then
    location = _location
  end
  if not location then
    return
  end
  if not self._refActorIsolateWorld then
    return
  end
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) then
    self._refActorIsolateWorld:Abs_K2_SetActorLocation_WithoutHit(location)
  end
end

function UMG_PetImage3D_EvoOnly_C:SetModelScale(_scale)
  self.Scale = _scale or 1
  local scale = _scale or 1
  if self._refActorIsolateWorld then
    self._refActorIsolateWorld:SetActorScale3D(UE4.FVector(scale, scale, scale))
    local height = self._refActorIsolateWorld:GetHalfHeight() * scale
    local PetLocation = UE4.FVector(0, 0, 0)
    PetLocation.Z = PetLocation.Z + height
    self._refActorIsolateWorld:Abs_K2_SetActorLocation_WithoutHit(PetLocation)
    self._startActorLocation = PetLocation
    Log.Debug(PetLocation, "UMG_PetImage3D_EvoOnly_C:SetModelScale")
  end
end

function UMG_PetImage3D_EvoOnly_C:SetEvoModelOffSetInfo()
  if self.PetEvoConf then
    local modelScale = self.PetEvoConf.petpage_ui_percentage and self.PetEvoConf.petpage_ui_percentage > 0 and self.PetEvoConf.petpage_ui_percentage or 1
    local heightMax = self.PetEvoConf.height_high
    local heightMin = self.PetEvoConf.height_low
    if heightMax and heightMin then
      local scale = 0.33
      local height = (heightMax - heightMin) * scale + heightMin
      local heightModelScale = PetMutationUtils.GetHeightModelScale(self.evoPetID, height)
      modelScale = modelScale * heightModelScale
    end
    self:SetEvoModelScale(modelScale)
    PetMutationUtils.DoMutation(self._evoTargetActor, self.baseInfo)
    if self.PetEvoConf.petpage_capsule_offset and next(self.PetEvoConf.petpage_capsule_offset) then
      local offsetConf = self.PetEvoConf.petpage_capsule_offset
      local modelOffset = UE4.FVector(offsetConf[1] or 0, offsetConf[2] or 0, offsetConf[3] or 0)
      self:SetEvoModelOffset(modelOffset, modelScale)
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:SetModelOffset(_offset, modelScale)
  if self._refActorIsolateWorld then
    local height = (self._refActorIsolateWorld:GetHalfHeight() + _offset.Z) * (modelScale or 1)
    local CurPetLocation = self._refActorIsolateWorld:Abs_K2_GetActorLocation()
    local NewPetLocation = UE4.FVector(CurPetLocation.X + _offset.X, CurPetLocation.Y + _offset.Y, height)
    self._refActorIsolateWorld:Abs_K2_SetActorLocation_WithoutHit(NewPetLocation)
    self._startActorLocation = NewPetLocation
  end
end

function UMG_PetImage3D_EvoOnly_C:SetEvoModelOffset(_offset, modelScale)
  if self._evoTargetActor then
    local height = (self._evoTargetActor:GetHalfHeight() + _offset.Z) * (modelScale or 1)
    local CurPetLocation = self._evoTargetActor:Abs_K2_GetActorLocation()
    local NewPetLocation = UE4.FVector(CurPetLocation.X + _offset.X, CurPetLocation.Y + _offset.Y, height)
    self._evoTargetActor:Abs_K2_SetActorLocation_WithoutHit(NewPetLocation)
    self._startActorLocation = NewPetLocation
  end
end

function UMG_PetImage3D_EvoOnly_C:SetEvoModelScale(_scale)
  local scale = _scale or 1
  if self._evoTargetActor then
    self._evoTargetActor:SetActorScale3D(UE4.FVector(scale, scale, scale))
  end
end

function UMG_PetImage3D_EvoOnly_C:SetShowOrHidePet(_IsHide)
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) then
    self._refActorIsolateWorld:SetActorHiddenInGame(_IsHide)
  end
end

function UMG_PetImage3D_EvoOnly_C:SetAnimList(_animList, _idleCount, _randomAnimList)
  if not _idleCount or _idleCount <= 0 then
    _idleCount = 1
  end
  self.curAnimListTime = 0
  self.curAnimListIndex = 1
  self.animList = _animList
  self.randomAnimList = {
    "Alert",
    "Happy",
    "Fear",
    "Relax",
    "Shock",
    "Sad"
  }
  if self.idleAnimLen == nil then
    self.idleAnimLen = self:GetAnimLengthByName("Idle")
  end
  self.maxAnimListIdleTime = math.random(5, 10) * self.idleAnimLen
end

function UMG_PetImage3D_EvoOnly_C:GetAnimLengthByName(_name)
  if UE4.UObject.IsValid(self._refActorIsolateWorld) and _name then
    local animComp = self._refActorIsolateWorld:GetAnimComponent()
    if animComp then
      return animComp:GetAnimLengthByName(_name)
    end
  end
  return 0
end

function UMG_PetImage3D_EvoOnly_C:StopPetAudio()
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) then
    _G.NRCAudioManager:StopAllForActor(self._refActorIsolateWorld)
  end
end

function UMG_PetImage3D_EvoOnly_C:HidePetBeforeCloseAnim()
  local caster = self._refActorIsolateWorld
  if UE.UObject.IsValid(caster) then
    caster:SetVisible(false)
  end
end

function UMG_PetImage3D_EvoOnly_C:OnTick(InDeltaTime)
  if self.skillCamera and self.bEvoing then
    if UE.UObject.IsValid(self.skillCamera) then
      self.skillCamVec = self.skillCamera:Abs_GetTransform()
    end
    if UE.UObject.IsValid(self.MainCameraActor) then
      self.MainCameraActor:Abs_K2_SetActorTransform_WithoutHit(self.skillCamVec)
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:OnPreEvo()
  self.MainCameraTransform = self.MainCameraActor.RootComponent:GetRelativeTransform()
  self:PlayAlertAnim()
  self:ChangeEvoLight(true)
  self:LoadEvoTargetModel()
  self:LoadPrepareEvoSkill1()
  self:DelaySeconds(1, function()
    self:StartEvolution()
  end)
end

function UMG_PetImage3D_EvoOnly_C:StartEvolution()
  self.bEvoing = true
  self._refActorIsolateWorld:PlayAnimByName("Happy", 1, 0, 0, 0, 1)
  self:LoadPrepareEvoSkill2()
end

function UMG_PetImage3D_EvoOnly_C:PlayAlertAnim()
  if self.bEvoing then
    return
  end
  local EmoteDuration = 1
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) then
    local Anim = self._refActorIsolateWorld.RocoAnim:GetAnimSequenceByName("Alert")
    if Anim then
      EmoteDuration = Anim:GetPlayLength()
    end
    self._refActorIsolateWorld:PlayAnimByName("Alert")
  end
  local RandTime = math.random(2, 5)
  self:DelaySeconds(EmoteDuration * RandTime, self.PlayAlertAnim, self)
end

function UMG_PetImage3D_EvoOnly_C:ChangeEvoLight(bEvoStart, bEvoSucc)
  if bEvoStart then
    self:ChangeLight_1(true)
  elseif true == bEvoSucc then
    self:CloseAllLight()
  else
    self:ChangeLight_1(false)
  end
end

function UMG_PetImage3D_EvoOnly_C:LoadEvoTargetModel()
  if self.PetEvoConf and self.PetEvoConf.model_conf then
    local targetModelId = self.PetEvoConf.model_conf
    local targetModelPath = _G.DataConfigManager:GetModelConf(targetModelId).path
    if targetModelPath then
      self:LoadPanelRes(targetModelPath, 255, self.LoadEvoPetSucceed, nil, nil)
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:LoadEvoPetSucceed(resRequest, targetModelClass)
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 1.5)
  local trans = UE4.FTransform(quat, UE4.FVector(0.0, 0.0, 0.0), UE4.FVector(1, 1, 1))
  if UE.UObject.IsValid(self.SkeletalMesh) and self._refActorIsolateWorld then
    self.SkeletalMesh:K2_SetWorldRotation(UE4.FRotator(0, 20, 0), false, nil, false)
  end
  if targetModelClass then
    self._evoTargetActor = self.PetWorldView:SpawnActor(targetModelClass, trans)
    _G.NRCAudioManager:SetEmitterSwitch("Pet_Switch", "Pet_Show", self._evoTargetActor)
    self._evoTargetActor:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
    if self.baseInfo then
      PetMutationUtils.PrepareMutationAssets(self._evoTargetActor, self.baseInfo)
    end
    self._evoTargetActor:InitOutSceneAsync(self, self.OnEvoPetLoaded)
    self._evoTargetActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(0, 0, 0))
  end
end

function UMG_PetImage3D_EvoOnly_C:OnEvoPetLoaded(actor)
  actor.IkOverride = false
  actor:SetSelfControlSignificance(true, UE.ESignificanceValue.Highest)
  actor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(0, 0, 0))
  actor:SetActorHiddenInGame(true)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh:SetForcedLOD(1)
  mesh.bEnableUpdateRateOptimizations = false
  mesh.StreamingDistanceMultiplier = 999
  mesh.bNeverDistanceCull = true
  mesh.bForceMipStreaming = true
  _G.NRCAudioManager:RegisterSpecialPet(self.AudioIdEvo, actor)
  _G.NRCAudioManager:SetListenerToSelf(actor, "SpecialPet")
  local SKMComponent = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  SKMComponent.bNRCUseFixedSkelBounds = false
  SKMComponent.bNRCAlwaysUpdateKinematicBonesToAnim = true
  SKMComponent.bEabledAuxiliaryAnimGraphThread = false
end

function UMG_PetImage3D_EvoOnly_C:ChangeLight_1(bStart)
  local DarkVolumeBP = self.PetWorldView:getActorByName("BP_DarkVolume_3")
  if bStart then
    DarkVolumeBP:Start()
  else
    DarkVolumeBP:End()
  end
end

function UMG_PetImage3D_EvoOnly_C:CloseAllLight()
  self:ChangeLight_1(false)
end

function UMG_PetImage3D_EvoOnly_C:EvoPlayPetSkill(bStart, bPlay)
  if bPlay then
    if bStart then
      self:PlayPetSkillAsync(self.CloseDetailsPlaySkill, self.CloseDetailsPlaySkillPath, true)
    else
      self:PlayPetSkillAsync(self.OpenDetailsPlaySkill, self.OpenDetailsPlaySkillPath, true)
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:GetEvolutionTypeIcon()
  local evoTypeImage = self.PetWorldView:getActorByName("CWLP_BGIcon")
  if evoTypeImage then
    local meshCmpt = evoTypeImage:GetComponentByClass(UE4.UMeshComponent)
    local meshcomponent = evoTypeImage:GetComponentByClass(UE4.UStaticMeshComponent)
    local sourceMaterial = meshcomponent:GetMaterial(0)
    local dyMaterial = meshcomponent:CreateDynamicMaterialInstance(0, sourceMaterial)
    self.evolutionTypeMaterial = dyMaterial
    self.evolutionTypeMaterial_Ref = self.evolutionTypeMaterial and UnLua.Ref(self.evolutionTypeMaterial)
  end
  self.evolutionTypeIcon = evoTypeImage
  self.evolutionBgAnim = self.PetWorldView:getActorByName("CWLP_CycleAnim")
end

function UMG_PetImage3D_EvoOnly_C:LoadPrepareEvoSkill1()
  self:LoadPanelRes(self.G6_Evolution_UI_FX01, 255, self.PlayPrepareEvoSkill1, nil, nil)
end

function UMG_PetImage3D_EvoOnly_C:PlayPrepareEvoSkill1(resRequest, asset)
  local Caster = self._refActorIsolateWorld
  if asset and Caster and UE4.UObject.IsValid(Caster) then
    local skillComponent = Caster.RocoSkill
    if skillComponent and UE4.UObject.IsValid(skillComponent) then
      local skillObj = skillComponent:FindOrAddSkillObj(asset)
      if skillObj then
        skillObj:SetCaster(Caster)
        skillObj:SetPassive(false)
        self:StopEvoSkill()
        self.EvoFx1 = skillObj:GetBlackboard():GetValueAsObject("Fx1")
        self.EvoFx2 = skillObj:GetBlackboard():GetValueAsObject("Fx2")
        Caster.RocoSkill:PlaySkill(skillObj)
      end
    end
  end
end

function UMG_PetImage3D_EvoOnly_C:LoadPrepareEvoSkill2()
  self:LoadPanelRes(self.G6_Evolution_UI_OutFx, 255, self.PlayPrepareEvoSkill2, nil, nil)
  self:LoadPanelRes(self.G6_Evolution_Anim01, 255, self.SetEvoSkillAnim01, nil, nil)
end

function UMG_PetImage3D_EvoOnly_C:PlayPrepareEvoSkill2(resRequest, asset)
  local Caster = self._refActorIsolateWorld
  if Caster and UE4.UObject.IsValid(Caster) and asset and Caster then
    local skillObj = Caster.RocoSkill:FindOrAddSkillObj(asset)
    skillObj:SetCaster(Caster)
    skillObj:SetPassive(false)
    self:StopEvoSkill()
    skillObj:RegisterEventCallback("ShowWhiteUI", self, self.ShowWhiteUI)
    skillObj:RegisterEventCallback("End", self, self.LoadEvoSkill)
    Caster.RocoSkill:LoadAndPlaySkill(skillObj)
  end
end

function UMG_PetImage3D_EvoOnly_C:ShowWhiteUI()
  self.EvoWhiteScreen:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local bkg = self.EvoWhiteScreen.dianji
  if bkg then
    bkg:SetRenderOpacity(1)
  end
end

function UMG_PetImage3D_EvoOnly_C:HideWhiteUI()
  self.EvoWhiteScreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetImage3D_EvoOnly_C:PlayWhiteUIAnim()
  self.EvoWhiteScreen:PlayAnimation(self.EvoWhiteScreen.Anim)
end

function UMG_PetImage3D_EvoOnly_C:SetEvoSkillAnim01(resRequest, asset)
  self.EvoSkillAnim01 = asset
end

function UMG_PetImage3D_EvoOnly_C:StopEvoSkill()
  if self._refActorIsolateWorld and UE4.UObject.IsValid(self._refActorIsolateWorld) and self._refActorIsolateWorld.RocoSkill then
    self._refActorIsolateWorld.RocoSkill:StopCurrentSkill()
  end
  if self.EvoFx1 then
    self.EvoFx1:K2_DestroyActor()
    self.EvoFx1 = nil
  end
  if self.EvoFx2 then
    self.EvoFx2:K2_DestroyActor()
    self.EvoFx2 = nil
  end
end

function UMG_PetImage3D_EvoOnly_C:LoadEvoSkill()
  if self.EvoSkillAnim01 then
    self:PlayEvoSkill(nil, self.EvoSkillAnim01)
  end
end

function UMG_PetImage3D_EvoOnly_C:PlayEvoSkill(resRequest, asset)
  self._refActorIsolateWorld.Mesh.BoundsScale = 999
  self.EvoPetLocation = self._refActorIsolateWorld:Abs_GetTransform()
  self.startActorRotation = self._refActorIsolateWorld:K2_GetActorRotation()
  local Caster = self._refActorIsolateWorld
  local Target = self._evoTargetActor
  local Targets = {}
  if asset and Caster then
    local skillObj = Caster.RocoSkill:FindOrAddSkillObj(asset)
    if self.MainCameraPosActor then
      skillObj.Blackboard:SetValueAsObject("PetImage3D_MainCamera", self.MainCameraPosActor)
    end
    if self.MainCameraActor then
      skillObj.Blackboard:SetValueAsObject("PetImage3D_MainCamera1", self.MainCameraActor)
    end
    skillObj:SetCaster(Caster)
    Targets[1] = Target
    skillObj:SetTargets(Targets)
    skillObj:SetPassive(false)
    skillObj:RegisterEventCallback("OpenResultPanel", self, self.OpenResultPanel)
    skillObj:RegisterEventCallback("SetCamera1", self, self.SetSkillCamera1)
    skillObj:RegisterEventCallback("SetCamera2", self, self.SetSkillCamera2)
    skillObj:RegisterEventCallback("SetEvoTransform", self, self.SetEvoPetTransform)
    skillObj:RegisterEventCallback("End", self, self.OnEvoSkillEnd1)
    Caster.RocoSkill:LoadAndPlaySkill(skillObj)
    self:SetBagColourByUnitType()
  end
end

function UMG_PetImage3D_EvoOnly_C:OnEvoSkillEnd1(Event, Skill)
  Skill.Blackboard:RemoveObjectValue("PetImage3D_MainCamera")
  Skill.Blackboard:RemoveObjectValue("PetImage3D_MainCamera1")
end

function UMG_PetImage3D_EvoOnly_C:OnSkillEnd()
  self.IsPlayShowPetSkill = false
  self.curAnimInfo.curAniLength = self:GetAnimLengthByName("Idle")
end

function UMG_PetImage3D_EvoOnly_C:SetSkillCamera1(Event, Skill)
  self.skillCamera = Skill:GetBlackboard():GetValueAsObject("camActor_0001")
  self.skillCameraMesh = Skill:GetBlackboard():GetValueAsObject("camActor_0001_SA")
  self:PlayWhiteUIAnim()
end

function UMG_PetImage3D_EvoOnly_C:SetSkillCamera2(Event, Skill)
  self.skillCamera = nil
  self.skillCameraMesh = nil
  self.skillCamera = Skill:GetBlackboard():GetValueAsObject("camActor_0002")
  self.skillCameraMesh = Skill:GetBlackboard():GetValueAsObject("camActor_0002_SA")
end

function UMG_PetImage3D_EvoOnly_C:OnEvoSkillEnd(skillObj)
  if self._refActorIsolateWorld and self._evoTargetActor then
    self.PetWorldView:DestroyActor(self._refActorIsolateWorld)
    self._refActorIsolateWorld = nil
    self._refActorIsolateWorld = self._evoTargetActor
  end
end

function UMG_PetImage3D_EvoOnly_C:UpdateEvoPetMesh(Actor)
  local mesh = Actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  if mesh then
    mesh.VisibilityBasedAnimTickOption = UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
    self.SkeletalMesh = mesh
    mesh:SetForcedLOD(1)
    mesh.bEnableUpdateRateOptimizations = false
    mesh.StreamingDistanceMultiplier = 999
    mesh.bNeverDistanceCull = true
    mesh.bForceMipStreaming = true
  end
end

function UMG_PetImage3D_EvoOnly_C:SetEvoPetTransform()
  if self._evoTargetActor == nil then
    Log.Warning("evoTargetActor is nil")
    return
  end
  self._evoTargetActor:SetActorHiddenInGame(false)
  self.MainCameraActor.RootComponent:K2_SetRelativeTransform(self.MainCameraTransform, false, nil, false)
  local _petBaseCfg = _G.DataConfigManager:GetPetbaseConf(self.evoPetID)
  local modelScale = _petBaseCfg.petpage_ui_percentage and _petBaseCfg.petpage_ui_percentage > 0 and _petBaseCfg.petpage_ui_percentage or 1
  local height = 1
  local heightModelScale = PetMutationUtils.GetHeightModelScale(self.evoPetID, height)
  modelScale = modelScale * heightModelScale * 1.0
  local halfHeight = self._evoTargetActor:GetHalfHeight() * modelScale
  local PetLocation = UE4.FVector(0, 0, 0)
  PetLocation.Z = PetLocation.Z + halfHeight
  if self._startActorLocation then
    self._startActorLocation.Z = PetLocation.Z
  end
  self._evoTargetActor:Abs_K2_SetActorLocation_WithoutHit(PetLocation)
  self._evoTargetActor:K2_SetActorRotation(self.startActorRotation, false)
  self:UpdateEvoPetMesh(self._evoTargetActor)
  self._evoTargetActor:SetIsPlayerModel(true)
  self._refActorIsolateWorld:SetIsPlayerModel(false)
  self:SetEvoModelOffSetInfo()
end

function UMG_PetImage3D_EvoOnly_C:OpenResultPanel()
  local arg = {
    petID = self.petID,
    evoPetID = self.evoPetID,
    Action = self.Action
  }
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetEvoResultPanel, arg)
end

return UMG_PetImage3D_EvoOnly_C
