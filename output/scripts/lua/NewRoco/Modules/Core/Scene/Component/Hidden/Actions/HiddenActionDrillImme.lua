local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local HiddenPluginSkill = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginSkill")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Drill_WithoutAnim"
local NS_HORIZON_PARTICLE = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/Pet/BWN/NS_BWN_DrillMud_Horizontal.NS_BWN_DrillMud_Horizontal'"
local G6_HORIZON_PARTICLE = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Horizontal.G6_BWN_DrillMud_Horizontal_C'"
local G6_HORIZON_PARTICLE_NoRvt = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Horizontal_NoRvt.G6_BWN_DrillMud_Horizontal_NoRvt_C'"
local NS_VERTICAL_PARTICLE = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/Pet/BWN/NS_BWN_DrillMud_Vertical.NS_BWN_DrillMud_Vertical'"
local G6_VERTICAL_PARTICLE = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Vertical.G6_BWN_DrillMud_Vertical_C'"
local G6_VERTICAL_PARTICLE_NoRvt = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Vertical_NoRvt.G6_BWN_DrillMud_Vertical_NoRvt_C'"
local G6_VERTICAL_PARTICLE_NONSTAND = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Vertical_NoStandEffect.G6_BWN_DrillMud_Vertical_NoStandEffect_C'"
local G6_VERTICAL_PARTICLE_NONSTAND_NoRvt = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/BWN/G6_BWN_DrillMud_Vertical_NoStandEffect_NoRvt.G6_BWN_DrillMud_Vertical_NoStandEffect_NoRvt_C'"
local G6_SNOW_ACCESS = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/Ecology/G6_Scene_Ecology_SnowAccess.G6_Scene_Ecology_SnowAccess_C'"
local G6_SNOW_ACCESS_NoRvt = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/Ecology/G6_Scene_Ecology_SnowAccess_NoRvt.G6_Scene_Ecology_SnowAccess_NoRvt_C'"
local G6_SNOW_MOVE = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/Ecology/G6_Scene_Ecology_SnowMove01.G6_Scene_Ecology_SnowMove01_C'"
local G6_SNOW_MOVE_NoRvt = "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/Ecology/G6_Scene_Ecology_SnowMove01_NoRvt.G6_Scene_Ecology_SnowMove01_NoRvt_C'"
local HiddenActionDrillImme = Base:Extend("HiddenActionDrillImme")
local HOME_MAP_ID = 301

local function IsCurrentInHome()
  return SceneUtils.GetSceneID() == HOME_MAP_ID
end

function HiddenActionDrillImme:Ctor(mode)
  local currentInHome = IsCurrentInHome()
  local prio = PriorityEnum.Passive_World_NPC_Hidden_Drill
  if 2 == mode[2] then
    self.jumpSkill = nil
    self.moveSkill = nil
  elseif 1 == mode[2] then
    if currentInHome then
      self.jumpSkill = HiddenPluginSkill(G6_SNOW_ACCESS_NoRvt, true, true, prio)
      self.moveSkill = HiddenPluginSkill(G6_SNOW_MOVE_NoRvt, true, true, prio)
    else
      self.jumpSkill = HiddenPluginSkill(G6_SNOW_ACCESS, true, true, prio)
      self.moveSkill = HiddenPluginSkill(G6_SNOW_MOVE, true, true, prio)
    end
  elseif currentInHome then
    self.jumpSkill = HiddenPluginSkill(G6_HORIZON_PARTICLE_NoRvt, true, true, prio)
    if 1 == mode[1] then
      self.moveSkill = HiddenPluginSkill(G6_VERTICAL_PARTICLE_NONSTAND_NoRvt, true, true, prio)
    else
      self.moveSkill = HiddenPluginSkill(G6_VERTICAL_PARTICLE_NoRvt, true, true, prio)
    end
  else
    self.jumpSkill = HiddenPluginSkill(G6_HORIZON_PARTICLE, true, true, prio)
    if 1 == mode[1] then
      self.moveSkill = HiddenPluginSkill(G6_VERTICAL_PARTICLE_NONSTAND, true, true, prio)
    else
      self.moveSkill = HiddenPluginSkill(G6_VERTICAL_PARTICLE, true, true, prio)
    end
  end
end

function HiddenActionDrillImme:Init(comp)
  Base.Init(self, comp)
  if self.jumpSkill then
    self.jumpSkill:Init(comp.owner)
  end
  if self.moveSkill then
    self.moveSkill:Init(comp.owner)
  end
  self.moveSkill_visibility = true
end

function HiddenActionDrillImme:Release()
  if self.jumpSkill then
    self.jumpSkill:Release()
  end
  if self.moveSkill then
    self.moveSkill:Release()
  end
  Base.Release(self)
end

function HiddenActionDrillImme:OnInitialHide()
end

function HiddenActionDrillImme:OnHidden()
  if not self.owner:IsHidden() and self.moveSkill then
    self.jumpSkill:Show()
  end
  self:SetCharacterVisibility(false)
  if self.moveSkill then
    self.moveSkill:Show()
  end
  self.comp:EnterHidden(AIDefines.ActionResult.Success)
end

function HiddenActionDrillImme:AssureHidden(imme)
  if self.moveSkill then
    self.moveSkill:Show()
  end
  self:SetCharacterVisibility(false)
end

function HiddenActionDrillImme:OnUnhidden()
  if not self.owner:IsHidden() and self.jumpSkill then
    self.jumpSkill:Show()
  end
  if self.moveSkill then
    self.moveSkill:Stop()
  end
  self:SetCharacterVisibility(true)
  if self.owner and self.owner.viewObj then
    local Character = self.owner.viewObj
    local moveComp = Character:GetMovementComponent()
    moveComp.bJustTeleported = true
  end
  self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
end

function HiddenActionDrillImme:AssureUnhidden(imme)
  if self.moveSkill then
    self.moveSkill:Stop()
  end
  self:SetCharacterVisibility(true)
end

function HiddenActionDrillImme:OnVisibilityChange(visible)
end

function HiddenActionDrillImme:EnablePinToGround()
  return false
end

function HiddenActionDrillImme:SetVisible(subItemVisibility, ownerVisibility)
  local isHidden = self.comp.state == self.comp.State.Hidden
  if subItemVisibility and isHidden then
    if self.moveSkill then
      self.moveSkill:Show()
    end
  elseif self.moveSkill then
    self.moveSkill:Stop()
  end
  self:SetFxVisibility(subItemVisibility)
end

function HiddenActionDrillImme:SetCharacterVisibility(visible)
  local mesh = SceneUtils.GetActorMesh(self.owner.viewObj)
  if mesh then
    mesh:SetHiddenInGame(not visible, false)
  end
  local view = self.owner.viewObj
  if view and view.IkOverride ~= nil then
    view.IkOverride = visible
  end
  self:SetFxVisibility(true)
end

function HiddenActionDrillImme:SetFxVisibility(visible)
  local movePc = self.moveSkill and self.moveSkill:GetBlackboard("Particle")
  if movePc then
    movePc:SetHiddenInGame(not visible, true)
  end
  local jumpPc = self.jumpSkill and self.jumpSkill:GetBlackboard("Particle")
  if jumpPc then
    jumpPc:SetHiddenInGame(not visible, true)
  end
end

return HiddenActionDrillImme
