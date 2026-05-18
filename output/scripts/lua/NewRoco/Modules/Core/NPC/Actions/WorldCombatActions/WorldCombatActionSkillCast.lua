local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local WorldCombatActionSkillCast = Base:Extend("WorldCombatActionSkillCast")

function WorldCombatActionSkillCast:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionSkillCast:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Owner and self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local target = self:GetTargetByServerInfo()
  local targetPos
  if self.ServerInfo.target_pos then
    targetPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.target_pos.pos)
  end
  self.Owner:ClientTryCastSkill(self.ServerInfo.skill_id, target and target.viewObj or nil, targetPos)
end

return WorldCombatActionSkillCast
