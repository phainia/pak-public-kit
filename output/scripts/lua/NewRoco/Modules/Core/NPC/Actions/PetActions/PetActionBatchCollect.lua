local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PetActionEvent = require("NewRoco.Modules.Core.NPC.Actions.PetActionEvent")
local PetActionBase = require("NewRoco.Modules.Core.NPC.Actions.PetActionBase")
local Base = PetActionBase
local PetActionBatchCollect = Base:Extend("PetActionBatchCollect")

function PetActionBatchCollect:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.Options = nil
  self.bAlreadyInteracted = nil
end

function PetActionBatchCollect:Execute(Runner, Options, bAlreadyInteracted)
  self.Options = Options
  self.bAlreadyInteracted = bAlreadyInteracted
  Base.Execute(self, Runner)
end

function PetActionBatchCollect:OnExecute()
  local SkillPath
  if self.bAlreadyInteracted then
    SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/Pet_Caiji_Common_Happy.Pet_Caiji_Common_Happy"
  else
    SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneCaiji/Pet_Caiji_Common_Hua.Pet_Caiji_Common_Hua"
  end
  local View = self:GetRunnerView()
  if not View then
    self:OnHarvest()
    self:OnHarvestSkillComplete()
    return
  end
  local SkillComp = View.RocoSkill
  local Skill = RocoSkillProxy.Create(SkillPath, SkillComp, PriorityEnum.Active_Throw_Pet)
  Skill:SetCaster(View)
  Skill:SetPassive(true)
  Skill:RegisterEventCallback("Harvest", self, self.OnHarvest)
  Skill:RegisterEventCallback("End", self, self.OnHarvestSkillComplete)
  Skill:PlaySkill()
end

function PetActionBatchCollect:OnHarvest(Name, Skill)
  self:SendEvent(PetActionEvent.OnHarvest, self.Options)
end

function PetActionBatchCollect:OnHarvestSkillComplete(Name, Skill)
  self:Finish(true)
end

function PetActionBatchCollect:Submit()
end

function PetActionBatchCollect:InternalSyncAction(Status)
  local req = _G.ProtoMessage:newZoneClientOperationReq()
  req.operation.operator_id = self.Runner:GetServerId()
  req.operation.npc_action_info = nil
  req.operation.aim_info = nil
  local PetActionSync = req.operation.pet_action_info
  PetActionSync.operation_target_id = 0
  PetActionSync.operator_owner_id = self.Runner:GetCreatorID()
  PetActionSync.operation_type = Enum.ActionType.ACT_PET_NORMAL
  PetActionSync.action_status = Status
  PetActionSync.option_id = 0
  PetActionSync.conf_type = ProtoEnum.ClientOperationConfType.COCT_NPC_OPTION_CONF
  PetActionSync.conf_id = 0
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req)
end

return PetActionBatchCollect
