local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local TurnComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.TurnComponent")
local Base = WorldCombatActionBase
local WorldCombatActionRotate = Base:Extend("WorldCombatActionRotate")

function WorldCombatActionRotate:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionRotate:PreExecute()
  Base.PreExecute(self)
  self.turnAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
  if not self.turnAction then
    return
  end
  self.actionType = WorldCombatActionBase.EActionType.duration
  self.actionDuration = self.turnAction:GetActionLength()
  self.targetYaw = self.ServerInfo.rotator.z / 10
end

function WorldCombatActionRotate:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.Runner.viewObj and self.ServerInfo) or not self.ServerInfo.skill_id then
    return
  end
  Log.Debug("WorldCombatActionRotate:InternalExecute", self.ServerInfo.skill_id, self.ServerInfo.rotator.x, self.ServerInfo.rotator.y, self.ServerInfo.rotator.z, UE.FRotator(0, self.ServerInfo.rotator.z / 10, 0), self.Runner:GetActorRotation())
  if not UE.UObject.IsValid(self.turnAction) then
    return
  end
  local bInstantRotate = self.turnAction.bInstantRotate
  if bInstantRotate then
    self:RotateEnd()
  else
    local TurnComp = self.Runner:EnsureComponent(TurnComponent)
    local bUseTurnAnim = self.turnAction.bUseTurnAnim or false
    local time = self.actionDuration / self.turnAction.AnimSpeedScale
    if time <= 0 then
      time = 0.1
    end
    TurnComp:StartTurn_S(self.targetYaw, time, bUseTurnAnim, false, 1.0, self, self.RotateEnd, true)
  end
end

function WorldCombatActionRotate:RotateEnd()
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  self.Runner.viewObj:K2_SetActorRotation(UE.FRotator(0, self.targetYaw, 0), false)
  self:Finish()
end

return WorldCombatActionRotate
