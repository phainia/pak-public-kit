local NRCData = NRCClass:Extend("NRCData")

function NRCData:Ctor()
  NRCClass.Ctor(self)
  self.bindValueDict = {}
  self.eventDict = {}
end

function NRCData:SetInitData(module)
  self:Log("SetInitData:", module.moduleName)
  self.module = module
  self:SetEventDispatcher(module.eventDispatcher)
end

function NRCData:CacheConf(confName, conf, frame)
  self.module:CacheConf(confName, conf, frame)
end

function NRCData:ClearConf(confName)
  self.module:ClearConf(confName)
end

function NRCData:SetEventDispatcher(dispatcher)
  if not dispatcher then
    self.eventDispatcher = NRCClass()
    EventDispatcher():Attach(self.eventDispatcher)
  else
    self.eventDispatcher = dispatcher
  end
end

function NRCData:RegisterEvent(caller, eventName, handler)
  if not self.eventDispatcher then
    self:LogError("\229\173\144View\229\191\133\233\161\187\232\166\129\229\156\168\231\136\182\232\138\130\231\130\185OnConstruct\229\135\189\230\149\176\228\184\173\232\176\131\231\148\168SetChildViews\230\179\168\229\134\140\230\137\141\232\131\189\228\189\191\231\148\168\228\186\139\228\187\182\228\190\166\229\144\172\227\128\130")
    return
  end
  if not self.eventDict[caller] then
    self.eventDict[caller] = {}
  end
  if not self.eventDict[caller][eventName] then
    self.eventDict[caller][eventName] = {c = caller, h = handler}
    self.eventDispatcher:AddEventListener(caller, eventName, handler)
  end
end

function NRCData:UnRegisterEvent(caller, eventName)
  if not self.eventDict[caller] then
    self:LogError("UnRegisterEvent caller is not registered")
    return
  end
  if self.eventDict[caller][eventName] then
    self:Log("UnRegisterEvent:", eventName)
    local caller = self.eventDict[caller][eventName].c
    local handler = self.eventDict[caller][eventName].h
    self.eventDispatcher:RemoveEventListener(caller, eventName, handler)
    self.eventDict[caller][eventName] = nil
  end
end

function NRCData:DispatchEvent(eventName, ...)
  self.eventDispatcher:SendEvent(eventName, ...)
end

function NRCData:Bind(key, func)
  if not self.bindValueDict then
    self.bindValueDict = {}
  end
  self.bindValueDict[key] = SimpleDelegateFactory:CreateCallback(self, func)
end

function NRCData:SetValue(key, value)
  self[key] = value
  self:Broadcast(key, value)
end

function NRCData:Broadcast(key, value)
  if self.bindValueDict[key] then
    self.bindValueDict[key](self, value)
  end
end

function NRCData:Log(...)
  Log.Debug(string.format("[%s]", self.name), ...)
end

function NRCData:LogError(...)
  Log.Error(string.format("[%s]", self.name), ...)
end

return NRCData
