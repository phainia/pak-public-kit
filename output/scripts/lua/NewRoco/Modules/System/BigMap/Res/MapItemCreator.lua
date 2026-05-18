local MapItemCreator = Class("MapItemCreator")
local Debug_Force_Immediately = RocoEnv.PLATFORM_WINDOWS and true or false
local ECreateMethod = {Immediately = 1, Deffered = 2}

function MapItemCreator:Ctor(countPerSecond)
  if nil == countPerSecond then
    countPerSecond = 0
  end
  self.createDataQueue = {}
  self.createClosureQueueMapping = {}
  self.creatorList = {}
  if countPerSecond <= 0 then
    self.createMethodType = ECreateMethod.Immediately
  else
    self.createMethodType = ECreateMethod.Deffered
    self.intervalTime = 1.0 / countPerSecond
    self._timer = nil
  end
end

function MapItemCreator:Create(itemCreator, tag, priorityFunction, createData)
  if self.creatorList[tag] == nil then
    self.creatorList[tag] = {}
  end
  self.creatorList[tag] = itemCreator
  if self.createMethodType == ECreateMethod.Immediately or Debug_Force_Immediately then
    return self:CreateImmediately(itemCreator, createData)
  else
    self:CreateDeffered(tag, priorityFunction, createData)
  end
end

function MapItemCreator:CreateImmediately(itemCreator, createData)
  if not itemCreator then
    Log.Error("Invalid itemCreator!")
    return
  end
  if createData and itemCreator.Create then
    itemCreator:Create(createData)
  end
end

function MapItemCreator:CreateDeffered(tag, priorityFunction, createData)
  table.insert(self.createDataQueue, createData)
  if tag then
    self.createClosureQueueMapping[createData] = tag
  end
  if not self._timer then
    local TimerUniqueName = "MapItemCreator_Timer_" .. tostring(self)
    self._timer = _G.TimerManager:CreateTimer(self, TimerUniqueName, math.maxinteger, self.OnTimer_CreateMapItem, nil, self.intervalTime)
  end
end

function MapItemCreator:OnTimer_CreateMapItem()
  for i = 1, _G.GlobalConfig.mapCreateItemNumPerFrame do
    if #self.createDataQueue > 0 then
      local index = #self.createDataQueue
      local createData = self.createDataQueue[index]
      self.createDataQueue[index] = nil
      local tag = self.createClosureQueueMapping[createData]
      if tag then
        self.createClosureQueueMapping[createData] = nil
      end
      if self.creatorList[tag] and createData then
        self.creatorList[tag]:Create(createData)
      end
    else
      DelayManager:DelayFrames(1, function()
        self:Interrupt()
      end)
      break
    end
  end
end

function MapItemCreator:Interrupt()
  if self._timer then
    _G.TimerManager:RemoveTimer(self._timer)
    self._timer = nil
  end
  table.clear(self.createDataQueue)
  table.clear(self.createClosureQueueMapping)
end

function MapItemCreator:DestroyAll()
  self:Interrupt()
end

return MapItemCreator
