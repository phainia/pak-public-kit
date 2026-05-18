require("UnLuaEx")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ActivityModuleEvent = require("NewRoco/Modules/System/Activity/ActivityModuleEvent")
local MagicManualModuleCmd = require("NewRoco.Modules.System.MagicManual.MagicManualModuleCmd")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C = Base:Extend("BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C")

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:PlayDisappearSkill1()
  if not self.sceneCharacter.shouldDestroy then
    return
  end
  local skillPath = "/Game/ArtRes/Effects/G6Skill/XueMai/G6_XueMai_TeamBattle_8.G6_XueMai_TeamBattle_8"
  local skillObj = RocoSkillProxy.Create(skillPath, self.RocoSkill, PriorityEnum.Passive_NPC_BornDie)
  skillObj:SetCaster(self)
  skillObj:RegisterEventCallback("Disappear1", self, self.OnDisappear1)
  skillObj:RegisterEventCallback("DestroyActor1", self, self.OnDestroySkillEnd)
  skillObj:SetPassive(false)
  skillObj:PlaySkill()
  if self.sceneCharacter.InteractionComponent then
    self.sceneCharacter.InteractionComponent:TryDisableInteraction()
  end
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:OnDisappear1()
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:OnDestroySkillEnd()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:SetNotDestroyFlag(false)
  self:SetActorHiddenInGame(true)
  local serverId = self.sceneCharacter.serverData.base.actor_id
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverId)
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:OnVisible()
  Base.OnVisible(self)
  _G.NRCAudioManager:PlaySound3DWithActorAuto(11000010, self, "BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C")
  self:UpdateFlowerNiagaraParameters()
  local ActivityModule = NRCModuleManager:GetModule("ActivityModule")
  if ActivityModule then
    ActivityModule:RegisterEvent(self, ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo, self.UpdateFlowerNiagaraParameters)
    ActivityModule:RegisterEvent(self, ActivityModuleEvent.RefreshActivityShinyPetDayData, self.UpdateFlowerNiagaraParameters)
  end
  local meshComp = self:GetComponentByClass(UE.UMeshComponent)
  if meshComp then
    meshComp.KinematicBonesUpdateType = 0
    meshComp.bNRCAlwaysUpdateKinematicBonesToAnim = true
    meshComp.bNRCUseFixedSkelBounds = false
  end
  self:PreventOverlap()
  local SceneCharacter = self.sceneCharacter
  if SceneCharacter then
    SceneCharacter:SetVisible(true)
  end
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:OnLeaveBattle()
  self:PreventOverlap()
  Base.OnLeaveBattle(self)
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:OnInVisible()
  Base.OnInVisible(self)
  _G.NRCAudioManager:StopAllForActor(self)
  local ActivityModule = NRCModuleManager:GetModule("ActivityModule")
  if ActivityModule then
    ActivityModule:UnRegisterEvent(self, ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo)
    ActivityModule:UnRegisterEvent(self, ActivityModuleEvent.RefreshActivityShinyPetDayData)
  end
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:UpdateFlowerNiagaraParameters()
  if not self.sceneCharacter then
    self:default()
    return
  end
  local RefreshContentId = self.sceneCharacter.serverData.npc_base.npc_content_cfg_id
  local Flower = NRCModuleManager:DoCmd(MagicManualModuleCmd.GetShinyNpcFlowerInfo, RefreshContentId)
  local bNormalFlower = true
  if Flower then
    bNormalFlower = false
    self:shiny_flower_seed()
  else
    local bLimitedFlower = NRCModuleManager:DoCmd(MagicManualModuleCmd.IsLimitedFlower, RefreshContentId)
    if bLimitedFlower then
      bNormalFlower = false
      self:self_selected_flower_seed()
    end
  end
  if bNormalFlower then
    self:default()
  end
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  if sceneCharacter then
    sceneCharacter:SetVisible(false)
  end
end

function BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C:PreventOverlap()
  local SceneCharacter = self.sceneCharacter
  if not SceneCharacter then
    return
  end
  local Comp = SceneCharacter:EnsureComponent(OverlapAwareVisibilityComponent)
  if not Comp then
    return
  end
  Comp:CheckInBoundAndMarkHidden()
end

return BP_NPC_SM_EnvDesTree_Bud_02b_Skin_C
