local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local ActionUtils = require("NewRoco.Modules.Core.NPC.Actions.ActionUtils")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = PetActionBase
local PetActionTree = Base:Extend("PetActionTree")

function PetActionTree:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.bSkillCompleted = false
  self.bSubmitted = false
end

function PetActionTree:OnExecute()
  local OwnerView = self:GetOwnerNPCView()
  if OwnerView and self:HasControlAuthority() then
    OwnerView.HoldFruit = true
    OwnerView.fruits = {}
  end
  self.bSubmitted = false
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.SceneNpc then
    self.bSkillCompleted = true
    self:Submit()
  else
    self.bSkillCompleted = false
    self:StartSkill()
  end
end

function PetActionTree:StartSkill()
  local PetView = self:GetRunnerView()
  if not PetView then
    Log.Error("Can't find pet view")
    self:SkillFailed()
    return
  end
  local TargetView = self:GetOwnerNPCView()
  if not TargetView then
    Log.Error("Can't find target view")
    self:SkillFailed()
    return
  end
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/G6_Scene_Caiji_Shu.G6_Scene_Caiji_Shu"
  local SkillComp = self:GetRunnerSkillComponent()
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  if not Skill then
    Log.Error("Can't find skill from skill component")
    self:SkillFailed()
    return
  end
  Skill:SetCaster(PetView)
  Skill:SetTargets({TargetView})
  Skill:RegisterEventCallback("End", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  Skill:RegisterEventCallback("Interrupt", self, self.SkillComplete)
  Skill:RegisterEventCallback("TriggerBeHit", self, self.SkillImpact)
  Skill:RegisterEventCallback("TriggerPreHit", self, self.SkillPreProcess)
  Skill:PlaySkill()
end

function PetActionTree:SkillFailed()
  self:Finish(false)
end

function PetActionTree:SkillPreProcess(Name, Skill)
  self:SetSessionRecycle(false)
end

function PetActionTree:SkillComplete(Name, Skill)
  self.bSkillCompleted = true
  if self.bSkillCompleted and self.bSubmitted then
    self:Finish(true)
  end
end

function PetActionTree:OnFinish()
  self:SetSessionRecycle(true)
end

function PetActionTree:SkillImpact(Name, Skill)
  self:Submit()
end

function PetActionTree:RushTree()
  local View = self:GetOwnerNPCView()
  if not View then
    return
  end
  if not self:HasControlAuthority() then
    return
  end
  if self.NextSubmissionMode == ActionUtils.ActionSubmissionMode.SceneNpc then
    View.InteractType = NPCModuleEnum.InteractType.PET_BULL_RUSH
  end
  View.PetBullRush = true
  View.HoldFruit = false
end

function PetActionTree:OnSubmit(rsp)
  self.bSubmitted = true
  self:ConsumeOwnerActorTag()
  self:RushTree()
  if self.bSkillCompleted and self.bSubmitted then
    self:Finish(true)
  end
end

function PetActionTree:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR_BIG
end

return PetActionTree
