local Class = _G.MakeSimpleClass
local EventDispatcher = Class("EventDispatcher")
EventDispatcher:SetMemberCount(8)

function EventDispatcher:Ctor(EventTypeCount, ListenerCount, Lazy)
  self.EventTypeCount = EventTypeCount or 8
  self.ListenerCount = ListenerCount or 8
  if Lazy then
    self._handlersDic = false
    self._tempAddDic = false
    self._tempRemoveDic = false
    self._isSending = false
  else
    self:CreateEventMaps()
  end
end

local EventDispatcherHolder = {}

function EventDispatcherHolder:AddEventListener(listener, eventType, handler)
  if self._eventDispatcher then
    self._eventDispatcher:AddEventListener(listener, eventType, handler)
  end
end

function EventDispatcherHolder:EnsureEventListener(listener, eventType, handler)
  if not self._eventDispatcher then
    return
  end
  if not self._eventDispatcher:HasListener(listener, eventType, handler) then
    self._eventDispatcher:AddEventListener(listener, eventType, handler)
  end
end

function EventDispatcherHolder:RemoveEventListener(listener, eventType, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, eventType, handler)
  end
end

function EventDispatcherHolder:HasListener(listener, eventType, handler)
  if self._eventDispatcher then
    return self._eventDispatcher:HasListener(listener, eventType, handler)
  end
  return false
end

function EventDispatcherHolder:RemoveListeners(eventType)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveListeners(eventType)
  end
end

function EventDispatcherHolder:RemoveAllListeners()
  if self._eventDispatcher then
    self._eventDispatcher:RemoveAllListeners()
  end
end

function EventDispatcherHolder:SendEvent(eventType, ...)
  if self._eventDispatcher then
    self._eventDispatcher:SendEvent(eventType, ...)
  end
end

function EventDispatcher:Attach(owner)
  owner._eventDispatcher = self
  if owner.AddEventListener then
    return
  end
  for k, v in pairs(EventDispatcherHolder) do
    rawset(owner, k, v)
  end
end

function EventDispatcher:_CheckReAdd(listener, eventType, handler)
  if _G.RocoEnv.IS_EDITOR then
    if not self._tempAddDic then
      return false
    end
    local handlerList = self._tempAddDic[eventType]
    if handlerList then
      for _, item in ipairs(handlerList) do
        if item and item.handler == handler and item.listener == listener then
          Log.ErrorFormat("\233\135\141\229\164\141\230\179\168\229\134\140\228\186\139\228\187\182\231\155\145\229\144\172,\232\175\183\229\138\161\229\191\133\229\164\132\231\144\134\228\184\128\228\184\139!\228\184\141\231\132\182\229\140\133\228\189\147\233\135\140\233\157\162\228\189\160\231\154\132\229\155\158\232\176\131\229\143\175\232\131\189\228\188\154\232\162\171\230\137\167\232\161\140\233\157\158\229\184\184\229\164\154\233\129\141!!!  [%s   %s   %s]", eventType, listener.name, tostring(handler))
          return true
        end
      end
    end
    local oriHandlerList = self._handlersDic[eventType]
    if oriHandlerList then
      for _, item in ipairs(oriHandlerList) do
        if item and item.handler == handler and item.listener == listener then
          Log.ErrorFormat("\233\135\141\229\164\141\230\179\168\229\134\140\228\186\139\228\187\182\231\155\145\229\144\172,\232\175\183\229\138\161\229\191\133\229\164\132\231\144\134\228\184\128\228\184\139!\228\184\141\231\132\182\229\140\133\228\189\147\233\135\140\233\157\162\228\189\160\231\154\132\229\155\158\232\176\131\229\143\175\232\131\189\228\188\154\232\162\171\230\137\167\232\161\140\233\157\158\229\184\184\229\164\154\233\129\141!!!  [%s   %s   %s]", eventType, listener.name, tostring(handler))
          return true
        end
      end
    end
  end
  return false
end

function EventDispatcher:_CheckReRemove(listener, eventType, handler)
  if _G.RocoEnv.IS_EDITOR then
    if not self._tempRemoveDic then
      return false
    end
    local tempRemoveList = self._tempRemoveDic[eventType]
    if tempRemoveList then
      for _, item in ipairs(tempRemoveList) do
        if item and item.handler == handler and item.listener == listener then
          Log.Warning("\233\135\141\229\164\141\231\167\187\233\153\164:", eventType, tostring(listener), tostring(handler))
          return true
        end
      end
    end
  end
  return false
end

function EventDispatcher:AddEventListener(listener, eventType, handler)
  if nil == handler then
    Log.Error("handler can't be nil", eventType)
    return
  end
  if nil == eventType then
    Log.Error("eventType cant be nil")
    return
  end
  if not RocoEnv.IS_SHIPPING and type(handler) ~= "function" and type(handler) ~= "table" then
    Log.Error("A unregistered handler must be callable")
  end
  if not self._tempAddDic or not self._tempRemoveDic then
    self:CreateEventMaps()
  end
  local tempRemoveList = self._tempRemoveDic[eventType]
  local items = tempRemoveList
  if items then
    for i, item in ipairs(items) do
      if item and item.handler == handler and item.listener == listener then
        table.remove(tempRemoveList, i)
        return
      end
    end
  end
  if self:_CheckReAdd(listener, eventType, handler) then
    return
  end
  if self._isSending[eventType] == true then
    if nil == self._tempAddDic[eventType] then
      self._tempAddDic[eventType] = table.new(math.ceil(self.ListenerCount / 2))
    end
    local handlerList = self._tempAddDic[eventType]
    local event = {listener = listener, handler = handler}
    table.insert(handlerList, event)
  else
    if nil == self._handlersDic[eventType] then
      self._handlersDic[eventType] = table.new(self.ListenerCount, 0)
    end
    local event = {listener = listener, handler = handler}
    table.insert(self._handlersDic[eventType], event)
  end
end

function EventDispatcher:RemoveEventListener(listener, eventType, handler)
  if nil == handler then
    Log.Error("handler can't be nil", eventType)
    return
  end
  if nil == eventType then
    Log.Error("eventType cant be nil")
    return
  end
  if not RocoEnv.IS_SHIPPING and type(handler) ~= "function" and type(handler) ~= "table" then
    Log.Error("A unregistered handler must be callable")
  end
  if not self._tempAddDic or not self._tempRemoveDic then
    self:CreateEventMaps()
  end
  local tempHandlerList = self._tempAddDic[eventType]
  if tempHandlerList then
    for i, item in ipairs(tempHandlerList) do
      if item and item.handler == handler and item.listener == listener then
        table.remove(tempHandlerList, i)
        return
      end
    end
  end
  if self:_CheckReRemove(listener, eventType, handler) then
    return
  end
  local TempHandler = self._handlersDic[eventType]
  if not TempHandler then
    return
  end
  local Found = false
  for index, item in ipairs(TempHandler) do
    if item and item.handler == handler and item.listener == listener then
      if self._isSending[eventType] == true then
        if nil == self._tempRemoveDic[eventType] then
          self._tempRemoveDic[eventType] = table.new(math.ceil(self.ListenerCount / 2))
        end
        local tempRemoveList = self._tempRemoveDic[eventType]
        local event = {listener = listener, handler = handler}
        table.insert(tempRemoveList, event)
      else
        table.remove(TempHandler, index)
      end
      Found = true
      break
    end
  end
  if not Found then
    return
  end
end

function EventDispatcher:HasListener(listener, eventType, handler)
  if not self._handlersDic or not self._tempAddDic then
    return false
  end
  local handlerList = self._handlersDic[eventType]
  if handlerList then
    for _, v in ipairs(handlerList) do
      if v.handler == handler and v.listener == listener then
        return true
      end
    end
  end
  local tempHandlerList = self._tempAddDic[eventType]
  if tempHandlerList then
    for _, v in ipairs(tempHandlerList) do
      if v.handler == handler and v.listener == listener then
        return true
      end
    end
  end
  return false
end

function EventDispatcher:RemoveListeners(eventType)
  if not self._handlersDic then
    return
  end
  self._handlersDic[eventType] = nil
end

function EventDispatcher:RemoveAllListeners()
  self:CreateEventMaps()
end

function EventDispatcher:CreateEventMaps()
  local Half = math.ceil(self.EventTypeCount / 2)
  self._handlersDic = table.new(0, self.EventTypeCount)
  self._tempRemoveDic = table.new(0, Half)
  self._tempAddDic = table.new(0, Half)
  self._isSending = table.new(0, self.EventTypeCount)
end

function EventDispatcher:_DoAddRemoveListeners()
  if not self._tempAddDic or not self._tempRemoveDic then
    return
  end
  for eventType, addHandlerList in pairs(self._tempAddDic) do
    if addHandlerList then
      Log.Debug("EventDispatcher DoAdd", eventType)
      if self._handlersDic[eventType] == nil then
        self._handlersDic[eventType] = {}
      end
      for _, item in ipairs(addHandlerList) do
        table.insert(self._handlersDic[eventType], item)
      end
    end
  end
  for eventType, items in pairs(self._tempRemoveDic) do
    for _, item in ipairs(items) do
      local handlerList = self._handlersDic[eventType]
      if handlerList then
        for j = #handlerList, 1, -1 do
          local v = handlerList[j]
          if v.handler == item.handler and v.listener == item.listener then
            Log.Debug("EventDispatcher DoRemove", eventType)
            table.remove(handlerList, j)
          end
        end
      end
    end
  end
  table.clear(self._tempAddDic)
  table.clear(self._tempRemoveDic)
end

function EventDispatcher:SendEvent(eventType, ...)
  if not self._isSending then
    return false
  end
  if table.len(self._isSending) > 0 then
    if self._tempAddDic[eventType] or self._tempRemoveDic[eventType] then
      Log.Error("\229\176\189\233\135\143\228\184\141\232\166\129\232\191\153\228\185\136\229\129\154: \229\156\168\229\143\145\233\128\129\228\186\139\228\187\182\231\154\132\229\155\158\232\176\131\229\135\189\230\149\176\229\162\158\229\136\160\230\136\150\232\128\133\229\136\160\233\153\164\228\186\139\228\187\182\229\155\158\232\176\131\239\188\140\231\132\182\229\144\142\231\187\167\231\187\173\229\143\145\233\128\129 ", eventType)
    end
  else
    self:_DoAddRemoveListeners()
  end
  if self._handlersDic[eventType] == nil then
    return
  end
  self._isSending[eventType] = true
  local handleList = self._handlersDic[eventType]
  for index, v in ipairs(handleList) do
    if v and v.handler then
      tcall(v.listener, v.handler, ...)
    end
  end
  self._isSending[eventType] = nil
end

function EventDispatcher.DumpEvent(Dispatcher, EventName, ExtraMessage)
  Log.Error("Dump Event Dispatcher Event", EventName, ExtraMessage)
  if Dispatcher._eventDispatcher then
    Dispatcher = Dispatcher._eventDispatcher
  end
  if not Dispatcher._handlersDic then
    Log.Debug("EventDispatcher not used yet")
    return
  end
  local Handler = Dispatcher._handlersDic[EventName]
  local Add = Dispatcher._tempAddDic[EventName]
  local Remove = Dispatcher._tempRemoveDic[EventName]
  if not Handler or 0 == #Handler then
    Log.Debug("Handler size is zero")
  else
    for i, v in ipairs(Handler) do
      Log.Dump(v.listener, 1, "Show handler dict")
    end
  end
  if not Add or 0 == #Add then
    Log.Debug("Add size is zero")
  else
    for i, v in ipairs(Add) do
      Log.Dump(v.listener, 1, "Show Add dict")
    end
  end
  if not Remove or 0 == #Remove then
    Log.Debug("Remove size is zero")
  else
    for i, v in ipairs(Remove) do
      Log.Dump(v.listener, 1, "Show Remove dict")
    end
  end
end

function EventDispatcher.BindClass(Klass)
  Klass.AddEventListener = EventDispatcherHolder.AddEventListener
  Klass.RemoveEventListener = EventDispatcherHolder.RemoveEventListener
  Klass.EnsureEventListener = EventDispatcherHolder.EnsureEventListener
  Klass.HasListener = EventDispatcherHolder.HasListener
  Klass.RemoveListeners = EventDispatcherHolder.RemoveListeners
  Klass.RemoveAllListeners = EventDispatcherHolder.RemoveAllListeners
  Klass.SendEvent = EventDispatcherHolder.SendEvent
end

function EventDispatcher.Detach(owner)
  if owner and owner._eventDispatcher then
    owner._eventDispatcher = nil
  end
end

return EventDispatcher
