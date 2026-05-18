local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local Base = WorldCombatActionBase
local WorldCombatActionSelectPos = Base:Extend("WorldCombatActionSelectPos")

function WorldCombatActionSelectPos:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionSelectPos:InternalExecute()
  Base.InternalExecute(self)
  local skillObj = self.Owner.skillObj
  if not skillObj then
    return
  end
  skillObj:SetSelectLocations(self.ServerInfo.select_pos)
end

return WorldCombatActionSelectPos
