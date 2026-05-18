local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local Base = WorldCombatActionBase
local WorldCombatActionLookAt = Base:Extend("WorldCombatActionLookAt")

function WorldCombatActionLookAt:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionLookAt:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local target = self:GetTargetByServerInfo()
  if not target then
    return
  end
  self.Runner:SetHeadLookAtActor(target.viewObj, true, false)
end

return WorldCombatActionLookAt
