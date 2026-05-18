local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionOpenLevelAwards = Base:Extend("NPCActionOpenLevelAwards")

function NPCActionOpenLevelAwards:ExecuteWithModel()
  local CampFire = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/LevelUpRewardsFocus.LevelUpRewardsFocus"
  local skillObj = RocoSkillProxy.Create(skillPath, CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  skillObj:SetCaster(CampFire)
  skillObj:RegisterEventCallback("End", self, self.OnCameraStartEnd)
  skillObj:SetPassive(true)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillObj)
end

function NPCActionOpenLevelAwards:OnCameraStartEnd(Event, Skill)
  _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.RequestOpenLevelPanel, self)
end

function NPCActionOpenLevelAwards:EndAction()
  local CampFire = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/LevelUpRewardsEnd.LevelUpRewardsEnd"
  local skillObj = RocoSkillProxy.Create(skillPath, CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  skillObj:SetCaster(CampFire)
  skillObj:SetPassive(true)
  skillObj:RegisterEventCallback("End", self, self.OnCameraEndEnd)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillObj)
end

function NPCActionOpenLevelAwards:OnCameraEndEnd(Event, Skill)
  self:Finish()
end

return NPCActionOpenLevelAwards
