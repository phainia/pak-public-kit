local TaskActionBase = require("NewRoco.Modules.Core.Task.TaskActionBase")
local Base = TaskActionBase
local TaskActionImageFlow = Base:Extend("TaskActionImageFlow")

function TaskActionImageFlow:Ctor(Task, ActionGroup, ActionIndex, Conf)
  Base.Ctor(self, Task, ActionGroup, ActionIndex, Conf)
  self.ImageFlowID = tonumber(Conf.data1[1] or 0) or 0
  self.bExecuted = false
end

function TaskActionImageFlow:ShouldExecute()
  if self.bExecuted then
    return false
  end
  local State = self.Task.Info.state
  return State == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN or State == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN_PLAY or State == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE or State == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE_PLAY
end

function TaskActionImageFlow:OnExecute()
  self.bExecuted = true
  local Param = {}
  Param.ImageFlowID = self.ImageFlowID
  Param.Caller = self
  Param.Callback = self.OnImageFlowFinish
  Param.Style = 1
  NRCModeManager:DoCmd(TaskModuleCmd.PlayTaskImageFlow, Param)
end

function TaskActionImageFlow:OnImageFlowFinish(bSuccess)
  if bSuccess then
    self:Finish()
  else
    Log.Debug("[TaskActionImageFlow:OnImageFlowFinish] ImageFlow Finish Failed")
  end
end

function TaskActionImageFlow:SendFinishReq()
  local Req = ProtoMessage:newZoneTaskConditionTriggerReq()
  Req.taskid = self.Task.Config.id
  Req.condition_type = self.Conf.type
  Log.Debug("[TaskActionImageFlow:SendFinishReq] Send Finish Req")
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_TASK_CONDITION_TRIGGER_REQ, Req, self, self.OnSendFinish, false, false)
end

function TaskActionImageFlow:OnSendFinish(Rsp)
  self:Finish()
end

function TaskActionImageFlow:Destroy()
end

return TaskActionImageFlow
