local NPCActionBehaviorOverwrite = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBehaviorOverwrite")
local Base = NPCActionBehaviorOverwrite
local NPCActionBehaviorOverwriteContent = Base:Extend("NPCActionBehaviorOverwriteContent")

function NPCActionBehaviorOverwriteContent:TriggerAiOverwrite()
  local filterParam = tonumber(self.Config.action_param1) or 0
  local behaviorGroupId = tonumber(self.Config.action_param2) or 0
  if 0 == filterParam then
    local npc = self:GetOwnerNPC()
    if npc and npc.AIComponent then
      npc.AIComponent:OverrideBehavior(behaviorGroupId, _G.Enum.BehaviorOverridePriority.BOP_A)
    end
  else
    local filterTactic = 1
    UE.UDotsStatics.OverrideBehaviorBatchByConfigId(_G.UE4Helper.GetCurrentWorld(), filterParam, behaviorGroupId, filterTactic)
  end
end

return NPCActionBehaviorOverwriteContent
