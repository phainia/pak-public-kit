local Class = _G.MakeSimpleClass
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NpcSkillPlayComponent = Class("NpcSkillPlayComponent")

function NpcSkillPlayComponent:Ctor(viewObj)
  self.viewObj = viewObj
end

function NpcSkillPlayComponent:PlaySkillByClass(assetClass, caster, target, eventRegister, onSkillEnd, isPassive)
  Log.Debug("NpcSkillPlayComponent:PlaySkillByClass")
  return self:PlaySkillInternal(assetClass, caster, target, eventRegister, onSkillEnd, isPassive)
end

function NpcSkillPlayComponent:PlaySkill(skillPath, caster, target, eventRegister, onSkillEnd, isPassive)
  Log.Debug("NpcSkillPlayComponent:PlaySkill  : ", skillPath)
  if string.IsNilOrEmpty(skillPath) then
    Log.Error("PlaySkill Error, skillPath is nil")
    return false
  end
  local rocoSkill = self.viewObj.RocoSkill
  if self.viewObj.RocoSkill == nil then
    Log.Error("PlayCommonPetInteractionSkill Error, Not Find RocoSkill")
    return false
  end
  local SkillProxy = RocoSkillProxy(skillPath, rocoSkill)
  if caster then
    SkillProxy:SetCaster(caster)
  end
  if target then
    SkillProxy:SetTargets({target})
  end
  if onSkillEnd then
    SkillProxy:RegisterEventCallback("End", self.viewObj, onSkillEnd)
    SkillProxy:RegisterEventCallback("PreEnd", self.viewObj, onSkillEnd)
    SkillProxy:RegisterEventCallback("PreEndAnim", self.viewObj, onSkillEnd)
    SkillProxy:RegisterEventCallback("Interrupt", self.viewObj, onSkillEnd)
  end
  if eventRegister then
    eventRegister(SkillProxy)
  end
  SkillProxy:SetPassive(isPassive)
  SkillProxy:PlaySkill()
end

function NpcSkillPlayComponent:PlaySkillInternal(assetClass, caster, target, eventRegister, onSkillEnd, isPassive)
  local rocoSkill = self.viewObj.RocoSkill
  if self.viewObj.RocoSkill == nil then
    Log.Error("PlayCommonPetInteractionSkill Error, Not Find RocoSkill")
    return false
  end
  local skill = RocoSkillProxy.Create(UE4.UNRCStatics.GetSoftObjPath(assetClass), rocoSkill, _G.PriorityEnum.Active_Player_Action)
  if not skill then
    return false
  end
  if isPassive then
    skill:SetPassive(true)
  end
  if caster then
    skill:SetCaster(caster)
  end
  if target then
    skill:SetTargets({target})
  end
  if eventRegister then
    eventRegister(skill)
  end
  if onSkillEnd then
    skill:RegisterEventCallback("End", self.viewObj, onSkillEnd)
    skill:RegisterEventCallback("PreEnd", self.viewObj, onSkillEnd)
    skill:RegisterEventCallback("PreEndAnim", self.viewObj, onSkillEnd)
    skill:RegisterEventCallback("Interrupt", self.viewObj, onSkillEnd)
  end
  skill:PlaySkill()
  return true
end

function NpcSkillPlayComponent:PlayCommonPetInteractionSkill(petElement, target, onPetSkillEnd)
  local skillPath = NPCModuleEnum.UnLockSkillPathMap[petElement]
  if string.IsNilOrEmpty(skillPath) then
    Log.Error("PlayCommonPetInteractionSkill Error, Not Find Skill with : ", petElement)
    return false
  end
  
  local function registerEvent(skill)
    if onPetSkillEnd then
      skill:RegisterEventCallback("PetSkillEnd", target, onPetSkillEnd)
    end
  end
  
  return self:PlaySkill("/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/" .. skillPath, self.viewObj, target, registerEvent)
end

return NpcSkillPlayComponent
