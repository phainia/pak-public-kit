local UMG_MiracleExchangeMainImage_C = _G.NRCPanelBase:Extend("UMG_MiracleExchangeMainImage_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")

function UMG_MiracleExchangeMainImage_C:OnConstruct()
  self.camera = nil
  self.camera1 = nil
  self.captureComponent = nil
  self.captureComponent1 = nil
  self.petActor = nil
  self.petActorRef = nil
  self.initPetBaseConf = nil
  self.initPetData = nil
  self:OnAddEventListener()
  self:InitSceneCapture()
end

function UMG_MiracleExchangeMainImage_C:OnActive()
end

function UMG_MiracleExchangeMainImage_C:OnDeactive()
end

function UMG_MiracleExchangeMainImage_C:OnAddEventListener()
end

function UMG_MiracleExchangeMainImage_C:OnDestruct()
  if self.camera then
  end
end

function UMG_MiracleExchangeMainImage_C:InitSceneCapture()
  self.camera = self.previewWorld:getActorByName("DefaultSceneCapture_zong")
  self.captureComponent = self.camera:GetComponentByClass(UE4.USceneCaptureComponent2D)
  self.previewWorld:SetCapturePostProcessing(self.captureComponent)
  UE4.UNRCStatics.ChangeTextureToMatchScreen(self.captureComponent.TextureTarget, UE4Helper.GetCurrentWorld(), 1)
end

function UMG_MiracleExchangeMainImage_C:InitPetActor(petBaseConfId, petData)
  if self.petActor then
    self.previewWorld:DestroyActor(self.petActor)
    self.petActor = nil
  end
  self.petActorRef = nil
  self.initPetBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseConfId)
  self.initPetData = petData
  local modelCfg = _G.DataConfigManager:GetModelConf(self.initPetBaseConf.model_conf)
  self:LoadPanelRes(modelCfg.path, 255, self.OnPetModelLoadSucc)
end

function UMG_MiracleExchangeMainImage_C:OnPetModelLoadSucc(resRequest, modelClass)
  local modelCfg = _G.DataConfigManager:GetModelConf(self.initPetBaseConf.model_conf)
  if not modelClass then
    Log.ErrorFormat("UMG_PetTeamImage_C:AddPetToScene \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175 [%s].", modelCfg.path or "")
    return
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 3.5)
  local transform = UE4.FTransform(quat, UE4.FVector(0, 0, 0), UE4.FVector(1, 1, 1))
  local actor = self.previewWorld:SpawnActor(modelClass, transform)
  if not actor then
    Log.ErrorFormat("UMG_MiracleExchangeMainImage_C:SpawnActor \229\136\155\229\187\186Actor\229\164\177\232\180\165.", modelCfg.path or "")
    return
  end
  self.captureComponent.showOnlyActors:Add(actor)
  actor.CharacterMovement:SetMovementMode(UE4.EMovementMode.MOVE_Custom, 0)
  actor:SetIKEnable(false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh.bForceMipStreaming = true
  self.petActor = actor
  self.petActorRef = UnLua.Ref(actor)
  actor:InitOutSceneAsync()
  local modelScale = self.initPetBaseConf.pet_ui_percentage and self.initPetBaseConf.pet_ui_percentage > 0 and self.initPetBaseConf.pet_ui_percentage or 1
  local heightModelScale = PetMutationUtils.GetHeightModelScaleByPetData(self.initPetData)
  modelScale = modelScale * heightModelScale
  PetMutationUtils.DoMutation(actor, self.initPetData)
  UE.UNRCCharacterUtils.SetCharacterMeshScale(actor, modelScale)
  self:SetModelScale(modelScale)
  self:PlaySelectSkill()
end

function UMG_MiracleExchangeMainImage_C:RecalcActorLocation(actor)
  local Root = actor:K2_GetRootComponent()
  local height = Root:GetScaledCapsuleHalfHeight()
  local location = actor:K2_GetActorLocation()
  location.Z = location.Z + height
  actor:K2_SetActorLocation(location)
end

function UMG_MiracleExchangeMainImage_C:SetModelScale(_scale)
  local scale = _scale or 1
  if self.petActor then
    self.petActor:SetActorScale3D(UE4.FVector(scale, scale, scale))
    local height = self.petActor:GetHalfHeight() * scale
    self.petActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(0, 100, height))
  end
end

function UMG_MiracleExchangeMainImage_C:PlaySelectSkill()
  local path = "/Game/ArtRes/Effects/G6Skill/UI/Team/G6_UI_PetTeamFx.G6_UI_PetTeamFx"
  local caster = self.petActor
  if caster then
    local skillComponent = caster.RocoSkill
    if skillComponent then
      local skillProxy = RocoSkillProxy.Create(path, skillComponent)
      skillProxy:SetCaster(caster)
      skillProxy:SetPassive(true)
      skillProxy:PlaySkill()
    end
  end
end

return UMG_MiracleExchangeMainImage_C
