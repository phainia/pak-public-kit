local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local SpringFestivalActivityObject = Base:Extend("SpringFestivalActivityObject")

function SpringFestivalActivityObject:OnConstruct(_conf)
  self.festivalTaskInfoList = {}
  local partID = self:GetSinglePartId()
  Log.Debug("[SpringFestival] OnConstruct partID:", partID)
  if partID then
    self.activitySpringConf = _G.DataConfigManager:GetActivitySpringFestivalConf(partID)
  end
  self.LastSpringFestivalNum = 0
  self.LastGlobalNum = 0
end

function SpringFestivalActivityObject:GetTabRedPointCustomExtraKeyList()
  local extraKeyList = {}
  local ActivityID = self:GetActivityId()
  if self.activitySpringConf then
    for _, taskId in ipairs(self.activitySpringConf.global_vitem_task) do
      table.insert(extraKeyList, {ActivityID, taskId})
    end
  end
  return extraKeyList
end

function SpringFestivalActivityObject:SetLastGlobalNum(_num)
  Log.Debug("[SpringFestival] SetLastGlobalNum:", _num)
  self.LastGlobalNum = _num
end

function SpringFestivalActivityObject:GetLastGlobalNum()
  Log.Debug("[SpringFestival] GetLastGlobalNum return:", self.LastGlobalNum)
  return self.LastGlobalNum
end

function SpringFestivalActivityObject:SetLastSpringFestivalNum(_num)
  Log.Debug("[SpringFestival] SetLastSpringFestivalNum:", _num)
  self.LastSpringFestivalNum = _num
end

function SpringFestivalActivityObject:GetLastSpringFestivalNum()
  Log.Debug("[SpringFestival] GetLastSpringFestivalNum return:", self.LastSpringFestivalNum)
  return self.LastSpringFestivalNum
end

function SpringFestivalActivityObject:OnDestruct()
  self.festivalTaskInfoList = nil
end

function SpringFestivalActivityObject:GetSpringTaskInfo(taskId)
  if not taskId then
    Log.Warning("[SpringFestival] GetSpringTaskInfo taskId is nil")
    return nil
  end
  if self.festivalTaskInfoList[taskId] then
    local taskInfo = self.festivalTaskInfoList[taskId]
    Log.Debug("[SpringFestival] GetSpringTaskInfo taskId:", taskId, "found, task_target_list:", taskInfo.task_target_list and table.concat(taskInfo.task_target_list, ",") or "nil")
    return taskInfo
  end
  Log.Warning("[SpringFestival] GetSpringTaskInfo taskInfo not found, taskId:", taskId)
  return nil
end

function SpringFestivalActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.svrActivityData = _updateData
    Log.Dump(_updateData, 3, "[SpringFestival] SpringFestivalActivityObject:OnSvrUpdateActivityData")
    local _activityData = _updateData
    local springFestivalData = _activityData.spring_festival_data
    self.springFestivalData = springFestivalData
    if springFestivalData then
      self:ReqGetGlobalAndPersonalFestivalTaskData()
    end
  elseif _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_ADD_PLAYER_ACTIVITY_PART_REWARD_NTY then
  end
end

function SpringFestivalActivityObject:UpdateFestivalTaskInfoList(_taskInfoList)
  if not _taskInfoList then
    Log.Error("[SpringFestival] UpdateFestivalTaskInfoList taskInfoList is nil")
    return
  end
  Log.Debug("[SpringFestival] UpdateFestivalTaskInfoList count:", #_taskInfoList)
  for _, taskInfo in ipairs(_taskInfoList) do
    self.festivalTaskInfoList[taskInfo.id] = taskInfo
    Log.Debug("[SpringFestival] UpdateFestivalTaskInfoList taskId:", taskInfo.id, "task_target_list:", taskInfo.task_target_list and table.concat(taskInfo.task_target_list, ",") or "nil")
  end
  self:SendEvent(ActivityModuleEvent.RefreshSpringFestivalActivityData, self)
end

function SpringFestivalActivityObject:GetTaskType(_taskId)
  if not _taskId then
    return ActivityEnum.SprintTaskType.None
  end
  if self.springFestivalData.global_popularity_task_ids then
    for _, taskId in ipairs(self.springFestivalData.global_popularity_task_ids) do
      if taskId == _taskId then
        return ActivityEnum.SprintTaskType.ServerPopularityTask
      end
    end
  end
  return ActivityEnum.SprintTaskType.None
end

function SpringFestivalActivityObject:ReqGetGlobalAndPersonalFestivalTaskData()
  local taskList = {}
  if self.springFestivalData.global_popularity_task_ids then
    for _, taskId in ipairs(self.springFestivalData.global_popularity_task_ids) do
      table.insert(taskList, taskId)
    end
  end
  local req = _G.ProtoMessage:newZoneTaskQueryReq()
  req.task_list = taskList
  req.task_state = 0
  Log.Dump(req, 3, "[SpringFestival] SpringFestivalActivityObjectdump :ReqGetGlobalAndPersonalFestivalTaskData")
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_QUERY_REQ, req, self, self.OnFestivalTaskQueryRsp)
end

function SpringFestivalActivityObject:OnFestivalTaskQueryRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    Log.Error("[SpringFestival] OnFestivalTaskQueryRsp failed, ret_code:", _protoData and _protoData.ret_info.ret_code or "nil")
    return
  end
  Log.Debug("[SpringFestival] OnFestivalTaskQueryRsp success, task_info_list count:", _protoData.task_info_list and #_protoData.task_info_list or 0)
  Log.Dump(_protoData, 3, "[SpringFestival] SpringFestivalActivityObjectdump :OnFestivalTaskQueryRsp")
  self:UpdateFestivalTaskInfoList(_protoData.task_info_list)
end

function SpringFestivalActivityObject:GetSubActivityState()
  local taskIds = self.activitySpringConf.task_conf_id
  if taskIds and #taskIds > 0 then
    for i, v in ipairs(taskIds) do
      local taskData = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.getTaskByID, v)
      if taskData then
        if i == #taskIds and taskData.state >= ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
          return ActivityEnum.SprintSubActivityState.Ended
        elseif taskData.state < ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
          return ActivityEnum.SprintSubActivityState.InProgress
        end
      end
    end
  end
  return ActivityEnum.SprintSubActivityState.Ended
end

function SpringFestivalActivityObject:GetCurTaskId()
  local taskIds = self.activitySpringConf.task_conf_id
  if taskIds and #taskIds > 0 then
    for i, taskId in ipairs(taskIds) do
      local taskInfo = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.getTaskByID, taskId)
      if taskInfo and taskInfo.state < ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
        return taskId
      end
    end
    return taskIds[#taskIds]
  end
  return 0
end

function SpringFestivalActivityObject:GetCurTaskName()
  local taskId = self:GetCurTaskId()
  if taskId and taskId > 0 then
    local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
    if taskConf then
      return taskConf.name
    end
  end
end

function SpringFestivalActivityObject:OnSubActivityClick()
  local taskId = self:GetCurTaskId()
  if taskId and taskId > 0 then
    _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenTaskPanel, taskId)
  end
end

return SpringFestivalActivityObject
