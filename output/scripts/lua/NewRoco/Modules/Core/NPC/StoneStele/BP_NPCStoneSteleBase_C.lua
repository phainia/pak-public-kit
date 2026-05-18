local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = ViewNPCBase
local BP_NPCStoneSteleBase_C = Base:Extend("BP_NPCStoneSteleBase_C")

function BP_NPCStoneSteleBase_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_NPCStoneSteleBase_C:ReceiveEndPlay(reason)
  Base.ReceiveEndPlay(self, reason)
end

function BP_NPCStoneSteleBase_C:OnVisible()
  Base.OnVisible(self)
  if not self.sceneCharacter then
    return
  end
  local InterComp = self.sceneCharacter.InteractionComponent
  local AllOptions = InterComp:GetAllOptions()
  for _, Option in pairs(AllOptions) do
    if not Option:IsOptionEnable() then
    elseif Option.optionInfo.succ_exec_times > 0 then
    else
      local Action = Option.CurrentAction
      if not Action then
      elseif Action.Config.action_type ~= Enum.ActionType.ACT_STELE_KNOWLEDGE then
      elseif Action.Config.action_param1 == "1" then
        self:PlayLoop()
        break
      end
    end
  end
end

function BP_NPCStoneSteleBase_C:GetActorForwardVector()
  return self:GetActorRightVector()
end

function BP_NPCStoneSteleBase_C:PlayLoop()
  local SkillComp = self.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Loop", SkillComp, PriorityEnum.Passive_NPC_BornDie)
  Skill:SetCaster(self)
  Skill:SetTargets({self})
  Skill:RegisterEventCallback("End", self, self.SaveLight)
  SkillComp:StopCurrentSkill()
  Skill:PlaySkill()
end

function BP_NPCStoneSteleBase_C:GetHalfHeight()
  return 780
end

function BP_NPCStoneSteleBase_C:SaveLight(Name, Skill)
  local Fx = Skill.Blackboard:GetValueAsObject("FXLoopLight")
  if Fx then
    self.BeamFxComponent = Fx
  end
  Skill.Blackboard:RemoveObjectValue("FXLoopLight")
end

return BP_NPCStoneSteleBase_C
