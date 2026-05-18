local TaskActionBase = require("NewRoco.Modules.Core.Task.TaskActionBase")
local Base = TaskActionBase
local TaskActionCmd = Base:Extend("TaskActionCmd")

function TaskActionCmd:Ctor(Task, ActionGroup, ActionIndex, Conf)
  Base.Ctor(self, Task, ActionGroup, ActionIndex, Conf)
  self.bExecuted = false
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

function TaskActionCmd:ShouldExecute()
  if self.bExecuted then
    return false
  end
  local State = self.Task.Info.state
  return State == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN or State == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN_PLAY or State == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE or State == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE_PLAY
end

function TaskActionCmd:OnExecute()
  self.bExecuted = true
  _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenClientPublicCMD, self.Conf.data1[1])
  self:Finish()
end

function TaskActionCmd:OnDisconnect()
  self.bExecuted = false
end

function TaskActionCmd:Destroy()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

return TaskActionCmd
