local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleEvent = require("NewRoco.Modules.System.BattleUI.BattleUIModuleEvent")
local UMG_BattleEvoPanel_C = _G.NRCPanelBase:Extend("UMG_BattleEvoPanel_C")

function UMG_BattleEvoPanel_C:OnActive(fromPetData, toPetData, bShow)
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C OnActive")
  self.beforePetData = fromPetData.card.petInfo.battle_common_pet_info
  self.afterPetData = toPetData.pet_info.battle_common_pet_info
  self.beforePetTransform = fromPetData:GetActorTransform()
  self.beforeActor = nil
  self.beforeActorRef = nil
  self.afterActor = nil
  self.afterActorRef = nil
  self.beforeActorLoaded = false
  self.afterActorLoaded = false
  self.evoSkill = nil
  self.skillObj = nil
  self:OnShow(bShow)
  self:AddPetModel()
end

function UMG_BattleEvoPanel_C:OnDeactive()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C OnDeactive")
  self:DestroyActors()
end

function UMG_BattleEvoPanel_C:OnAddEventListener()
end

function UMG_BattleEvoPanel_C:OnConstruct()
end

function UMG_BattleEvoPanel_C:OnDestruct()
end

function UMG_BattleEvoPanel_C:AddPetModel()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Try Load Pet Model")
  local beforePetbaseConf = _G.DataConfigManager:GetPetbaseConf(self.beforePetData.base_conf_id)
  local beforePetModelPath = _G.DataConfigManager:GetModelConf(beforePetbaseConf.model_conf)
  local afterPetbaseConf = _G.DataConfigManager:GetPetbaseConf(self.afterPetData.base_conf_id)
  local afterPetModelPath = _G.DataConfigManager:GetModelConf(afterPetbaseConf.model_conf)
  self:SetPath(beforePetModelPath.path, false)
  self:SetPath(afterPetModelPath.path, true)
end

function UMG_BattleEvoPanel_C:SetPath(modelPath, bAfterPet)
  if bAfterPet then
    self:LoadPanelRes(modelPath, 255, self.OnSetPathSucc1)
  else
    self:LoadPanelRes(modelPath, 255, self.OnSetPathSucc2)
  end
end

function UMG_BattleEvoPanel_C:OnSetPathSucc1(resRequest, modelClass)
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Spawn afterActor")
  if not modelClass then
    Log.ErrorFormat("UMG_BattleEvoPanel_C:SetPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175.")
    return
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
  local fTransfom = UE4.FTransform(quat, UE4.FVector(0, 0, 0), UE4.FVector(1, 1, 1))
  self.afterActor = _G.UE4Helper.GetCurrentWorld():SpawnActor(modelClass, fTransfom)
  self.afterActorRef = UnLua.Ref(self.afterActor)
  self.afterActor:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
  if self.afterPetData then
    PetMutationUtils.PrepareMutationAssets(self.afterActor, self.afterPetData)
  else
    PetMutationUtils.PrepareMutationAssets(self.afterActor, self.beforePetData)
  end
  self.afterActor:InitOutSceneAsync(self, self.OnAfterPetLoaded)
end

function UMG_BattleEvoPanel_C:OnSetPathSucc2(resRequest, modelClass)
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Spawn beforeActor")
  if not modelClass then
    Log.ErrorFormat("UMG_BattleEvoPanel_C:SetPath \230\168\161\229\158\139\232\183\175\229\190\132\233\148\153\232\175\175.")
    return
  end
  local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
  local fTransfom = UE4.FTransform(quat, UE4.FVector(0, 0, 0), UE4.FVector(1, 1, 1))
  self.beforeActor = _G.UE4Helper.GetCurrentWorld():SpawnActor(modelClass, fTransfom)
  self.beforeActorRef = UnLua.Ref(self.beforeActor)
  self.beforeActor:SetLoadPriority(PriorityEnum.UI_Pet_Mutation)
  PetMutationUtils.PrepareMutationAssets(self.beforeActor, self.beforePetData)
  self.beforeActor:InitOutSceneAsync(self, self.OnBeforePetLoaded)
end

function UMG_BattleEvoPanel_C:OnBeforePetLoaded(actor)
  actor.IkOverride = false
  actor:Abs_K2_SetActorTransform(self.beforePetTransform, false, nil, false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh:SetForcedLOD(1)
  mesh.bEnableUpdateRateOptimizations = false
  mesh.StreamingDistanceMultiplier = 999
  mesh.bNeverDistanceCull = true
  mesh.bForceMipStreaming = true
  if self.beforePetData then
    PetMutationUtils.DoMutation(actor, self.beforePetData)
  end
  self.beforeActorLoaded = true
  self:LoadEvoSkill()
end

function UMG_BattleEvoPanel_C:OnAfterPetLoaded(actor)
  actor.IkOverride = false
  actor:Abs_K2_SetActorTransform(self.beforePetTransform, false, nil, false)
  local mesh = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  mesh:SetForcedLOD(1)
  mesh.bEnableUpdateRateOptimizations = false
  mesh.StreamingDistanceMultiplier = 999
  mesh.bNeverDistanceCull = true
  mesh.bForceMipStreaming = true
  if self.afterPetData then
    PetMutationUtils.DoMutation(actor, self.afterPetData)
  end
  self.afterActorLoaded = true
  self:LoadEvoSkill()
end

function UMG_BattleEvoPanel_C:LoadEvoSkill()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Try Start LoadEvoSkill")
  if self.beforeActorLoaded and self.afterActorLoaded then
    self:OnShow(true)
    Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Start LoadEvoSkill")
    BattleResourceManager:LoadClassAsync(self, BattleConst.Evolution.PetEvolutionAnimWorldEnd, self.PlayEvoSkill)
  end
end

function UMG_BattleEvoPanel_C:PlayEvoSkill(skillClass)
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C PlayEvoSkill(Loaded)")
  if skillClass and self.beforeActor then
    local Caster = self.beforeActor
    local Target = self.afterActor
    local Targets = {}
    local skillObj = Caster.RocoSkill:FindOrAddSkillObj(skillClass)
    skillObj:SetCaster(Caster)
    Targets[1] = Target
    skillObj:SetTargets(Targets)
    skillObj:SetPassive(true)
    skillObj.Blackboard:SetValueAsInt("Nextok", -1)
    skillObj:RegisterEventCallback("OpenResultPanel", self, self.OpenResultPanel)
    skillObj:RegisterEventCallback("SetCamera1", self, self.SetSkillCamera1)
    skillObj:RegisterEventCallback("SetCamera2", self, self.SetSkillCamera2)
    self:UpdateBound(Caster)
    self:UpdateBound(Target)
    Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C Caster.RocoSkill:LoadAndPlaySkill(skillObj)")
    Caster.RocoSkill:LoadAndPlaySkill(skillObj)
    self.skillObj = skillObj
  else
    Log.Error("skillClass or beforeActor is nil")
  end
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C DispatchEvent OnBattleEvolutionPanelShown")
  _G.NRCEventCenter:DispatchEvent(BattleUIModuleEvent.OnBattleEvolutionPanelShown)
end

function UMG_BattleEvoPanel_C:NotifySkillJumpToEnd()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C NotifySkillJumpToEnd")
  if self.skillObj and UE4.UObject.IsValid(self.skillObj) then
    self.skillObj.Blackboard:SetValueAsInt("Nextok", 0)
  else
    self:OnSkillComplete()
  end
  self.skillObj = nil
end

function UMG_BattleEvoPanel_C:UpdateBound(actor)
  if not actor then
    return
  end
  local SKMComponent = actor:GetComponentByClass(UE4.USkeletalMeshComponent)
  if SKMComponent then
    SKMComponent.bNRCUseFixedSkelBounds = false
    SKMComponent.bNRCAlwaysUpdateKinematicBonesToAnim = true
    SKMComponent.bEabledAuxiliaryAnimGraphThread = false
    SKMComponent.BoundsScale = 999
    SKMComponent.VisibilityBasedAnimTickOption = UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
  end
end

function UMG_BattleEvoPanel_C:OpenResultPanel()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C OpenResultPanel(SkillEvent) -> Dispatch BattleEvent.EVOLUTION_OPEN_RESULT")
  _G.BattleEventCenter:Dispatch(BattleEvent.EVOLUTION_OPEN_RESULT)
end

function UMG_BattleEvoPanel_C:DestroyActors()
  Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C DestroyActors")
  if self.beforeActor then
    self.beforeActor:K2_DestroyActor()
    self.beforeActor = nil
    self.beforeActorRef = nil
  end
  if self.afterActor then
    self.afterActor:K2_DestroyActor()
    self.afterActor = nil
    self.afterActorRef = nil
  end
end

function UMG_BattleEvoPanel_C:OnShow(bShow)
  if bShow then
    Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C SetRenderOpacity(1)")
    self:SetRenderOpacity(1)
  else
    Log.Debug("Battle Evo Progress: UMG_BattleEvoPanel_C SetRenderOpacity(0)")
    self:SetRenderOpacity(0)
  end
end

function UMG_BattleEvoPanel_C:SetSkillCamera1(Event, Skill)
  self:PlayWhiteUIAnim()
end

function UMG_BattleEvoPanel_C:SetSkillCamera2(Event, Skill)
end

function UMG_BattleEvoPanel_C:PlayWhiteUIAnim()
  self.EvoWhiteScreen:PlayAnimation(self.EvoWhiteScreen.Anim)
end

return UMG_BattleEvoPanel_C
