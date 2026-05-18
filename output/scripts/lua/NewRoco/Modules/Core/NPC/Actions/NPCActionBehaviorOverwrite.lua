local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionBehaviorOverwrite = Base:Extend("NPCActionBehaviorOverwrite")

function NPCActionBehaviorOverwrite:OnSubmit(rsp)
  local ret_code_ok = 0 == rsp.ret_info.ret_code
  if ret_code_ok then
    self:TriggerAiOverwrite()
  end
  Base.OnSubmit(self, rsp)
  self:Finish(ret_code_ok)
end

function NPCActionBehaviorOverwrite:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if self.SkipSubmit then
    self:TriggerAiOverwrite()
    self:Finish(true)
  end
end

function NPCActionBehaviorOverwrite:OnDialogueAction()
  self:TriggerAiOverwrite()
  Base.OnDialogueAction(self)
end

function NPCActionBehaviorOverwrite:TriggerAiOverwrite()
  local filterParam = tonumber(self.Config.action_param1) or 0
  local behaviorGroupId = tonumber(self.Config.action_param2) or 0
  if 0 == filterParam then
    local npc = self:GetOwnerNPC()
    if npc and npc.AIComponent then
      npc.AIComponent:OverrideBehavior(behaviorGroupId, _G.Enum.BehaviorOverridePriority.BOP_A)
    end
  else
    local filterTactic = 0
    UE.UDotsStatics.OverrideBehaviorBatchByConfigId(_G.UE4Helper.GetCurrentWorld(), filterParam, behaviorGroupId, filterTactic)
  end
end

return NPCActionBehaviorOverwrite
