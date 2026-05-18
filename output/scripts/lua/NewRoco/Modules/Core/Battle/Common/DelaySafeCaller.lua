local DelaySafeCaller = NRCClass("DelaySafeCaller")

function DelaySafeCaller:Ctor()
  self.delayIds = {}
  self.bDisposed = false
end

function DelaySafeCaller:Dctor()
  self:OnDispose()
end

function DelaySafeCaller:Dispose()
  if not self.bDisposed then
    self:_OnDispose()
    self.bDisposed = true
  end
end

function DelaySafeCaller:Reuse()
  self:Dispose()
  self.bDisposed = false
end

function DelaySafeCaller:Reset()
  self:Dispose()
end

function DelaySafeCaller:SafeCancelAllDelay()
  self:_DoCancelAllDelay()
end

function DelaySafeCaller:SafeDelaySeconds(idName, ...)
  self:_CheckDisposed()
  self:_CheckArgs(idName)
  local id = self.delayIds[idName]
  _G.DelayManager:CancelDelayByIdEx(id)
  self.delayIds[idName] = _G.DelayManager:DelaySeconds(...)
end

function DelaySafeCaller:SafeDelayFrames(idName, ...)
  self:_CheckDisposed()
  self:_CheckArgs(idName)
  local id = self.delayIds[idName]
  _G.DelayManager:CancelDelayByIdEx(id)
  self.delayIds[idName] = _G.DelayManager:DelayFrames(...)
end

function DelaySafeCaller:SafeCancelDelayById(idName)
  self:_CheckDisposed()
  self:_CheckArgs(idName)
  local id = self.delayIds[idName]
  if id then
    _G.DelayManager:CancelDelayById(id)
    self.delayIds[idName] = nil
  end
end

function DelaySafeCaller:SafeFindDelayById(idName)
  self:_CheckDisposed()
  self:_CheckArgs(idName)
  return self.delayIds[idName]
end

function DelaySafeCaller:_OnDispose()
  self:_DoCancelAllDelay()
end

function DelaySafeCaller:_DoCancelAllDelay()
  for name, id in pairs(self.delayIds) do
    _G.DelayManager:CancelDelayByIdEx(id)
  end
  table.clear(self.delayIds)
end

function DelaySafeCaller:_CheckArgs(idName)
  if RocoEnv.IS_EDITOR and type(idName) ~= "string" then
    error("DelaySafeCaller: idName must be string type!")
  end
end

function DelaySafeCaller:_CheckDisposed()
  if self.bDisposed and not RocoEnv.IS_SHIPPING then
    Log.Error("DelaySafeCaller has been disposed, cannot call delay functions!")
    local Ctx = DialogContext()
    Ctx:SetTitle("Error!!")
    Ctx:SetContent("DelaySafeCaller has been disposed, cannot call delay functions!")
    Ctx:SetMode(DialogContext.Mode.OK)
    Ctx:SetCallback(nil, function()
    end)
  end
end

return DelaySafeCaller
