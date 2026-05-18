local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Drill_New"
local SKILL_PATH_NoRvt = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Drill_New_NoRvt"
local NS_VERTICAL_PARTICLE = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Scene/Pet/BWN/NS_BWN_DrillMud_Vertical.NS_BWN_DrillMud_Vertical'"
local LOCATOR_POS = "locator_pos"
local HiddenPluginFx = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenPluginFx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenActionBase")
local HiddenActionDrill = Base:Extend("HiddenActionDrill")

function HiddenActionDrill:Ctor()
end

local HOME_MAP_ID = 301

local function IsCurrentInHome()
  return SceneUtils.GetSceneID() == HOME_MAP_ID
end

function HiddenActionDrill:Init(comp)
  Base.Init(self, comp)
  local currentInHome = IsCurrentInHome()
  self.skillObj = nil
  if currentInHome then
    self.skillPath = _G.NRCUtils.FormatBlueprintAssetPath(SKILL_PATH_NoRvt)
  else
    self.skillPath = _G.NRCUtils.FormatBlueprintAssetPath(SKILL_PATH)
  end
  self.skillreq = nil
  self.skip_start = false
end

function HiddenActionDrill:Release()
  self.skillObj = nil
  self:ReleaseRes()
  Base.Release(self)
end

function HiddenActionDrill:EnablePinToGround()
  return false
end

function HiddenActionDrill:OnHidden(skip_start)
  self.skip_start = skip_start
  if self.skillObj then
    if not skip_start then
      self.comp:EnterHidden(AIDefines.ActionResult.Success)
    end
    return
  end
  if self.skillreq then
    self.comp:EnterHidden(AIDefines.ActionResult.Success)
    return
  end
  if skip_start then
    self:LoopAnim()
    UE.UNRCCharacterUtils.ForceTickCharacterMesh(self.owner.viewObj)
  end
  self.skillreq = _G.NRCResourceManager:LoadResAsync(self, self.skillPath, PriorityEnum.Passive_World_NPC_Hidden_Drill, 10, self.SkillLoadSucc, self.SkillLoadFail)
end

function HiddenActionDrill:SkillLoadSucc(req, skillClass)
  local RocoSkill = self.owner.viewObj.RocoSkill
  if not RocoSkill then
    self:ReleaseRes()
    self.comp:EnterHidden(AIDefines.ActionResult.Failed)
    return
  end
  local skillObj = RocoSkill:FindOrAddSkillObj(skillClass)
  local blackboard = skillObj and skillObj:IsValid() and skillObj.SetCaster and skillObj:GetBlackboard() or nil
  if blackboard then
    skillObj:ClearDelegates()
    skillObj:SetCaster(self.owner.viewObj):SetTargets({
      self.owner.viewObj
    }):RegisterEventCallback("End", self, self.SkillEnd):RegisterEventCallback("PreEnd", self, self.SkillEnd):RegisterEventCallback("Interrupt", self, self.SkillInterrupt):RegisterEventCallback("ActivateFailed", self, self.SkillEnd)
    skillObj:SetPassive(true)
    blackboard:SetValueAsInt("Looping", 1)
    blackboard:SetValueAsInt("End", -1)
    if self.skip_start then
      skillObj.Blackboard:SetValueAsInt("SkipStart", 1)
    else
      skillObj.Blackboard:SetValueAsInt("SkipStart", 0)
    end
    local result = RocoSkill:LoadAndPlaySkill(skillObj)
    if result == UE.ESkillStartResult.Success then
      self.skillObj = skillObj
      self.comp:EnterHidden(AIDefines.ActionResult.Success)
    else
      Log.Warning("HiddenActionSkillBased:OnHidden, PlaySkill not success", self.owner.config.name)
      self.comp:EnterHidden(AIDefines.ActionResult.Failed)
    end
  else
    Log.Warning("HiddenActionSkillBased:OnHidden, skillObj invalid", self.owner.config.name)
    self.comp:EnterHidden(AIDefines.ActionResult.Failed)
  end
end

function HiddenActionDrill:SkillLoadFail(req, msg)
  Log.Warning("HiddenActionSkillBased:OnHidden, skill class invalid")
  self.comp:EnterHidden(AIDefines.ActionResult.Failed)
end

function HiddenActionDrill:AssureHidden(imme)
  if self.skillObj then
    if imme then
      local skillObj = self.skillObj
      local RocoSkill = self.owner.viewObj.RocoSkill
      if not RocoSkill then
        return self.comp:EnterHidden(AIDefines.ActionResult.Failed)
      end
      self.skip_start = true
      skillObj:ClearDelegates()
      RocoSkill:CancelSkill(skillObj, UE.ESkillActionResult.SkillActionResultInterrupted)
      skillObj:SetCaster(self.owner.viewObj):RegisterEventCallback("End", self, self.SkillEnd):RegisterEventCallback("PreEnd", self, self.SkillEnd):RegisterEventCallback("Interrupt", self, self.SkillInterrupt)
      skillObj.Blackboard:SetValueAsInt("Looping", 1)
      skillObj.Blackboard:SetValueAsInt("End", -1)
      skillObj.Blackboard:SetValueAsInt("SkipStart", 1)
      local result = RocoSkill:PlaySkill(skillObj)
      self.skillObj = skillObj
      if result == UE.ESkillStartResult.Success then
        self.comp:EnterHidden(AIDefines.ActionResult.Success)
      else
        Log.Warning("HiddenActionSkillBased:AssureHidden, PlaySkill not success", self.owner.config.name)
        self.comp:EnterHidden(AIDefines.ActionResult.Failed)
      end
    end
  else
    self:OnHidden(imme)
  end
end

function HiddenActionDrill:OnUnhidden()
  if self.skillObj then
    self.skillObj.Blackboard:SetValueAsInt("Looping", -1)
    self.skillObj.Blackboard:SetValueAsInt("End", 1)
  else
    Log.Debug("[HiddenActionDrill:OnUnhidden] \229\183\178\231\187\143\231\187\147\230\157\159\229\152\158\239\188\129", self.owner:DebugNPCNameAndID())
    self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
    self:StopAnim()
  end
end

function HiddenActionDrill:AssureUnhidden(imme)
  if self.skillObj and self.owner.viewObj then
    if imme then
      self.owner.viewObj.RocoSkill:CancelSkill(self.skillObj, UE4.ESkillActionResult.SkillActionResultInterrupted)
      self.skillObj = nil
    else
      self:OnUnhidden()
    end
  elseif 4 == self.comp.state then
    self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
  end
  if imme then
    self:StopAnim()
  end
end

function HiddenActionDrill:SetVisible(subItemVisibility, ownerVisibility)
  if self.skillObj and self.skillObj.Blackboard then
    local Mound = self.skillObj.Blackboard:GetValueAsObject("TuDui_01")
    if Mound then
      Mound:SetActorHiddenInGame(not subItemVisibility)
    end
    Mound = self.skillObj.Blackboard:GetValueAsObject("TuDui_02")
    if Mound then
      Mound:SetActorHiddenInGame(not subItemVisibility)
    end
  end
end

function HiddenActionDrill:ReleaseRes()
  if self.skillreq then
    _G.NRCResourceManager:UnLoadRes(self.skillreq)
    self.skillreq = nil
  end
end

function HiddenActionDrill:LoadSkillAndPlay(init_skip)
end

function HiddenActionDrill:SkillEnd()
  self.skillObj = nil
  self:ReleaseRes()
  if self.comp then
    self.comp:FinalizeHidden(AIDefines.ActionResult.Success)
  end
end

function HiddenActionDrill:SkillInterrupt()
  Log.Warning("\229\140\191\232\184\170\230\138\128\232\131\189\232\162\171\230\137\147\230\150\173", self.owner and self.owner.config.name)
  self:SkillEnd()
end

function HiddenActionDrill:LoopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:PlayAnimByName("DrillLoop", 1, 0, 0, 0.2, -1)
  end
end

function HiddenActionDrill:StopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:StopAnimByName("DrillLoop", 0.02)
  end
end

return HiddenActionDrill
