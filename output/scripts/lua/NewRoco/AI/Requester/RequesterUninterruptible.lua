local Base = require("NewRoco.AI.Requester.RequesterInterface")
local RequesterUninterruptible = Base:Extend("RequesterUninterruptible")

function RequesterUninterruptible:OnRequest(param, caller, callback)
  if self.state == AIDefines.ActionState.Idle then
    self:PushRequest(param, caller, callback)
    self:TryDoNextAction()
    return true
  else
    while self._requests:Size() > 1 do
      local result = AIDefines.ActionResult.Rejected
      local _param
      self._requests:RemoveLast()
      local _delegate = self._delegates:RemoveLast()
      if _delegate.callback then
        _delegate.callback(_delegate.caller, result, self, _param)
      end
    end
    self:PushRequest(param, caller, callback)
    return false
  end
end

function RequesterUninterruptible:OnActEnd(result)
  if result == AIDefines.ActionResult.Success and self._requests:Size() > 1 then
    self:PopRequest(AIDefines.ActionResult.Continue)
  else
    self:PopRequest(result)
  end
  self:TryDoNextAction()
end

function RequesterUninterruptible:NextRequest()
  while self._requests:Size() > 2 do
    self:PopRequest(AIDefines.ActionResult.Rejected)
  end
  return Base.NextRequest(self)
end

return RequesterUninterruptible
