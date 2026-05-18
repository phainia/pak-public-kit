require("UnLuaEx")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BattleModuleCmd = require("NewRoco.Modules.Core.Battle.BattleModuleCmd")
local MarkerModuleCmd = require("NewRoco.Modules.Core.Marker.MarkerModuleCmd")
local ExplodeActorComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.ExplodeActorComponent")
local ZVelocityModule = require("NewRoco.Modules.Core.NPC.Velocity.ZVelocityModule")
local CylinderModule = require("NewRoco.Modules.Core.NPC.Velocity.CylinderVelocityModule")
local PhysicsAnimConfig = require("NewRoco.Modules.Core.Scene.Common.PhysicsAnimConfig")
local BoxTypeMap = {
  L1 = "",
  L2 = "_L2",
  L3 = "_L3"
}
local WorldCombatRewardBoxName = "\229\164\167\231\178\190\231\129\181\231\137\169\232\181\132\231\174\177"
local BP_NPCBox_C = Base:Extend("BP_NPCBox_C")

function BP_NPCBox_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCBox_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.ActorEmitter = ExplodeActorComponent()
  local ZModule = ZVelocityModule(PhysicsAnimConfig.Box.ZVelocityMin, PhysicsAnimConfig.Box.ZVelocityMax)
  local Cylinder = CylinderModule(PhysicsAnimConfig.Box.CylinderMin, PhysicsAnimConfig.Box.CylinderMax)
  self.ActorEmitter:AddForceModule(ZModule)
  self.ActorEmitter:AddForceModule(Cylinder)
  self.ActorEmitter.force = PhysicsAnimConfig.Box.Force
  local IsBattle = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
  if IsBattle then
    local center = _G.NRCModuleManager:DoCmd(BattleModuleCmd.GetBattleFieldCenterPos)
    local battle_radius = _G.NRCModuleManager:DoCmd(BattleModuleCmd.GetBattleFieldRadius)
    local npcPos = self:Abs_K2_GetActorLocation()
    if center and battle_radius and npcPos then
      local disSqr = UE.FVector.DistSquared(center, npcPos)
      self:OnEnterBattle(center, battle_radius, disSqr)
    end
  end
end

function BP_NPCBox_C:Init()
  Base.Init(self)
  self.SkeletalMesh.bHiddenInGame = false
  self:SetActorHiddenInGame(false)
end

function BP_NPCBox_C:ResetOpenState()
  self:SetBoxOpen(false)
  self.showed = false
end

function BP_NPCBox_C:OnLoadResource()
  Base.OnLoadResource(self)
  if self and UE4.UObject.IsValid(self) then
    UE4.UNRCNavLibrary.RefreshComponentNav(self.SkeletalMesh)
  end
end

function BP_NPCBox_C:LoadLockEffect()
  return self.NRCChildActor
end

function BP_NPCBox_C:CheckNavValid(Config)
  if self.showed then
    return
  end
  local LocalPlayer = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Capsule = LocalPlayer.viewObj:K2_GetRootComponent()
  local SelfPos = self:GetInterPos(LocalPlayer:GetActorLocation(), Config.enablefix_distance, Config.fix_distance, Config.fix_rotation, Capsule:GetScaledCapsuleRadius())
  local QueryExtent = UE4.FVector(0, 0, 50)
  local ProjectedLocation, ResValue = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(UE4Helper.GetCurrentWorld(), SelfPos, nil, nil, nil, QueryExtent)
  return ResValue, SelfPos
end

function BP_NPCBox_C:GetInterPos(playerPos, enableFixType, config_distance, config_rotation, playerRadius)
  return Base.GetInterPos(self, playerPos, enableFixType, config_distance, config_rotation, playerRadius)
end

function BP_NPCBox_C:PreNavInter()
  local MeshComp = self.SkeletalMesh
  if MeshComp then
    if MeshComp.bForceSetNavRelevancyTrue ~= nil then
      MeshComp.bForceSetNavRelevancyTrue = true
    end
    MeshComp:SetCollisionProfileName("CreatingNPC")
  else
    Log.Warning("BP_NPCBox_C:PreNavInter no rootComponent", self:GetDebugInfo())
  end
end

function BP_NPCBox_C:OnNavInterFinish(Success)
  local MeshComp = self.SkeletalMesh
  if MeshComp then
    MeshComp:SetCollisionProfileName("BlockAllDynamic")
  else
    Log.Warning("BP_NPCBox_C:OnNavInterFinish no rootComponent", self:GetDebugInfo())
  end
end

function BP_NPCBox_C:PlayLockLoopEffect()
  Log.Debug("BP_NPCBox_C:PlayLockLoopEffect", self:GetDebugInfo(), self:GetLockTime())
  self:PlaySkillByClass(self.LockSkill, self)
end

function BP_NPCBox_C:PlayUnlockEffect(lockNum)
  Log.Debug("BP_NPCBox_C:PlayUnlockEffect", self:GetDebugInfo())
  local effectActor = self.NRCChildActor:GetChildActor()
  if not effectActor or not UE.UObject.IsValid(effectActor) then
    return
  end
  local Current = effectActor:GetTotalNum()
  local Need = self:GetLockTime()
  local Diff = Current - Need
  if Diff > 0 then
    for i = 1, Diff do
      effectActor:UnlockOnce()
    end
  end
  if not self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED) then
    self.NRCChildActor:NRCDestroyChildActor()
    return
  end
  if 0 ~= lockNum then
    return
  end
  self.RocoSkill:StopCurrentSkill()
  self:PlaySkillByClass(self.UnLockSkill, self, nil, nil, nil, true)
end

function BP_NPCBox_C:ResetLockNum(num)
  Log.Debug("BP_NPCBox_C:ResetLockNum", num, self:GetDebugInfo())
  local Comp = self:LoadLockEffect()
  if not Comp then
    return
  end
  if not self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED) then
    self.NRCChildActor:NRCDestroyChildActor()
    return
  end
  local effectActor = Comp:GetChildActor()
  if not effectActor then
    return
  end
  if effectActor.DestroyAll then
    effectActor:DestroyAll()
  end
  if effectActor.SetTotalNum then
    effectActor:SetTotalNum(self:GetLockTime())
  end
end

function BP_NPCBox_C:OnVisible()
  Base.OnVisible(self)
  if not self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED) then
    self.NRCChildActor:NRCDestroyChildActor()
  end
  self:SetActorEnableCollision(true)
  self:TryUpdateWorldCombatRewards(false)
  self:SetBoxOpen(false)
  self.showed = false
end

function BP_NPCBox_C:OnInVisible()
  self.RocoSkill:StopCurrentSkill()
  Base.OnInVisible(self)
  self:TryUpdateWorldCombatRewards(true)
end

function BP_NPCBox_C:SendGlobalEvent(Name)
  local SceneCharacter = self.sceneCharacter
  if not SceneCharacter then
    return
  end
  local ServerData = SceneCharacter.serverData
  local Misc = ServerData and ServerData.misc_info
  local RewardList = Misc and Misc.box_extra_reward_info_list
  if not RewardList then
    return
  end
  _G.NRCEventCenter:DispatchEvent(Name, SceneCharacter, RewardList)
end

function BP_NPCBox_C:TryUpdateWorldCombatRewards(collected)
  local sceneCharacter = self.sceneCharacter
  if sceneCharacter and sceneCharacter.config.name == WorldCombatRewardBoxName then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      local playerId = localPlayer:GetServerId()
      if playerId == sceneCharacter.serverData.base.owner_id then
        if collected then
          _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.ExtraRewardCollected, sceneCharacter.serverData)
        elseif sceneCharacter:IsFirstAppearance() then
          _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.UpdateRewardsFromServerData, sceneCharacter.serverData)
        end
      else
        sceneCharacter:SetHidden(NPCModuleEnum.NpcReasonFlags.NOT_OWNER, true)
        sceneCharacter:SetCollisionDisable(NPCModuleEnum.NpcReasonFlags.NOT_OWNER, true)
      end
    elseif collected then
      _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.ExtraRewardCollected, sceneCharacter.serverData)
    end
  end
end

function BP_NPCBox_C:OnShouldDestroy()
  Log.Debug("BP_NPCBox_C:OnShouldDestroy", self:GetDebugInfo())
  if self.sceneCharacter then
    self.sceneCharacter.InteractionComponent:OnPlayerLeaveActionArea()
  end
  local luaObj = self.sceneCharacter.luaObj
  if luaObj.enable_has_changed and not self.showed and -1 == luaObj.createNum then
    self:Show()
  end
end

function BP_NPCBox_C:OnOpenedInAnim()
  Log.Debug("BP_NPCBox_C:OnOpenedInAnim", self:GetDebugInfo())
  self:SetBoxOpen(true)
end

function BP_NPCBox_C:DestroySelf()
  if not self.sceneCharacter then
    return
  end
  local serverId = self.sceneCharacter.serverData.base.actor_id
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverId)
end

function BP_NPCBox_C:PlayDestroyEffect()
  Log.Debug("BP_NPCBox_C:PlayDestroyEffect", self:GetDebugInfo())
  self.RocoSkill:StopCurrentSkill()
  
  local function registerEvent(skill)
  end
  
  self:PlaySkillByClass(self.FadeSkill, self, nil, registerEvent, self.DestroySelf, true)
end

function BP_NPCBox_C:UnlockDestory()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:SetNotDestroyFlag(false)
  self:PlayDestroyEffect()
end

function BP_NPCBox_C:OnShootInAnim()
  Log.Debug("BP_NPCBox_C:OnShootInAnim", self:GetDebugInfo())
  if not self.sceneCharacter then
    Log.Error("\229\188\128\229\174\157\231\174\177\231\154\132\230\151\182\229\128\153\230\178\161\230\156\137SceneCharacter", UE.UObject.GetName(self))
    return
  end
  if self.GlowComp then
    self.GlowComp:SetVisibility(false, true)
  end
  self.ActorEmitter.startPos = self:Abs_K2_GetActorLocation() + self:GetLockSocketHeight()
  self.ActorEmitter.startPos.Z = self.ActorEmitter.startPos.Z + 10
  self.ActorEmitter:Explode(self.sceneCharacter.luaObj:GetChildrenNPCViews())
  _G.GlobalConfig.DisableBattle = false
  _G.DelayManager:DelaySeconds(2, self.UnlockDestory, self)
end

function BP_NPCBox_C:Show()
  self:SetCanBeBase(false)
  self.showed = true
  self.SkeletalMesh:SetComponentTickEnabled(true)
  self:PlayShowSkill(self.useStar)
end

function BP_NPCBox_C:PlayShowSkill(isStar)
  if self.bHidden then
    self:OnOpenedInAnim()
    self:OnShootInAnim()
    return
  end
  local suffix = isStar and "" or "_Hand"
  local skillType = BoxTypeMap[self.BoxType]
  local skillPath = string.format("/Game/ArtRes/Effects/G6Skill/SceneEffect/791244%s%s", skillType, suffix)
  
  local function registerEvent(skill)
    skill:RegisterEventCallback("Open", self, self.OnOpenedInAnim)
    skill:RegisterEventCallback("Shoot", self, self.OnShootInAnim)
  end
  
  self:PlaySkill(skillPath, self, nil, registerEvent, nil, true)
end

function BP_NPCBox_C:CanThrowInter(throwInfo)
  return false
end

function BP_NPCBox_C:SetOptionCfg(optionCfg)
  self.optionCfg = optionCfg
end

function BP_NPCBox_C:Recycle()
  local Comp = self.RocoMaterial
  if Comp then
    Comp:ClearMaterials()
  end
  self.open = false
  self.showed = false
  self.SkeletalMesh.bHiddenInGame = false
  self:SetActorHiddenInGame(false)
  Base.Recycle(self)
end

function BP_NPCBox_C:SetBoxOpen(isOpen)
  if isOpen then
    local Anim = self.RocoAnim
    if Anim then
      Anim:StopAllMontage(0)
    end
  end
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:SetCollisionDisable(isOpen, NPCModuleEnum.NpcReasonFlags.ANY)
  self:SetOpened(isOpen)
end

function BP_NPCBox_C:GetLockSocketHeight()
  if self.LockSocket then
    local Translation = self.LockSocket:GetRelativeTransform().Translation
    return Translation.Z
  end
  return 50
end

function BP_NPCBox_C:BeforeBornPerform()
  Log.Debug("BP_NPCBox_C:BeforeBornPerform", self:GetDebugInfo())
  local sceneCharacter = self.sceneCharacter
  if sceneCharacter then
    if sceneCharacter.config.name == WorldCombatRewardBoxName then
      sceneCharacter:SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
      self:PreventOverlap(true)
      sceneCharacter.InteractionComponent:SetInteractionEnable(false, NPCModuleEnum.NpcInteractDisableFlag.WORLD_COMBAT, true)
      Log.Debug("BP_NPCBox_C:BeforeBornPerform PreventOverlap", sceneCharacter:DebugNPCNameAndID(), sceneCharacter.hiddenFlag, sceneCharacter.collisionDisableFlag)
    end
    sceneCharacter.InteractionComponent:SetMarkShouldShow(false)
  end
end

function BP_NPCBox_C:AfterBornPerform()
  Log.Debug("BP_NPCBox_C:AfterBornPerform", self:GetDebugInfo())
  local sceneCharacter = self.sceneCharacter
  if sceneCharacter then
    if sceneCharacter.config.name == WorldCombatRewardBoxName then
      self:PreventOverlap(true)
      sceneCharacter:SetCollisionDisable(false, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
      sceneCharacter.InteractionComponent:SetInteractionEnable(true, NPCModuleEnum.NpcInteractDisableFlag.WORLD_COMBAT, true)
      Log.Debug("BP_NPCBox_C:AfterBornPerform PreventOverlap", sceneCharacter:DebugNPCNameAndID(), sceneCharacter.hiddenFlag, sceneCharacter.collisionDisableFlag)
    end
    sceneCharacter.InteractionComponent:SetMarkShouldShow(true)
  end
end

return BP_NPCBox_C
