local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local Base = WorldCombatActionBase
local WorldCombatActionJumpEnd = Base:Extend("WorldCombatActionJump")

function WorldCombatActionJumpEnd:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionJumpEnd:InternalExecute()
  self.Runner:SendEvent(WorldCombatSkillEvent.SKILL_JUMP_END)
end

return WorldCombatActionJumpEnd
