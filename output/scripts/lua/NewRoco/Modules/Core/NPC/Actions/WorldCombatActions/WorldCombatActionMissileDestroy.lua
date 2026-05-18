local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local Base = WorldCombatActionBase
local WorldCombatActionMissileDestroy = Base:Extend("WorldCombatActionMissileDestroy")

function WorldCombatActionMissileDestroy:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionMissileDestroy:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  local missile = NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, self.ServerInfo.launch_bullet_id)
  if not missile then
    return
  end
  Log.Debug("WorldCombatActionMissileDestroy:InternalExecute", self.ServerInfo.launch_bullet_id)
  missile.missileComp:Destroy(Enum.MissileDestroyReason.MDR_LIFE_TIME_OUT)
end

return WorldCombatActionMissileDestroy
