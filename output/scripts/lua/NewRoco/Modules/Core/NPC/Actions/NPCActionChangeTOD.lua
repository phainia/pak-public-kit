local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionChangeTOD = Base:Extend("NPCActionChangeTOD")

function NPCActionChangeTOD:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionChangeTOD:ExecuteWithModel()
  if self.Config.action_param3 == "1" then
    if not _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.IsNightType) then
      local TargetTime = tonumber(self.Config.action_param1)
      local NpcId = self.OwnerNpc:GetServerId()
      _G.NRCModuleManager:DoCmd(_G.EnvSystemModuleCmd.ChangeGameTime, TargetTime, false, NpcId)
    end
    self:Finish()
  else
    local CampFire = self:GetOwnerNPCView()
    local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/ChangeTod.ChangeTod"
    local skillProxy = RocoSkillProxy.Create(skillPath, CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
    if not skillProxy then
      self:NPCActionBlackAndChange()
      self:CloseBlackScreen()
      self:OnCameraStartEnd()
      return
    end
    skillProxy:RegisterEventCallback("BlackScreen", self, self.NPCActionBlackAndChange)
    skillProxy:RegisterEventCallback("CloseBlack", self, self.CloseBlackScreen)
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillProxy, self, self.OnCameraStartEnd)
  end
end

function NPCActionChangeTOD:OnCameraStartEnd(Event, Skill)
  self:Finish()
end

function NPCActionChangeTOD:NPCActionBlackAndChange(Event, Skill)
  local TargetTime = tonumber(self.Config.action_param1)
  local action_param2 = self.Config and self.Config.action_param2
  local localizationConf = action_param2 and _G.DataConfigManager:GetLocalizationConf(action_param2)
  local TipText = localizationConf and localizationConf.msg or ""
  local NpcId = self.OwnerNpc:GetServerId()
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.GoToTime, TargetTime, TipText, NpcId)
end

function NPCActionChangeTOD:CloseBlackScreen(Event, Skill)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.FadeOutDialogueBlack)
end

return NPCActionChangeTOD
