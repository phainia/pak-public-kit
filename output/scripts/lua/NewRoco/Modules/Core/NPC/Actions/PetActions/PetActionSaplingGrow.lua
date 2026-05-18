local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionSaplingGrow = Base:Extend("PetActionSaplingGrow")

function PetActionSaplingGrow:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionSaplingGrow:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionSaplingGrow:ContinueNormalInteract()
  return false
end

function PetActionSaplingGrow:OnExecute()
  local Sapling = self:GetOwnerNPCView()
  if not Sapling then
    self:Finish(false)
    return nil
  end
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.Runner.ThrowSession.petData.base_conf_id)
  if not PetBaseConf then
    self:Finish(false)
    return nil
  end
  local PetDamageType = PetBaseConf.unit_type
  local WaterType = Enum.SkillDamType[self.Config.action_param1]
  if table.contains(PetDamageType, WaterType) and Sapling.bIsSeeding then
    self:PlayGrowSkill()
  else
    self:Finish(false)
    return nil
  end
  self:Submit()
end

function PetActionSaplingGrow:PlayGrowSkill()
  local PetView = self:GetRunnerView()
  if not PetView then
    Log.Error("Can't find pet view")
    self:SkillFailed()
    return nil
  end
  local TargetView = self:GetOwnerNPCView()
  if not TargetView then
    Log.Error("Can't find target view")
    self:SkillFailed()
    return nil
  end
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_WenDu_Jiaoshui_temp.G6_WenDu_Jiaoshui_temp"
  local SkillComp = self:GetRunnerSkillComponent()
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  if not Skill then
    Log.Error("Can't find skill from skill component")
    self:SkillFailed()
    return nil
  end
  Skill:SetAdditions("pet", PetView)
  Skill:SetCaster(PetView)
  Skill:SetTargets({TargetView})
  Skill:RegisterEventCallback("End", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  Skill:RegisterEventCallback("Interrupt", self, self.SkillFailed)
  Skill:PlaySkill()
end

function PetActionSaplingGrow:SkillFailed()
  Log.Error("Skill failed!")
  self:Finish(false)
  return nil
end

function PetActionSaplingGrow:OnSubmit(rsp)
  if 0 == rsp.ret_info.ret_code then
  else
    self:Finish(false)
  end
end

function PetActionSaplingGrow:SkillComplete()
  local Sapling = self:GetOwnerNPCView()
  if not Sapling then
    Log.Error("Can't find target view")
    return nil
  end
  Sapling:GrowUp()
  self:Finish(true)
end

return PetActionSaplingGrow
