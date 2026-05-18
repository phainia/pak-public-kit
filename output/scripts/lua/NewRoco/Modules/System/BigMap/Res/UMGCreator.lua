local UMGCreator = Class("UMGCreator")
local PriorityQueue = require("Utils.PriorityQueue")
local Debug_Force_Immediately = false
local ECreateMethod = {Immediately = 1, Deffered = 2}

function UMGCreator:Ctor(countPerSecond)
  self.createClosureQueue = {}
  self.createClosureQueueMapping = {}
  if countPerSecond <= 0 then
    self.createMethodType = ECreateMethod.Immediately
  else
    self.createMethodType = ECreateMethod.Deffered
    self.intervalTime = 1.0 / countPerSecond
    self._timer = nil
  end
  self.d_Interrupt = nil
end

function UMGCreator:Dctor()
  self:Interrupt()
  self.d_Interrupt = _G.DelayManager:CancelDelayByIdEx(self.d_Interrupt)
end

function UMGCreator:Create(createClosure, tag, priorityFunction, initClosure)
  if self.createMethodType == ECreateMethod.Immediately or Debug_Force_Immediately then
    return self:_CreateImmediately(createClosure, initClosure)
  else
    self:_CreateDeffered(createClosure, tag, priorityFunction, initClosure)
  end
end

function UMGCreator:Interrupt()
  self.d_Interrupt = nil
  if self._timer then
    _G.TimerManager:RemoveTimer(self._timer)
    self._timer = nil
  end
  table.clear(self.createClosureQueue)
  table.clear(self.createClosureQueueMapping)
end

function UMGCreator:FindCreateClosures(tagToQuery)
  return self.createClosureQueueMapping[tagToQuery]
end

function UMGCreator:TryChangeInitClosure(tagToQuery, newInitClosure)
  local existClosures = self.createClosureQueueMapping[tagToQuery]
  if existClosures then
    existClosures.initClosure = newInitClosure
    return true
  end
  return false
end

function UMGCreator:IsEmpty()
  return 0 == #self.createClosureQueue
end

function UMGCreator:_CreateImmediately(createClosure, initClosure)
  if not createClosure then
    Log.Error("Invalid createClosure!")
    return
  end
  local _ret = createClosure()
  if initClosure then
    InInitClosure()
  end
  return _ret
end

function UMGCreator:_CreateDeffered(createClosure, tag, priorityFunction, initClosure)
  local closures = {creator = createClosure, initializer = initClosure}
  table.insert(self.createClosureQueue, closures)
  if tag then
    self.createClosureQueueMapping[tag] = closures
    self.createClosureQueueMapping[closures] = tag
  end
  if not self.Timer then
    local TimerUniqueName = "UMGCreator_Timer_" .. tostring(self)
    self._timer = _G.TimerManager:CreateTimer(self, TimerUniqueName, math.maxinteger, self._OnTimer_CreateUMG, nil, self.intervalTime)
  end
end

function UMGCreator:_OnTimer_CreateUMG()
  if #self.createClosureQueue > 0 then
    local index = #self.createClosureQueue
    local closures = self.createClosureQueue[index]
    self.createClosureQueue[index] = nil
    local tag = self.createClosureQueueMapping[closures]
    if tag then
      self.createClosureQueueMapping[closures] = nil
      self.createClosureQueueMapping[tag] = nil
    end
    closures.creator()
    if closures.initializer then
      closures.initializer()
    end
  else
    self.d_Interrupt = DelayManager:DelayFramesEx(self.d_Interrupt, 1, function()
      self:Interrupt()
    end)
  end
end

return UMGCreator
