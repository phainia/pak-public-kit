local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = PetActionBase
local PetActionDestroy = Base:Extend("PetActionDestroy")

function PetActionDestroy:OnExecute()
  self:PlayPetSkill()
end

function PetActionDestroy:PlayPetSkill()
  local PetView = self:GetRunnerView()
  local NPCView = self:GetOwnerNPCView()
  if not PetView or not NPCView then
    self:Finish(false, true)
    return
  end
  local SkillPath = self.Config.action_param2
  if string.IsNilOrEmpty(SkillPath) then
    if not self.Runner or not self.Runner.ThrowSession then
      return
    end
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.Runner.ThrowSession.petData.base_conf_id)
    if not PetBaseConf then
      return
    end
    local DamageTypes = PetBaseConf.unit_type
    if #DamageTypes > 1 then
      self.interact_type = DamageTypes[2]
    else
      self.interact_type = DamageTypes[1]
    end
    self:DoPetTypeInteraction(self, self.PreSubmit)
  else
    NPCView.RocoSkill:StopCurrentSkill()
    local Skill = RocoSkillProxy.Create(SkillPath, NPCView.RocoSkill, PriorityEnum.Active_Throw_Pet)
    if not Skill then
      Log.Error("Can't find skill from skill component")
      self:Finish(false, true)
      return
    end
    Skill:SetCaster(PetView)
    Skill:SetTargets({NPCView})
    Skill:RegisterEventCallback("PetSkillEnd", self, self.PreSubmit)
    Skill:RegisterEventCallback("Interrupt", self, self.PreSubmit)
    Skill:RegisterEventCallback("End", self, self.PreSubmit)
    Skill:PlaySkill()
  end
end

function PetActionDestroy:PreSubmit(Success)
  if not Success then
    return
  end
  self:PlayNpcSkill()
end

function PetActionDestroy:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  self:Finish(0 == rsp.ret_info.ret_code, true)
end

function PetActionDestroy:PlayNpcSkill()
  local SkillPath = self.Config.action_param4
  if not string.IsNilOrEmpty(SkillPath) then
    local PetView = self:GetRunnerView()
    local NPCView = self:GetOwnerNPCView()
    if not PetView or not NPCView then
      self:Finish(false, true)
      return
    end
    NPCView.RocoSkill:StopCurrentSkill()
    local Skill = RocoSkillProxy.Create(SkillPath, NPCView.RocoSkill, PriorityEnum.Active_Throw_Pet)
    if not Skill then
      Log.Error("Can't find skill from skill component")
      self:Finish(false, true)
      return
    end
    Skill:SetCaster(NPCView)
    Skill:SetTargets({PetView})
    Skill:RegisterEventCallback("PreEndAnim", self, self.PlayNpcSkillComplete)
    Skill:RegisterEventCallback("PreEnd", self, self.PlayNpcSkillComplete)
    Skill:RegisterEventCallback("Interrupt", self, self.PlayNpcSkillComplete)
    Skill:RegisterEventCallback("End", self, self.PlayNpcSkillComplete)
    Skill:PlaySkill()
  else
    self:Submit()
  end
end

function PetActionDestroy:PlayNpcSkillComplete()
  self:Submit()
end

function PetActionDestroy:Finish(Success, SelfFinished)
  if SelfFinished then
    Base.Finish(self, Success)
  end
end

return PetActionDestroy
