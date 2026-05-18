local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = PetActionBase
local PetActionLightTorch = Base:Extend("PetActionLightTorch")

function PetActionLightTorch:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function PetActionLightTorch:GetThrowEffectType()
  return ProtoEnum.ThrowEffect.TRIG_PET_INTERACT
end

function PetActionLightTorch:GetRangeType()
  return Enum.PetReleaseRange.PRR_FAR
end

function PetActionLightTorch:OnExecute()
  local Torch = self:GetOwnerNPCView()
  if not Torch then
    self:Finish(false)
    return nil
  end
  local PetBaseConf = self:GetPetbaseConf()
  if not PetBaseConf then
    self:Finish(false)
    return nil
  end
  if ProtoEnum.SpaceActorLogicStatus[self.Config.action_param1] == ProtoEnum.SpaceActorLogicStatus.SALS_TRIGGER_ON then
    self.isLightUp = true
    self:PlayPetAction()
  elseif ProtoEnum.SpaceActorLogicStatus[self.Config.action_param1] == ProtoEnum.SpaceActorLogicStatus.SALS_TRIGGER_OFF then
    self.isLightUp = false
    self:PlayPetAction()
  else
    self:Finish(false)
    return nil
  end
end

function PetActionLightTorch:PlayPetAction()
  local petView = self:GetRunnerView()
  local targetView = self:GetOwnerNPCView()
  if not petView or not targetView then
    Log.Error("PetActionLightTorch:PlayPetAction can't find pet or viewObj")
    self:SkillFailed()
    return
  end
  local petElement = self.isLightUp and Enum.SkillDamType.SDT_FIRE or Enum.SkillDamType.SDT_WATER
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Xibiejiaohu/" .. NPCModuleEnum.UnLockSkillPathMap[petElement]
  local Klass = UE.UClass.Load(skillPath)
  if not Klass then
    Log.Error("PetActionLightTorch:PlayPetAction, skill not found : ", skillPath)
    self:SkillFailed()
    return nil
  end
  local skill = RocoSkillProxy.Create(skillPath, petView.RocoSkill, PriorityEnum.Active_Throw_Pet)
  if not skill then
    return
  end
  skill:SetCaster(petView)
  skill:SetTargets({targetView})
  skill:RegisterEventCallback("PetSkillEnd", self, self.PetSkillEnd)
  skill:PlaySkill()
end

function PetActionLightTorch:PetSkillEnd(Name, Skill)
  self:PlayTorchSkill(self.isLightUp)
  self:Submit()
end

function PetActionLightTorch:OnSubmit(rsp)
  if 0 == rsp.ret_info.ret_code then
  else
    self:Finish(false)
  end
end

function PetActionLightTorch:OnLightUp()
  local Torch = self:GetOwnerNPCView()
  if not Torch then
    self:Finish(false)
    return nil
  end
  Torch:LightUp()
  self:ConsumeOwnerActorTag()
end

function PetActionLightTorch:OnPutDown()
  local Torch = self:GetOwnerNPCView()
  if not Torch then
    self:Finish(false)
    return nil
  end
  Torch:PutDown()
  self:ConsumeOwnerActorTag()
end

function PetActionLightTorch:PlayTorchSkill(bLightUp)
  local TargetView = self:GetOwnerNPCView()
  if not TargetView then
    Log.Error("Can't find target view")
    self:SkillFailed()
    return nil
  end
  local SkillPath
  if bLightUp then
    SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Fir_HuoPen01.G6_Fir_HuoPen01"
  else
    SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Wat_HuoPen01.G6_Wat_HuoPen01"
  end
  local SkillComp = TargetView.RocoSkill
  SkillComp:StopCurrentSkill()
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  if not Skill then
    Log.Error("Can't find skill from skill component")
    self:SkillFailed()
    return nil
  end
  Skill:SetCaster(TargetView)
  Skill:RegisterEventCallback("End", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEnd", self, self.SkillComplete)
  Skill:RegisterEventCallback("PreEndAnim", self, self.SkillComplete)
  if bLightUp then
    Skill:RegisterEventCallback("TorchEnd", self, self.OnLightUp)
  else
    Skill:RegisterEventCallback("TorchEnd", self, self.OnPutDown)
  end
  self:SetInteractingState(true)
  Skill:PlaySkill()
end

function PetActionLightTorch:SkillFailed()
  self:Finish(false)
end

function PetActionLightTorch:SkillComplete(name, Skill)
  self:Finish(true)
end

function PetActionLightTorch:OnFinish()
  self:SetInteractingState(false)
end

function PetActionLightTorch:SetInteractingState(interacting)
  local TargetView = self:GetOwnerNPCView()
  if TargetView then
    TargetView:SetInteracting(interacting)
  end
end

function PetActionLightTorch:GetPetbaseConf()
  if not self.Runner then
    return
  end
  if not self.Runner:IsPet() then
    return
  end
  local Param = self.Runner.config.traverse_data_param
  return _G.DataConfigManager:GetPetbaseConf(Param[1])
end

return PetActionLightTorch
