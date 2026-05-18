local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local Base = NPCActionBase
local FakePerformConf = require("NewRoco.Modules.Core.Scene.Component.Show.FakePerformConf")
local HoldingItemComponent = require("NewRoco.Modules.Core.Scene.Component.Show.HoldingItemComponent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCActionOpenHomePlantGuardUI = Base:Extend("NPCActionOpenHomePlantGuardUI")

function NPCActionOpenHomePlantGuardUI:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, true)
  local npcViewObj = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Home/G6_ShouHu_Pet.G6_ShouHu_Pet"
  local skillProxy = RocoSkillProxy.Create(skillPath, npcViewObj.RocoSkill)
  self:PlayEnterCameraSkill(npcViewObj, skillProxy, self, self.OnCameraStartEnd)
end

function NPCActionOpenHomePlantGuardUI:EndAction()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerController = localPlayer:GetUEController()
  playerController:ReleaseRocoCamera()
  local npc = self:GetOwnerNPC()
  if npc then
    local holdingItemComponent = npc:EnsureComponent(HoldingItemComponent)
    holdingItemComponent:DestroyItem("camActor_0001")
    holdingItemComponent:DestroyItem("camActor_0001_SA")
  end
  self:Finish()
end

function NPCActionOpenHomePlantGuardUI:PlayEnterCameraSkill(npcViewObj, skillProxy, caller, callback)
  local PerformConf = FakePerformConf(skillProxy:GetSkillPath())
  PerformConf:AddSkillBlackboardValue("camActor_0001", false)
  PerformConf:AddSkillBlackboardValue("camActor_0001_SA", false)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.viewObj:Event_StopTurn()
  npcViewObj.sceneCharacter:PlayShowById(PerformConf, caller, callback, skillProxy, self, self.OnEnterCameraSkillPreStart)
end

function NPCActionOpenHomePlantGuardUI:OnEnterCameraSkillPreStart(skillObj)
  if skillObj then
    local characters = {}
    characters[UE4.EBattleStaticActorType.Player_1] = self:GetOwnerNPCView()
    skillObj:SetCharacters(characters)
  end
end

function NPCActionOpenHomePlantGuardUI:SetPosAndLockOnGround(Model, Position, Rotation)
  local npcViewObj = self:GetOwnerNPCView()
  if not npcViewObj then
    return
  end
  local MeshComponent = npcViewObj:K2_GetRootComponent()
  local RootComponent = Model:K2_GetRootComponent()
  RootComponent:K2_AttachToComponent(MeshComponent, "None", UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
  RootComponent:K2_SetRelativeLocation(Position, false, nil, false)
  RootComponent:K2_SetRelativeRotation(Rotation, false, nil, false)
  local ModelLocation = Model:Abs_GetTransform().Translation
  local ModelUnderLocation = ModelLocation
  local UnderLineBegin = UE4.FVector(ModelLocation.X, ModelLocation.Y, ModelLocation.Z + 500)
  local UnderLineEnd = UE4.FVector(ModelLocation.X, ModelLocation.Y, ModelLocation.Z - 500)
  local TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel5)
  local Hits, Success = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(_G.UE4Helper.GetCurrentWorld(), UnderLineBegin, UnderLineEnd, TraceChannel, false, nil, 0, nil)
  if Success then
    for _, Result in tpairs(Hits) do
      ModelUnderLocation.X = Result.ImpactPoint.X
      ModelUnderLocation.Y = Result.ImpactPoint.Y
      ModelUnderLocation.Z = Result.ImpactPoint.Z + Model:GetHalfHeight()
      break
    end
  end
  Model:Abs_K2_SetActorLocation_WithoutHit(ModelUnderLocation)
  local ModelRotation = Model:K2_GetActorRotation()
  local ModelDirection = ModelRotation:ToVector() * 20
  local ModelFrontLocation = ModelLocation + ModelDirection
  local ModelFrontLineBegin = UE4.FVector(ModelFrontLocation.X, ModelFrontLocation.Y, ModelFrontLocation.Z + 500)
  local ModelFrontLineEnd = UE4.FVector(ModelFrontLocation.X, ModelFrontLocation.Y, ModelFrontLocation.Z - 500)
  Hits, Success = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(_G.UE4Helper.GetCurrentWorld(), ModelFrontLineBegin, ModelFrontLineEnd, TraceChannel, false, nil, 0, nil)
  if Success then
    for _, Result in tpairs(Hits) do
      ModelFrontLocation.X = Result.ImpactPoint.X
      ModelFrontLocation.Y = Result.ImpactPoint.Y
      ModelFrontLocation.Z = Result.ImpactPoint.Z + Model:GetHalfHeight()
      break
    end
  end
  local RealRotation = (ModelFrontLocation - ModelUnderLocation):ToRotator()
  Model:K2_SetActorRotation(RealRotation, false)
  local ModelUpVectorNormal = Model:GetActorUpVector()
  local ModelUpVector = Model:GetActorUpVector() * 500
  local ModelUpLineBegin = UE4.FVector(ModelFrontLocation.X + ModelUpVector.X, ModelFrontLocation.Y + ModelUpVector.Y, ModelFrontLocation.Z + ModelUpVector.Z)
  local ModelUpLineEnd = UE4.FVector(ModelFrontLocation.X - ModelUpVector.X, ModelFrontLocation.Y - ModelUpVector.Y, ModelFrontLocation.Z - ModelUpVector.Z)
  local ModelRealLocation = UE4.FVector((ModelFrontLocation.X + ModelUnderLocation.X) / 2, (ModelFrontLocation.Y + ModelUnderLocation.Y) / 2, (ModelFrontLocation.Z + ModelUnderLocation.Z) / 2)
  Hits, Success = UE4.UKismetSystemLibrary.Abs_LineTraceMulti(_G.UE4Helper.GetCurrentWorld(), ModelUpLineBegin, ModelUpLineEnd, TraceChannel, false, nil, 0, nil)
  if Success then
    for _, Result in tpairs(Hits) do
      ModelRealLocation.X = Result.ImpactPoint.X + ModelUpVectorNormal.X * Model:GetHalfHeight()
      ModelRealLocation.Y = Result.ImpactPoint.Y + ModelUpVectorNormal.Y * Model:GetHalfHeight()
      ModelRealLocation.Z = Result.ImpactPoint.Z + ModelUpVectorNormal.Z * Model:GetHalfHeight()
      break
    end
  else
    ModelRealLocation.X = ModelRealLocation.X + ModelUpVectorNormal.X * Model:GetHalfHeight()
    ModelRealLocation.Y = ModelRealLocation.Y + ModelUpVectorNormal.Y * Model:GetHalfHeight()
    ModelRealLocation.Z = ModelRealLocation.Z + ModelUpVectorNormal.Z * Model:GetHalfHeight()
  end
  Model:Abs_K2_SetActorLocation_WithoutHit(ModelRealLocation)
  Model:K2_DetachFromActor(UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld, UE4.EAttachmentRule.KeepWorld)
end

function NPCActionOpenHomePlantGuardUI:OnCameraStartEnd(Event, Skill)
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdOpenPanel, "PlantGuardPetChoosing", true, self)
end

function NPCActionOpenHomePlantGuardUI:MoveDetailPanelCamera(bOpenDetailPanel)
  local skillPath
  if bOpenDetailPanel then
    skillPath = "/Game/ArtRes/Effects/G6Skill/Home/G6_ShouHu_Pet_Start.G6_ShouHu_Pet_Start"
  else
    skillPath = "/Game/ArtRes/Effects/G6Skill/Home/G6_ShouHu_Pet_End.G6_ShouHu_Pet_End"
  end
  local npcViewObj = self:GetOwnerNPCView()
  if npcViewObj then
    local SkillProxy = RocoSkillProxy.Create(skillPath, npcViewObj.RocoSkill)
    if SkillProxy then
      local FakePerform = FakePerformConf(skillPath)
      FakePerform:AddSkillBlackboardValue("camActor_0001", false)
      FakePerform:AddSkillBlackboardValue("camActor_0001_SA", false)
      
      local function OnDetailCameraMoveDone()
      end
      
      self.OwnerNpc:PlayShowById(FakePerform, self, OnDetailCameraMoveDone, SkillProxy)
    end
  end
end

return NPCActionOpenHomePlantGuardUI
