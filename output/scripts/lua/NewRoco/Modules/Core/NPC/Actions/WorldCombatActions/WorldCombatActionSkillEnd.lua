local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local Base = WorldCombatActionBase
local WorldCombatActionSkillEnd = Base:Extend("WorldCombatActionSkillEnd")

function WorldCombatActionSkillEnd:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionSkillEnd:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Owner and self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  self.Owner:ClientTryEndSkill(self.ServerInfo.skill_id)
end

return WorldCombatActionSkillEnd
