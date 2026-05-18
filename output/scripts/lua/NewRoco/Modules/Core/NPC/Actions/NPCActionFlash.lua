require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionFlash = Base:Extend("NPCActionFlash")

function NPCActionFlash:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionFlash:Execute()
  Log.Debug("NPCActionFlash:Execute")
  Base.Execute(self)
  self.NPCId = tonumber(self.Config.action_param1)
  local TargetPet = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNpcsByFilter, self, self.TargetID)
  for _, v in pairs(TargetPet) do
    local NPCComp = v.viewObj.RocoSkill
    local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_PetLizi", NPCComp, PriorityEnum.Active_Player_Action)
    if Skill then
      Skill:SetWithLoadAndPlay(true)
      Skill:SetCaster(v.viewObj)
      Skill:PlaySkill()
    end
  end
  self:Finish(true)
end

function NPCActionFlash:TargetID(v)
  if self.NPCId == v.serverData.npc_base.npc_cfg_id then
    return true
  else
    return false
  end
end

function NPCActionFlash:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionFlash failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

return NPCActionFlash
