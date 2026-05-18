local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionPetAdjustTeam = Base:Extend("NPCActionPetAdjustTeam")

function NPCActionPetAdjustTeam:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPetAdjustTeam:ExecuteWithModel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenWorldPetTeamPanel, self)
end

function NPCActionPetAdjustTeam:PlayCampingSkill()
  local CampFire = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/UI/Team/G6_UI_PetTeamBack.G6_UI_PetTeamBack"
  local skillClass = UE4.UClass.Load(skillPath)
  local skillObj = CampFire.RocoSkill:FindOrAddSkillObj(skillClass)
  skillObj:SetCaster(CampFire)
  skillObj:RegisterEventCallback("PreEnd", self, self.OnCameraStartEnd)
  skillObj:RegisterEventCallback("End", self, self.OnCameraStartEnd)
  skillObj:SetPassive(true)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillObj)
end

function NPCActionPetAdjustTeam:Callback(Characters)
  self:GetOwnerNPCView().RocoSkill:PlaySkill(self.skillObj)
end

function NPCActionPetAdjustTeam:OnCameraStartEnd(Event, Skill)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.PlayPetTeamOpenAnimation)
end

function NPCActionPetAdjustTeam:EndAction()
  Log.Debug("NPCActionOpenBottleTimes:EndAction")
  local CampFire = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/UI/Team/G6_UI_PetTeamshow.G6_UI_PetTeamshow"
  local skillClass = UE4.UClass.Load(skillPath)
  local skillObj = CampFire.RocoSkill:FindOrAddSkillObj(skillClass)
  skillObj:SetCaster(CampFire)
  skillObj:SetPassive(true)
  skillObj:RegisterEventCallback("End", self, self.OnCameraEndEnd)
  skillObj:RegisterEventCallback("PreEnd", self, self.OnCameraEndEnd)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillObj)
end

function NPCActionPetAdjustTeam:OnCameraEndEnd(Event, Skill)
  self:Finish()
end

return NPCActionPetAdjustTeam
