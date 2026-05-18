local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local Base = WorldCombatActionBase
local WorldCombatActionRcdEnd = Base:Extend("WorldCombatActionRcdEnd")

function WorldCombatActionRcdEnd:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionRcdEnd:InternalExecute()
  Base.InternalExecute(self)
  self.Runner:SendEvent(WorldCombatSkillEvent.SKILL_RCD_END, self.ServerInfo.GUID)
end

return WorldCombatActionRcdEnd
