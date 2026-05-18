local Base = require("NewRoco.AI.Requester.RequesterInterface")
local RequesterQueued = Base:Extend("RequesterQueued")

function RequesterQueued:OnRequest(param, caller, callback)
  self:PushRequest(param, caller, callback)
  if self.state == AIDefines.ActionState.Idle then
    self:TryDoNextAction()
    return true
  else
    return false
  end
end

function RequesterQueued:OnActEnd(result)
  if result == AIDefines.ActionResult.Success and self._requests:Size() > 1 then
    self:PopRequest(AIDefines.ActionResult.Continue)
  else
    self:PopRequest(result)
  end
  self:TryDoNextAction()
end

return RequesterQueued
