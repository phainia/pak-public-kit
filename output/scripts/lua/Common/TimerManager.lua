local Class = _G.MakeSimpleClass
local Timer = Class("Timer")

function Timer:Ctor()
  self.Caller = nil
  self.TimerName = nil
  self.interval = 0
  self.duration = 0
  self.OnUpdate = nil
  self.OnComplete = nil
  self.leftTime = 0
  self.isComplete = false
  self.elapsedTime = 0
  self.mgr = nil
end

function Timer:SetManager(mgr)
  self.mgr = mgr
end

function Timer:SetCaller(caller)
  self.Caller = caller
end

function Timer:SetName(timerName)
  self.TimerName = timerName
end

function Timer:SetInterval(interval)
  self.interval = interval
end

function Timer:SetDuration(duration)
  self.duration = duration
  self.leftTime = duration
end

function Timer:SetOnUpdate(updateFunc)
  self.OnUpdate = updateFunc
end

function Timer:SetOnComplete(completeFunc)
  self.OnComplete = completeFunc
end

function Timer:Restart()
  self.isComplete = false
  self.elapsedTime = 0
  self.leftTime = self.duration
end

function Timer:Clear()
  self.Caller = nil
  self.TimerName = nil
  self.interval = 0
  self.duration = 0
  self.OnUpdate = nil
  self.OnComplete = nil
  self.leftTime = 0
  self.isComplete = false
  self.elapsedTime = 0
  self.mgr = nil
end

function Timer:OnTick(deltaTime)
  if self.isComplete then
    return
  end
  self.elapsedTime = self.elapsedTime + deltaTime
  if self.elapsedTime >= self.interval then
    if self.OnUpdate ~= nil then
      tcall(self.Caller, self.OnUpdate)
    end
    self.elapsedTime = 0
  end
  self.leftTime = self.leftTime - deltaTime
  if self.leftTime <= 0 then
    self.isComplete = true
    if nil ~= self.OnComplete then
      tcall(self.Caller, self.OnComplete)
    end
  end
end

function Timer:Stop()
  self.isComplete = true
end

local TimerManager = Singleton:Extend("TimerManager")

function TimerManager:Ctor(name)
  self.name = name or "TimerManager"
  Singleton.Ctor(self, self.name)
  self.timerDict = {}
  self.timerKeyDict = {}
  self.timerLst = {}
  self:EnableTick(true)
end

function TimerManager:Free()
  Singleton.Free(self)
  if _G.UpdateManager ~= nil then
    _G.UpdateManager:UnRegister(self)
  end
end

function TimerManager:CreateTimer(caller, key, duration, onTimerUpdate, onTimerComplete, interval)
  local timer = Timer()
  timer:SetCaller(caller)
  timer:SetName(key)
  timer:SetInterval(interval)
  timer:SetOnUpdate(onTimerUpdate)
  timer:SetDuration(duration)
  timer:SetOnComplete(onTimerComplete)
  timer:SetManager(self)
  self.timerDict[key] = timer
  self.timerKeyDict[timer] = key
  table.insert(self.timerLst, key)
  return timer
end

function TimerManager:RemoveTimer(timer)
  if nil ~= timer then
    for i = #self.timerLst, 1, -1 do
      local key = self.timerKeyDict[timer]
      if self.timerLst[i] == key then
        timer:Clear()
        table.remove(self.timerLst, i)
        self.timerDict[key] = nil
        self.timerKeyDict[timer] = nil
      end
    end
  end
end

function TimerManager:ClearAllTimer()
  self.timerKeyDict = {}
  self.timerDict = {}
  self.timerLst = {}
end

function TimerManager:StopAllTimer()
  for i = #self.timerLst, 1, -1 do
    local timer = self.timerDict[self.timerLst[i]]
    if timer then
      timer.isComplete = true
    end
  end
end

function TimerManager:GetTimer(idx)
end

function TimerManager:OnTick(deltaTime)
  for i = #self.timerLst, 1, -1 do
    local key = self.timerLst[i]
    local timer = self.timerDict[key]
    if timer and not timer.isComplete then
      timer:OnTick(deltaTime)
    end
  end
end

return TimerManager
