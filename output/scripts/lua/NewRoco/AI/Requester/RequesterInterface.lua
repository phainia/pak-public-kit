local Queue = require("Utils.Queue")
local Class = _G.MakeSimpleClass
local RequesterInterface = Class("RequesterInterface")
RequesterInterface:SetMemberCount(4)

function RequesterInterface:Ctor()
  self._requests = Queue(2)
  self._delegates = Queue(2)
  self.state = AIDefines.ActionState.Idle
end

function RequesterInterface:Request(param, caller, callback)
  return self:OnRequest(param, caller, callback)
end

function RequesterInterface:ActEnd(result)
  self.state = AIDefines.ActionState.Idle
  self:OnActEnd(result)
end

function RequesterInterface:DoAction(param)
  self.state = AIDefines.ActionState.Working
  self:Action(param)
end

function RequesterInterface:PushRequest(param, caller, callback)
  self._requests:Enqueue(param)
  self._delegates:Enqueue({caller = caller, callback = callback})
end

function RequesterInterface:PopRequest(result)
  if 0 == self._requests:Size() then
    return Log.Warning("[Requester] Popped an empty Request")
  end
  local param = self._requests:Dequeue()
  local delegate = self._delegates:Dequeue()
  if delegate.callback then
    delegate.callback(delegate.caller, result, self, param)
  elseif delegate.caller then
    Log.Warning("[Requester] Empty callback with request")
  end
end

function RequesterInterface:TryDoNextAction()
  local valid, requestParam = self:NextRequest()
  if valid then
    self:DoAction(requestParam)
  end
  return valid
end

function RequesterInterface:OnRequest(param, caller, callback)
  self:PushRequest(param, caller, callback)
  if self.state == AIDefines.ActionState.Working then
    self:Interrupt()
    self:ActEnd(AIDefines.ActionResult.Aborted)
  end
  self:TryDoNextAction()
  return true
end

function RequesterInterface:OnActEnd(result)
  self:PopRequest(result)
end

function RequesterInterface:NextRequest()
  if self._requests:Size() > 0 then
    return true, self._requests:First()
  end
  return false, nil
end

function RequesterInterface:Action(param)
  error("unimplemented")
  self:ActEnd(AIDefines.ActionResult.Failed)
end

function RequesterInterface:Interrupt()
  error("unimplemented")
end

return RequesterInterface
