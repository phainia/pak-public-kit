local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityObjectWithPreTaskBase = Base:Extend("ActivityObjectWithPreTaskBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function ActivityObjectWithPreTaskBase:GetPreTaskId()
end

function ActivityObjectWithPreTaskBase:GetPreTaskStatus()
end

function ActivityObjectWithPreTaskBase:UpdatePreTaskStatus(_id, _status)
end

function ActivityObjectWithPreTaskBase:GetPreTaskData()
  local taskName = ""
  local taskConf
  local taskId = self:GetPreTaskId()
  if taskId then
    taskConf = _G.DataConfigManager:GetTaskConf(taskId)
    if taskConf then
      taskName = taskConf.name
    end
  end
  return taskName, taskConf
end

function ActivityObjectWithPreTaskBase:IsPreTaskFinished()
  if not self:GetPreTaskId() then
    return true
  end
  return self:GetPreTaskStatus() == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
end

function ActivityObjectWithPreTaskBase:IsInProgress()
  return Base.IsInProgress(self) and self:IsPreTaskFinished()
end

function ActivityObjectWithPreTaskBase:SendZoneTaskQueryReq(_taskList)
  if self:GetSvrStatus() ~= ActivityEnum.ActivitySvrStatus.Available or self:IsPreTaskFinished() then
    return
  end
  local req = _G.ProtoMessage:newZoneTaskQueryReq()
  req.task_list = _taskList or {
    self:GetPreTaskId()
  }
  req.task_state = 0
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_QUERY_REQ, req, self, self.OnZoneTaskQueryRsp)
end

function ActivityObjectWithPreTaskBase:OnZoneTaskQueryRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  local taskInfoList = _protoData.task_info_list
  if taskInfoList then
    for _, _taskInfo in ipairs(taskInfoList) do
      self:UpdatePreTaskStatus(_taskInfo.id, _taskInfo.state)
    end
  end
end

return ActivityObjectWithPreTaskBase
