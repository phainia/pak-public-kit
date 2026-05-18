local NRCEventCenter = Singleton:Extend("NRCEventCenter")
local EventDispatcher = require("Common.EventDispatcher")

function NRCEventCenter:Ctor()
  Singleton.Ctor(self, self.name)
  self.eventDispatcher = NRCClass()
  EventDispatcher():Attach(self.eventDispatcher)
  self.eventDict = {}
end

function NRCEventCenter:RegisterEvent(callerName, caller, eventName, handler)
  if not callerName then
    Log.Error("NRCEventCenter:RegisterEvent callerName is nil")
    return
  end
  if not eventName then
    Log.Error("NRCEventCenter:RegisterEvent eventName is nil:", eventName)
    return
  end
  if not self.eventDict[eventName] then
    self.eventDict[eventName] = {}
  end
  table.insert(self.eventDict[eventName], {
    name = callerName,
    callFrom = caller,
    callback = handler
  })
  self.eventDispatcher:AddEventListener(caller, eventName, handler)
end

function NRCEventCenter:UnRegisterEvent(caller, eventName, handler)
  if type(caller) == "string" then
    Log.Error("\230\179\168\230\132\143UnRegisterEvent\231\172\172\228\184\128\228\184\170\229\143\130\230\149\176\230\152\175caller\239\188\140UnRegisterEvent may fail")
  end
  if self.eventDict[eventName] then
    local isFind = false
    for i = #self.eventDict[eventName], 1, -1 do
      local regData = self.eventDict[eventName][i]
      local callFrom = regData.callFrom
      local callback = regData.callback
      if caller == callFrom and callback == handler then
        self.eventDispatcher:RemoveEventListener(callFrom, eventName, callback)
        table.remove(self.eventDict[eventName], i)
        isFind = true
        break
      end
    end
    if not isFind then
      Log.Debug("\230\178\161\230\156\137\230\137\190\229\136\176\229\133\168\229\177\128\230\179\168\229\134\140\228\186\139\228\187\182:", eventName)
    end
  end
end

function NRCEventCenter:DispatchEvent(eventName, ...)
  self.eventDispatcher:SendEvent(eventName, ...)
end

function NRCEventCenter:HasListener(name, caller, event, callback)
  if not name then
    return false
  end
  if not event then
    return false
  end
  if not caller then
    return false
  end
  if not callback then
    return false
  end
  local Dict = self.eventDict[event]
  if not Dict then
    return false
  end
  for i = 1, #Dict do
    local Item = Dict[i]
    if Item.callFrom == caller and Item.name == name and Item.callback == callback then
      return true
    end
  end
  return false
end

return NRCEventCenter
