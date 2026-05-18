local AIDefines = require("NewRoco.AI.AIDefines")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local TurnRequester = require("NewRoco.Modules.Core.Scene.Component.Movement.Actions.TurnRequester")
local Base = ActorComponent
local TurnComponent = Base:Extend("TurnComponent")

function TurnComponent:Attach(owner)
  Base.Attach(self, owner)
  self.requester = TurnRequester()
  self.requester:Attach(self.owner)
end

function TurnComponent:DeAttach()
  self.requester:DeAttach(self.owner)
  Base.DeAttach(self)
end

function TurnComponent:StartTurn_S(Yaw, Time, bPlayDefaultAnim, TimingMethod, AnimRate, caller, callback, bForceRotateInSkill, bUseAdditive)
  local SkillComp = self.owner.WorldCombatSkillComponent
  local bIsPlayingSkill = SkillComp and SkillComp.currentContext ~= nil
  if bIsPlayingSkill and not bForceRotateInSkill then
    Log.Debug("TurnComponent:StartTurn_S", self.owner:GetServerId())
    return false
  end
  local param = TurnRequester.CreateParam()
  param.Yaw = Yaw
  param.Time = Time
  param.PlayDefaultAnim = bPlayDefaultAnim
  param.UseAdditive = bUseAdditive
  if TimingMethod then
    param.TimingMethod = TimingMethod or false
  end
  if AnimRate then
    param.AnimRate = AnimRate or 1
  end
  self.requester:Request(param, caller, callback)
end

function TurnComponent:StopTurn(result, interrupt, bUseAdditive)
  if self.requester and self.requester.state ~= AIDefines.ActionState.Idle then
    if interrupt then
      self.requester:Interrupt()
      self.requester:ActEnd(AIDefines.ActionResult.Aborted)
    else
      self.requester:ActEnd(result)
    end
  end
end

function TurnComponent:IsTurning()
  if self.requester then
    return self.requester:IsTuring()
  else
    return false
  end
end

function TurnComponent:GetFutureRotator()
  if self.requester then
    return self.requester:GetFutureRotator()
  else
    return UE.FRotator()
  end
end

function TurnComponent:DebugTurnEnd(result, req, param)
  Log.Warning("RESULT=", result, "VALID=", req == self.requester, "PARAM=", param and param.Yaw or "nil")
end

return TurnComponent
