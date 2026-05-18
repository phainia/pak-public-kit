local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = WorldCombatActionBase
local WorldCombatActionCrushEnd = Base:Extend("WorldCombatActionCrushEnd")

function WorldCombatActionCrushEnd:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionCrushEnd:PreExecute()
  Base.PreExecute(self)
end

function WorldCombatActionCrushEnd:InternalExecute()
  Base.InternalExecute(self)
  local halfHeight = self.Runner:GetScaledHalfHeight()
  local endPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.stop_point.pos)
  self.crushAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
  if self.crushAction and not self.crushAction.IsNotForceFixToFloor then
    endPos = SceneUtils.WorldCombatGetPosInLand(endPos, self.Runner)
    if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
      UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), endPos, SceneUtils.ServerPos2ClientPos(self.ServerInfo.stop_point.pos), 10, UE.FLinearColor(1, 1, 0, 1), 10.0, 5)
    end
  else
    endPos.Z = endPos.Z + halfHeight
  end
  Log.Debug("WorldCombatActionCrushEnd:InternalExecute", SceneUtils.ServerPos2ClientPos(self.ServerInfo.stop_point.pos), endPos, self.Runner:GetActorLocation())
  self.Runner:SendEvent(WorldCombatSkillEvent.SKILL_CRUSH_END, endPos, self.ServerInfo.action_time)
  self.Runner:SetActorLocation(endPos)
end

return WorldCombatActionCrushEnd
