local Base = require("NewRoco.Modules.Core.Fsm.FsmState")
local FsmTimelineState = Base:Extend("FsmTimelineState")
FsmTimelineState:SetMemberCount(3)

function FsmTimelineState:Ctor(name, properties, actions, transitions, totalTime)
  self.TempArray = {}
  local Count = actions and #actions or 0
  if Count > 0 then
    for i = Count, 1, -1 do
      local action = actions[i]
      local StartTime = action:GetStartTime()
      local EndTime = action:GetEndTime()
      action.__timelineIndex = i
      action.__timelineOperation = 0
      action.__timelineTimestamp = -1
      if StartTime < 0 or EndTime < 0 or StartTime > EndTime then
        Log.Warning("action start time greater than end time!")
        Log.Dump(action, 2, "This action will be trimmed")
        table.remove(actions, i)
      end
    end
  end
  Base.Ctor(self, name, properties, actions, transitions)
  self.execTime = 0
  self.totalTime = totalTime or 3.0
end

function FsmTimelineState:SetTotalTime(time)
  self.totalTime = time or 1.48
  return self
end

function FsmTimelineState:OnEnter(fsm)
  if self.entered then
    return
  end
  self.execTime = 0
  Base.OnEnter(self, fsm)
end

function FsmTimelineState:TryAddActiveActions(startIndex, stopIndex)
  if not self.entered or not self.finished then
    return false
  end
  if stopIndex < startIndex then
    return false
  end
  local actionAdded = false
  for i = startIndex, stopIndex do
    self.index = i
    local action = self.actions[i]
    if action and not action.entered and not action.finished and action:GetStartTime() <= self.execTime and action:GetEndTime() > self.execTime then
      table.insert(self.activeActions, action)
      action.index = i
      action:DoEnter()
      action:DoTick(math.min(action:GetEndTime(), self.execTime) - action:GetStartTime())
      actionAdded = true
    end
  end
  return actionAdded
end

local function SortTimelineAction(a, b)
  local EventTimeA = a.__timelineTimestamp
  local EventTimeB = b.__timelineTimestamp
  if EventTimeA ~= EventTimeB then
    return EventTimeA < EventTimeB
  end
  return a.__timelineIndex < b.__timelineIndex
end

function FsmTimelineState:OnTick(DeltaTime)
  if self:IsWaitPreload() then
    return
  end
  if not self.active or self.finished then
    return
  end
  local tickStart = self.execTime
  local tickEnd = math.min(tickStart + DeltaTime, self.totalTime)
  self.execTime = tickEnd
  table.clear(self.TempArray)
  do
    local Count = #self.activeActions
    for i = Count, 1, -1 do
      local action = self.activeActions[i]
      if tickEnd >= action:GetEndTime() then
        action.__timelineOperation = 1
        action.__timelineTimestamp = tickStart
        table.insert(self.TempArray, action)
        table.remove(self.activeActions, i)
      else
        action.__timelineOperation = 3
        action.__timelineTimestamp = tickStart
        table.insert(self.TempArray, action)
      end
    end
  end
  do
    local Count = #self.actions
    for i = 1, Count do
      local action = self.actions[i]
      if not action.entered and not action.finished and tickEnd >= action:GetStartTime() then
        if tickEnd <= action:GetEndTime() then
          action.__timelineOperation = 2
          action.__timelineTimestamp = action:GetStartTime()
          table.insert(self.TempArray, action)
          table.insert(self.activeActions, action)
        else
          action.__timelineOperation = 4
          action.__timelineTimestamp = action:GetStartTime()
          table.insert(self.TempArray, action)
        end
      end
    end
  end
  table.sort(self.TempArray, SortTimelineAction)
  do
    local Count = #self.TempArray
    for i = 1, Count do
      local action = self.TempArray[i]
      local Operation = action.__timelineOperation
      action.__timelineOperation = 0
      action.__timelineTimestamp = -1
      local actionStart = action:GetStartTime()
      local actionEnd = action:GetEndTime()
      local tickDelta = math.min(tickEnd, actionEnd) - math.max(tickStart, actionStart)
      if 1 == Operation then
        action:DoTick(tickDelta)
        action:Finish()
      elseif 2 == Operation then
        action.index = action.__timelineIndex
        action:DoEnter()
        action:DoTick(tickDelta)
      elseif 3 == Operation then
        action:DoTick(tickDelta)
      elseif 4 == Operation and not action.ShouldSkipExecuteInOneTick then
        action:DoEnter()
        action:DoTick(tickDelta)
        action:Finish()
      end
    end
    table.clear(self.TempArray)
  end
  self:CheckAllActionsFinished()
end

function FsmTimelineState:CheckAllActionsFinished()
  if self.execTime < self.totalTime then
    return
  end
  self:Finish()
end

function FsmTimelineState:GetPercent()
  if 0 == self.totalTime then
    return 1
  end
  return math.clamp(self.execTime / self.totalTime, 0, 1)
end

function FsmTimelineState:AddAction(action)
  action.__timelineIndex = #self.actions + 1
  action.__timelineOperation = 0
  action.__timelineTimestamp = -1
  Base.AddAction(self, action)
end

return FsmTimelineState
