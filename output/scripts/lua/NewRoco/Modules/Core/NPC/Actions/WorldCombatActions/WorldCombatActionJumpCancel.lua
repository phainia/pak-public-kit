local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local WorldCombatActionJumpCancel = Base:Extend("WorldCombatActionJumpCancel")

function WorldCombatActionJumpCancel:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionJumpCancel:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    local curPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.cur_pos)
    local fallingPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.falling_pos)
    if curPos and fallingPos then
      UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), curPos, fallingPos, 5, UE.FLinearColor(1, 0.05, 0, 0), 20, 3)
    end
  end
  self.Runner:SendEvent(WorldCombatSkillEvent.SKILL_JUMP_END, SceneUtils.ServerPos2ClientPos(self.ServerInfo.cur_pos), true)
end

return WorldCombatActionJumpCancel
