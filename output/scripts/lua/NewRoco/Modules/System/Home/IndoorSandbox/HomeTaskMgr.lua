local HomeTaskMgr = Class("HomeTaskMgr")
local TaskDir = "NewRoco/Modules/System/Home/IndoorSandbox/Task/"
HomeTaskMgr.TaskModules = {
  LoadMapTask = true,
  ProtoSendTask = true,
  FeedbackTask = true,
  LoadPropsTask = true,
  PreloadTask = true,
  AsyncTask = true,
  ResolveObstacleTask = true
}
for k, v in pairs(HomeTaskMgr.TaskModules) do
  HomeTaskMgr.TaskModules[k] = require(TaskDir .. k)
end

function HomeTaskMgr:Ctor(CostEverTick, bForceNoTick)
  self.Tasks = {}
  self.PendingRunTasks = {}
  self.RunningTasks = {}
  self.AsyncTasks = {}
  self.AsyncTaskIndex = 0
  self.TaskRunCostEverTick = CostEverTick or 10
  self.bForceNoTick = bForceNoTick
end

function HomeTaskMgr:New(...)
  return HomeTaskMgr(...)
end

function HomeTaskMgr:SetTickEnabled(bEnable)
  if self.bForceNoTick then
    return
  end
  if bEnable ~= self.bTickEnabled then
    self.bTickEnabled = bEnable
    if bEnable then
      UpdateManager:Register(self)
    else
      UpdateManager:UnRegister(self)
    end
  end
end

function HomeTaskMgr:EnQueTask(M, ...)
  if not HomeIndoorSandbox:Ensure(nil ~= M, "require task failed") then
    return
  end
  local Instance = M(...)
  Instance.Mgr = self
  local OnInit = Instance.OnInit
  if OnInit then
    OnInit(Instance)
  end
  self.Tasks[Instance] = true
  HomeIndoorSandbox:LogInfo("EnQueTask", Instance:ToString())
  table.insert(self.PendingRunTasks, Instance)
  self:SetTickEnabled(true)
  return Instance
end

function HomeTaskMgr:EnQueTaskWithFeedback(M, Feedback, ...)
  local Instance = self:EnQueTask(M, ...)
  Instance.OnFinishFeedback = Feedback
  return Instance
end

function HomeTaskMgr:CleanAllTasks()
  for task, _ in pairs(self.Tasks) do
    task.bRunning = false
    local OnClean = task.OnClean
    if OnClean then
      OnClean(task)
    end
  end
  self.Tasks = {}
  self.RunningTasks = {}
  self.PendingRunTasks = {}
  self.AsyncTasks = {}
  self.AsyncTaskIndex = 0
  self:SetTickEnabled(false)
end

function HomeTaskMgr:StepAsync()
  if #self.AsyncTasks > 0 then
    self.AsyncTaskIndex = self.AsyncTaskIndex + 1
    if self.AsyncTaskIndex > #self.AsyncTasks then
      self.AsyncTaskIndex = 1
    end
    local Task = self.AsyncTasks[self.AsyncTaskIndex]
    local Cost = self:InternalRunTask(Task, self.AsyncTaskIndex)
    if Task.bFinished then
      self.AsyncTaskIndex = self.AsyncTaskIndex - 1
    end
    return Cost
  end
  return 1
end

function HomeTaskMgr:Step()
  local Cost = 0
  local Num = #self.PendingRunTasks
  if Num > 0 then
    for i = 1, Num do
      local Task = self.PendingRunTasks[i]
      if Task.bAsync then
        table.insert(self.AsyncTasks, Task)
      else
        table.insert(self.RunningTasks, Task)
      end
    end
    self.PendingRunTasks = {}
    return Num
  elseif #self.RunningTasks > 0 then
    local Task = self.RunningTasks[1]
    Cost = self:InternalRunTask(Task, 1)
    if not Task.bRepeated and not Task.bFinished then
      return math.maxinteger
    end
  end
  return Cost
end

function HomeTaskMgr:InternalRunTask(Task, Index)
  local Cost = 1
  if not Task.bFinished then
    if not Task.bRunning then
      Task.bRunning = true
      local OnStart = Task.OnStart
      if OnStart then
        HomeIndoorSandbox:LogInfo("OnStart", Task:ToString())
        Cost = OnStart(Task, self)
      end
    else
      local OnUpdate = Task.OnUpdate
      if OnUpdate then
        Cost = OnUpdate(Task)
      end
    end
    Cost = Cost or 1
  end
  if Task.bFinished then
    if Task.bAsync then
      table.remove(self.AsyncTasks, Index)
    else
      table.remove(self.RunningTasks, Index)
    end
    self.Tasks[Task] = nil
    local OnFinish = Task.OnFinish
    if OnFinish then
      Cost = Cost + (OnFinish(Task) or 0)
    end
    local OnClean = Task.OnClean
    if OnClean then
      OnClean(Task)
    end
  end
  return math.max(1, Cost)
end

function HomeTaskMgr:GetDesiredRunTaskNum()
  return #self.RunningTasks + #self.AsyncTasks + #self.PendingRunTasks
end

function HomeTaskMgr:OnTick()
  local PendingRunNum = #self.PendingRunTasks
  local AsyncNum = #self.AsyncTasks
  if AsyncNum > 0 or PendingRunNum > 0 then
    local Cost = 0
    local i = 0
    while AsyncNum > i and Cost < self.TaskRunCostEverTick do
      i = i + 1
      local ThisCost = self:StepAsync()
      Cost = Cost + ThisCost
    end
  end
  local TaskNum = #self.RunningTasks + #self.PendingRunTasks
  if TaskNum > 0 or PendingRunNum > 0 then
    local Cost = 0
    local i = 0
    while TaskNum > i and Cost < self.TaskRunCostEverTick do
      i = i + 1
      local ThisCost = self:Step()
      if 0 == ThisCost then
        break
      end
      Cost = Cost + ThisCost
    end
  end
  if 0 == self:GetDesiredRunTaskNum() then
    self:SetTickEnabled(false)
  end
end

return HomeTaskMgr
