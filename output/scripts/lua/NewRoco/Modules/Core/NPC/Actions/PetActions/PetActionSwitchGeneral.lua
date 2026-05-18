local PetTypeInteractActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetTypeInteractActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = PetTypeInteractActionBase
local PetActionSwitchGeneral = Base:Extend("PetActionSwitchGeneral")

function PetActionSwitchGeneral:OnExecute()
  self:PlayPetSkill()
end

function PetActionSwitchGeneral:PlayPetSkill()
  local PetView = self:GetRunnerView()
  local NPCView = self:GetOwnerNPCView()
  if not PetView or not NPCView then
    self:Finish(false)
    return
  end
  local SkillPath = self.Config.action_param2
  if string.IsNilOrEmpty(SkillPath) then
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.Runner.config.traverse_data_param[1])
    if not PetBaseConf then
      self:Finish(false)
      return
    end
    local DamageTypes = PetBaseConf.unit_type
    if #DamageTypes > 1 then
      self.interact_type = DamageTypes[2]
    else
      self.interact_type = DamageTypes[1]
    end
    self.Runner:LockAIForReason(true, false, _G.AIDefines.LockReason.ACTION_PROCESS)
    self:DoPetTypeInteraction(self, self.PreSubmit)
  else
    NPCView.RocoSkill:StopCurrentSkill()
    local Skill = RocoSkillProxy.Create(SkillPath, NPCView.RocoSkill, PriorityEnum.Active_Throw_Pet)
    if not Skill then
      self:Finish(false)
      return
    end
    self.Runner:LockAIForReason(true, false, _G.AIDefines.LockReason.ACTION_PROCESS)
    Skill:SetCaster(PetView)
    Skill:SetTargets({NPCView})
    Skill:RegisterEventCallback("PetSkillEnd", self, self.OnCustomSkillEnd)
    Skill:RegisterEventCallback("End", self, self.OnCustomSkillEnd)
    Skill:RegisterEventCallback("PreEnd", self, self.OnCustomSkillEnd)
    Skill:RegisterEventCallback("PreEndAnim", self, self.OnCustomSkillEnd)
    Skill:RegisterEventCallback("Interrupt", self, self.OnInterrupted)
    Skill:PlaySkill()
  end
end

function PetActionSwitchGeneral:OnInterrupted(Name, Skill)
  self:PreSubmit(false)
  self:Finish(false)
end

function PetActionSwitchGeneral:OnCustomSkillEnd(Name, Skill)
  self:PreSubmit(true)
end

function PetActionSwitchGeneral:PreSubmit(Success)
  if not Success then
    return
  end
  if self.Runner then
    self.Runner:LockAIForReason(false, false, _G.AIDefines.LockReason.ACTION_PROCESS)
  end
  self:Submit()
end

function PetActionSwitchGeneral:OnSubmit(rsp)
  self:ConsumeOwnerActorTag()
  if 0 == rsp.ret_info.ret_code then
    self:PlayNpcSkill()
  else
    self:Finish(false)
  end
end

function PetActionSwitchGeneral:PlayNpcSkill()
  local SkillPath = self.Config.action_param4
  if not string.IsNilOrEmpty(SkillPath) then
    local PetView = self:GetRunnerView()
    local NPCView = self:GetOwnerNPCView()
    if not PetView or not NPCView then
      self:Finish(false)
      return
    end
    NPCView.RocoSkill:StopCurrentSkill()
    local Skill = RocoSkillProxy.Create(SkillPath, NPCView.RocoSkill, PriorityEnum.Active_Throw_Pet)
    if not Skill then
      Log.Error("Can't find skill from skill component")
      self:Finish(false)
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
    self:Finish(true)
  end
end

function PetActionSwitchGeneral:PlayNpcSkillComplete()
  self:Finish(true)
end

return PetActionSwitchGeneral
