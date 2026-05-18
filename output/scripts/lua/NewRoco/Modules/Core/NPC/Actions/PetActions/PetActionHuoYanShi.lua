local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = PetActionBase
local PetActionHuoYanShi = Base:Extend("PetActionHuoYanShi")

function PetActionHuoYanShi:OnExecute()
  self:StartSkill()
end

function PetActionHuoYanShi:ContinueNormalInteract()
  return false
end

function PetActionHuoYanShi:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAN_FRONT
end

function PetActionHuoYanShi:StartSkill()
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
  local SKILL_PATH
  for _, unit_type in pairs(petData.unit_type) do
    if unit_type == Enum.SkillDamType.SDT_WATER then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/G6_XBJH_Wat.G6_XBJH_Wat"
      break
    end
    if unit_type == Enum.SkillDamType.SDT_STONE then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/G6_XBJH_Ear.G6_XBJH_Ear"
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
  skillObj:PlaySkill(self, self.OnSkillCallBack)
end

function PetActionHuoYanShi:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("PetActionHuoYanShi failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function PetActionHuoYanShi:OnPutOut(name, skill)
  self:GetOwnerNPCView():Extinguish()
end

function PetActionHuoYanShi:GetPetbaseConf()
  if not self.Runner then
    return
  end
  if not self.Runner:IsPet() then
    return
  end
  local Param = self.Runner.config.traverse_data_param
  return _G.DataConfigManager:GetPetbaseConf(Param[1])
end

function PetActionHuoYanShi:SkillComplete(name, skill)
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
  local SKILL_PATH
  for _, unit_type in pairs(petData.unit_type) do
    if unit_type == Enum.SkillDamType.SDT_WATER then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_Collected_HuoYanShi_Wat.G6_Scene_Collected_HuoYanShi_Wat"
      break
    end
    if unit_type == Enum.SkillDamType.SDT_STONE then
      SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/G6_XBJH_Ear01.G6_XBJH_Ear01"
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
  skillObj:RegisterEventCallback("PreEnd", self, self.StoneSkillComplete)
  skillObj:RegisterEventCallback("PreEndAnim", self, self.StoneSkillComplete)
  skillObj:RegisterEventCallback("End", self, self.StoneSkillComplete)
  skillObj:RegisterEventCallback("Interrupt", self, self.StoneSkillComplete)
  skillObj:RegisterEventCallback("OnPutOut", self, self.OnPutOut)
  skillObj:PlaySkill(self, self.OnSkillCallBack)
end

function PetActionHuoYanShi:StoneSkillComplete()
  self:Submit()
  self:Finish(true)
end

function PetActionHuoYanShi:SkillFailed()
  self:Finish(false)
end

return PetActionHuoYanShi
