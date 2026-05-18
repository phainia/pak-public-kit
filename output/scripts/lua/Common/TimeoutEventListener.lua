local TypeEnum = {
  None = 0,
  Global = 1,
  Dispatcher = 2
}
local TimeoutEventListener = Class("TimeoutEventListener")

function TimeoutEventListener:Ctor()
  self.Handler = -1
  self.Type = TypeEnum.None
  self.StartTime = -1
end

function TimeoutEventListener:StartGlobalEventListener(Timeout, CallerName, Caller, EventName, Callback)
  if self.Caller or self.Callback then
    Log.Error("\229\183\178\231\187\143\230\179\168\229\134\140\232\191\135\228\186\134\239\188\129")
    return
  end
  if string.IsNilOrEmpty(EventName) then
    Log.Error("\228\186\139\228\187\182\228\184\186\231\169\186")
    return
  end
  if Timeout <= 0 then
    Log.Error("\232\182\133\230\151\182\228\184\141\232\131\189\229\176\143\228\186\1420")
    return
  end
  self.Type = TypeEnum.Global
  self:ClearHandler()
  self.Handler = _G.DelayManager:DelaySeconds(Timeout, self.TimesUp, self)
  self.Caller = Caller
  self.Callback = Callback
  self.EventName = EventName
  self.Dispatcher = nil
  self.Timeout = Timeout
  self.StartTime = _G.UpdateManager.Timestamp
  _G.NRCEventCenter:RegisterEvent(CallerName, self, EventName, self.EventCallback)
  Log.Debug("TimeoutEventListener start wait for global event", EventName, self.StartTime, self.Timeout)
end

function TimeoutEventListener:StartDispatcherListener(Timeout, Dispatcher, Caller, EventName, Callback)
  if self.Caller or self.Callback then
    Log.Error("\229\183\178\231\187\143\230\179\168\229\134\140\232\191\135\228\186\134\239\188\129")
    return
  end
  if not Dispatcher then
    Log.Error("\228\186\139\228\187\182\230\180\190\229\143\145\229\153\168\228\184\186\231\169\186")
    return
  end
  if string.IsNilOrEmpty(EventName) then
    Log.Error("\228\186\139\228\187\182\228\184\186\231\169\186")
    return
  end
  if Timeout <= 0 then
    Log.Error("\232\182\133\230\151\182\228\184\141\232\131\189\229\176\143\228\186\1420")
    return
  end
  self.Type = TypeEnum.Dispatcher
  self:ClearHandler()
  self.Handler = _G.DelayManager:DelaySeconds(Timeout, self.TimesUp, self)
  self.Caller = Caller
  self.Callback = Callback
  self.EventName = EventName
  self.Dispatcher = Dispatcher
  self.Timeout = Timeout
  self.StartTime = _G.UpdateManager.Timestamp
  Dispatcher:AddEventListener(self, EventName, self.EventCallback)
  Log.Debug("TimeoutEventListener start wait for event", EventName, self.StartTime, self.Timeout)
end

function TimeoutEventListener:EventCallback(...)
  local Delta = _G.UpdateManager.Timestamp - self.StartTime
  Log.Debug("TimeoutEventListener:EventCallback", self.EventName, Delta)
  self:ClearHandler()
  self:Cleanup()
  self:FireCallback(false, ...)
end

function TimeoutEventListener:TimesUp()
  Log.Debug("\229\143\145\233\128\129\228\186\139\228\187\182\232\182\133\230\151\182\229\149\166...", self.EventName, self.Timeout, self.StartTime)
  self:Cleanup()
  self:FireCallback(true)
end

function TimeoutEventListener:Cleanup()
  if self.Type == TypeEnum.Global then
    _G.NRCEventCenter:UnRegisterEvent(self, self.EventName, self.EventCallback)
  elseif self.Type == TypeEnum.Dispatcher then
    self.Dispatcher:RemoveEventListener(self, self.EventName, self.EventCallback)
  end
  self.Type = nil
  self.EventName = nil
  self.Dispatcher = nil
  self.Timeout = 0
  self.StartTime = -1
end

function TimeoutEventListener:Stop()
  self.Caller = nil
  self.Callback = nil
  self:Cleanup()
end

function TimeoutEventListener:ClearHandler()
  if self.Handler <= 0 then
    return
  end
  _G.DelayManager:CancelDelayById(self.Handler)
end

function TimeoutEventListener:FireCallback(...)
  local Caller = self.Caller
  local Callback = self.Callback
  self.Caller = nil
  self.Callback = nil
  if not Callback then
    return
  end
  if Caller then
    Callback(Caller, ...)
  else
    Callback(...)
  end
end

return TimeoutEventListener
