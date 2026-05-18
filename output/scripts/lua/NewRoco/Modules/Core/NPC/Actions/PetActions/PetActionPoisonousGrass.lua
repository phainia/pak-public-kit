local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = PetActionBase
local PetActionPoisonousGrass = Base:Extend("PetActionPoisonousGrass")

function PetActionPoisonousGrass:OnExecute()
  self:StartSkill()
end

function PetActionPoisonousGrass:ContinueNormalInteract()
  return false
end

function PetActionPoisonousGrass:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR
end

function PetActionPoisonousGrass:StartSkill()
  local petView = self:GetRunnerView()
  if not petView then
    Log.Error("Cannot find pet view!")
    self:SkillFailed()
    return
  end
  local targetView = self:GetOwnerNPCView()
  if not targetView then
    Log.Error("cannot find target view!")
    self:SkillFailed()
    return
  end
  local petData = self:GetPetbaseConf()
  if not petData then
    Log.Error("cannot find data of pet with gid", self:GetRunnerView().sceneCharacter.serverData.pet_info.gid)
    return
  end
  local SKILL_PATH
  for _, unit_type in pairs(petData.unit_type) do
    if unit_type == Enum.SkillDamType.SDT_TOXIC then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Collected_Poisionus_Poi.G6_Scene_Collected_Poisionus_Poi"
      break
    end
    if unit_type == Enum.SkillDamType.SDT_WING then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/G6_XBJH_Win.G6_XBJH_Win"
      break
    end
  end
  if not SKILL_PATH then
    Log.Error("Unit type of pet cannot interact!!!", petData.unit_type[1])
    self:SkillFailed()
    return
  end
  local skillComp = self:GetRunnerSkillComponent()
  if not skillComp then
    Log.Error("Cannot find RocoSkillComponent from BP!")
    self:SkillFailed()
    return
  end
  local skillObj = RocoSkillProxy.Create(SKILL_PATH, skillComp, PriorityEnum.Active_Throw_Pet)
  if not skillObj then
    Log.Error("cannot find skill from RocoSkillComponent!")
    self:SkillFailed()
    return
  end
  skillObj:SetCaster(petView)
  skillObj:SetTargets({targetView})
  skillObj:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  skillObj:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  skillObj:RegisterEventCallback("End", self, self.SkillComplete)
  skillObj:RegisterEventCallback("Interrupt", self, self.SkillComplete)
  skillObj:RegisterEventCallback("PetSkillEnd", self, self.SkillComplete)
  skillObj:RegisterEventCallback("OnAbsorbEnd", self, self.OnAbsorbEnd)
  skillObj:PlaySkill(self, self.OnSkillCallBack)
end

function PetActionPoisonousGrass:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("PetActionPoisonousGrass failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function PetActionPoisonousGrass:GrassSkillComplete()
  self:Submit()
  self:Finish(true)
end

function PetActionPoisonousGrass:SkillFailed()
  self:Finish(false)
end

function PetActionPoisonousGrass:GetPetbaseConf()
  if not self.Runner then
    return
  end
  if not self.Runner:IsPet() then
    return
  end
  local Param = self.Runner.config.traverse_data_param
  return _G.DataConfigManager:GetPetbaseConf(Param[1])
end

function PetActionPoisonousGrass:SkillComplete(name, skill)
  local collectedItem = skill:GetTargets()[1]
  skill:UnregisterEventCallback("PreEnd", self, self.SkillComplete)
  skill:UnregisterEventCallback("PreEndAnim", self, self.SkillComplete)
  skill:UnregisterEventCallback("End", self, self.SkillComplete)
  skill:UnregisterEventCallback("Interrupt", self, self.SkillComplete)
  skill:UnregisterEventCallback("PetSkillEnd", self, self.SkillComplete)
  local skillComp = collectedItem.RocoSkill
  if not skillComp then
    Log.Error("Cannot find RocoSkillComponent from BP!")
    self:SkillFailed()
    return
  end
  local petData = self:GetPetbaseConf()
  if not petData then
    Log.Error("petData is nil !!!")
    self:SkillFailed()
    return
  end
  local SKILL_PATH
  for _, unit_type in pairs(petData.unit_type) do
    if unit_type == Enum.SkillDamType.SDT_TOXIC then
      SKILL_PATH = nil
      self:OnAbsorbEnd()
      self:GrassSkillComplete()
      return
    end
    if unit_type == Enum.SkillDamType.SDT_WING then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Collected_Poisionus_Win.G6_Scene_Collected_Poisionus_Win"
      break
    end
  end
  if not SKILL_PATH then
    Log.Error("Unit type of pet cannot interact!!!", petData.unit_type[1])
    self:SkillFailed()
    return
  end
  local skillObj = RocoSkillProxy.Create(SKILL_PATH, skillComp, PriorityEnum.Active_Throw_Pet)
  if not skillObj then
    Log.Error("cannot find skill from RocoSkillComponent!")
    self:SkillFailed()
    return
  end
  skillObj:SetCaster(collectedItem)
  skillObj:SetTargets({collectedItem})
  skillObj:RegisterEventCallback("PreEnd", self, self.GrassSkillComplete)
  skillObj:RegisterEventCallback("PreEndAnim", self, self.GrassSkillComplete)
  skillObj:RegisterEventCallback("End", self, self.GrassSkillComplete)
  skillObj:RegisterEventCallback("Interrupt", self, self.GrassSkillComplete)
  skillObj:RegisterEventCallback("OnAbsorbEnd", self, self.OnAbsorbEnd)
  skillObj:PlaySkill(self, self.OnSkillCallBack)
end

function PetActionPoisonousGrass:OnAbsorbEnd(name, skill)
  local animInst = self:GetOwnerNPCView():GetAnimInstance()
  if not animInst then
    Log.Error("PoisonousGrass cannot find AnimInstance!")
    return
  end
  animInst.isAbsorbed = true
end

return PetActionPoisonousGrass
