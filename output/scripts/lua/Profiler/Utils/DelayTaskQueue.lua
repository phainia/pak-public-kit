local Queue = require("Utils.Queue")
local DelayTaskQueue = Class("DelayTaskQueue")

function DelayTaskQueue:Ctor()
  self.task_queue = Queue()
end

function DelayTaskQueue:Add(Delay, Caller, TaskFunction, ...)
  local task = {
    delay = Delay,
    task = TaskFunction,
    caller = Caller,
    args = {
      ...
    }
  }
  self.task_queue:Enqueue(task)
  self.is_processing = false
end

function DelayTaskQueue:ExecuteTask(taskInfo)
  Log.DebugFormat("Executing task %s with delay %d", taskInfo.task, taskInfo.delay)
  local status, err = pcall(taskInfo.task, taskInfo.caller, table.unpack(taskInfo.args))
  if not status then
    Log.Error(err, debug.traceback())
  end
end

function DelayTaskQueue:ProcessTaskQueue()
  if self.is_processing then
    return
  end
  local processNextTask = function()
    if 0 == self.task_queue:Size() then
      Log.Debug("task queue empty")
      self.is_processing = false
      return
    end
    self.is_processing = true
    local taskInfo = self.task_queue:Dequeue()
    if taskInfo.delay > 0 then
      _G.DelayManager:DelaySeconds(taskInfo.delay, function()
        self:ExecuteTask(taskInfo)
        processNextTask()
      end)
    else
      self:ExecuteTask(taskInfo)
      processNextTask()
    end
  end
  processNextTask()
end

function DelayTaskQueue:Clear()
  self.task_queue:Clear()
end

return DelayTaskQueue
