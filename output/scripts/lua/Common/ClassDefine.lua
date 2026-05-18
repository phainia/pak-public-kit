local SingletonWithEventDispatcherHolder = {}

function SingletonWithEventDispatcherHolder:AddEventListener(listener, eventType, handler)
end

function SingletonWithEventDispatcherHolder:RemoveEventListener(listener, eventType, handler)
end

function SingletonWithEventDispatcherHolder:HasListener(listener, eventType, handler)
end

function SingletonWithEventDispatcherHolder:RemoveListeners(eventType)
end

function SingletonWithEventDispatcherHolder:RemoveAllListeners()
end

function SingletonWithEventDispatcherHolder:SendEvent(eventType, ...)
end
