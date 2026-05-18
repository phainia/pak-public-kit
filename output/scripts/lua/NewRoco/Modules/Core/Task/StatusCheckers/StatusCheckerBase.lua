local Class = _G.MakeSimpleClass
local EventCenter = _G.NRCEventCenter
local StatusCheckerBase = Class("StatusCheckerBase")

function StatusCheckerBase:Ctor()
  self.LogLevel = Log.LOG_LEVEL.ELogDebug
  self.LastCheckResult = false
  self.LogPrefix = "Unknown"
end

function StatusCheckerBase:Check(Caller, Callback, ...)
  self.LastCheckResult = self:CheckPass()
  if self.LastCheckResult then
    if Callback then
      if Caller then
        Callback(Caller, ...)
      else
        Callback(...)
      end
    end
    return true
  else
    self:StoreCallback(Caller, Callback, {
      ...
    })
    self:StartCheck()
    return false
  end
end

function StatusCheckerBase:CheckPass()
  return true
end

function StatusCheckerBase:StartCheck()
end

function StatusCheckerBase:EndCheck()
end

function StatusCheckerBase:StoreCallback(Caller, Callback, Args)
  self.Caller = Caller
  self.Callback = Callback
  self.Args = Args
end

function StatusCheckerBase:ClearCallback()
  self.Caller = nil
  self.Callback = nil
  self.Args = nil
end

function StatusCheckerBase:FireCallback()
  local Caller = self.Caller
  local Callback = self.Callback
  local Args = self.Args
  self:Reset()
  self.LastCheckResult = true
  if Callback then
    if Caller then
      Callback(Caller, table.unpack(Args))
    else
      Callback(table.unpack(Args))
    end
  end
end

function StatusCheckerBase:Reset()
  self:EndCheck()
  self:ClearCallback()
end

function StatusCheckerBase:Log(...)
  Log.LogWithLevel(self.LogLevel, 3, self.LogPrefix, ...)
end

function StatusCheckerBase:RegisterGlobalEvent(EventName, Callback)
  if not EventCenter:HasListener(self.name, self, EventName, Callback) then
    EventCenter:RegisterEvent(self.name, self, EventName, Callback)
  end
end

function StatusCheckerBase:UnregisterGlobalEvent(EventName, Callback)
  if EventCenter:HasListener(self.name, self, EventName, Callback) then
    EventCenter:UnRegisterEvent(self, EventName, Callback)
  end
end

return StatusCheckerBase
