local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local TaskInAreaChecker = Base:Extend("TaskInAreaChecker")

function TaskInAreaChecker:BindTask(Task)
  self.RelatedTask = Task
end

function TaskInAreaChecker:CheckPass()
  local Task = self.RelatedTask
  if not Task then
    return true
  end
  return Task:IsInActionArea()
end

function TaskInAreaChecker:StartCheck()
  local Task = self.RelatedTask
  if Task then
    Task:RevokeActionArea(self)
  end
end

function TaskInAreaChecker:EndCheck()
  self.RelatedTask = nil
end

return TaskInAreaChecker
