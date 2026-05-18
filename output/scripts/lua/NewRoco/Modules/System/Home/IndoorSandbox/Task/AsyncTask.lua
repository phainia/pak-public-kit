local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local AsyncTask = Super:Extend("AsyncTask")

function AsyncTask:Ctor(AsyncTaskModuleList, Callback)
  Super.Ctor(self)
  self.AsyncTaskModuleList = AsyncTaskModuleList
  self.Callback = Callback
  self.TaskMap = {}
  self.FinishFlag = {}
end

function AsyncTask:OnClean()
  if self.AsyncTaskMgr then
    self.AsyncTaskMgr:CleanAllTasks()
    self.AsyncTaskMgr = nil
  end
end

function AsyncTask:OnFinishSubTask(i)
  self.FinishFlag[i] = nil
end

function AsyncTask:OnStart()
  self.AsyncTaskMgr = self.Mgr:New()
  for i = 1, #self.AsyncTaskModuleList do
    local Task = self.AsyncTaskModuleList[i]
    self.FinishFlag[i] = false
    self.TaskMap[i] = self.AsyncTaskMgr:EnQueTask(Task[1], Task[2], Task[3], Task[4], Task[5])
    self.TaskMap[i].OnFinishFeedback = FPartial(self.OnFinishSubTask, self, i)
  end
  self:CheckFinish()
end

function AsyncTask:OnUpdate()
  self:CheckFinish()
end

function AsyncTask:CheckFinish()
  if not next(self.FinishFlag) then
    self:NotifyFinish()
    if self.Callback then
      self.Callback(self.TaskMap)
    end
  end
end

return AsyncTask
