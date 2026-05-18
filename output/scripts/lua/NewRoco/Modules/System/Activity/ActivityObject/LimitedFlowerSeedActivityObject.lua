local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectWithPreTaskBase")
local LimitedFlowerSeedActivityObject = Base:Extend("LimitedFlowerSeedActivityObject")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function LimitedFlowerSeedActivityObject:OnConstruct(_conf)
  self.petRaiseConf = _G.DataConfigManager:GetActivityPetRaiseConf(self:GetSinglePartId())
  self.first_task_id = self.petRaiseConf and self.petRaiseConf.first_task_id
  self.preTaskId = self.petRaiseConf and self.petRaiseConf.first_task_id
  self.tailTaskID = self.petRaiseConf and self.petRaiseConf.unlock_task_id
  self:InitTaskList()
  self.preTaskStatus = 0
end

function LimitedFlowerSeedActivityObject:InitTaskList()
  local TaskMap = {}
  local TaskList = {}
  local taskID = self.first_task_id
  table.insert(TaskList, taskID)
  TaskMap[taskID] = 0
  while true do
    local Conf = _G.DataConfigManager:GetTaskConf(taskID)
    if not Conf then
      Log.Error("\228\187\187\229\138\161\233\133\141\231\189\174\230\156\137\232\175\175\239\188\140\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174")
      break
    else
      if not (Conf.next_task and Conf.next_task[1]) then
        break
      end
      taskID = Conf.next_task[1]
      TaskMap[taskID] = 0
      table.insert(TaskList, taskID)
      if taskID ~= self.tailTaskID then
      else
        break
      end
    end
  end
  self.TaskMap = TaskMap
  self.TaskList = TaskList
end

function LimitedFlowerSeedActivityObject:GetTaskList()
  return self.TaskList
end

function LimitedFlowerSeedActivityObject:OnDestruct()
end

function LimitedFlowerSeedActivityObject:GetPlayerLimitedFlowerSeedInfo()
  return self.playerLimitedFlowerSeedInfo
end

function LimitedFlowerSeedActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local _activityData = _updateData
    self.playerLimitedFlowerSeedInfo = _activityData and _activityData.limited_flower_seed_info
    self:SendEvent(ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo, self)
  end
end

function LimitedFlowerSeedActivityObject:GetPlayerSelectSpecFlowerSeedData()
  local limitedSeed = self.playerLimitedFlowerSeedInfo
  local flowerSeedId = limitedSeed and limitedSeed.spec_flower_seed_id or 0
  if 0 == flowerSeedId then
    return
  end
  return ActivityUtils.GetPlayerSelectSpecFlowerSeedDataById(flowerSeedId)
end

function LimitedFlowerSeedActivityObject:GetInvestTaskInfo()
  local limitedSeedInfo = self.playerLimitedFlowerSeedInfo
  local flowerSeedId = limitedSeedInfo and limitedSeedInfo.spec_flower_seed_id or 0
  if 0 == flowerSeedId then
    return
  end
  local petGroupConf
  if self.petRaiseConf then
    for _, _conf in ipairs(self.petRaiseConf.pet_group) do
      if _conf.activity_spec_flower_seed_conf_id == flowerSeedId then
        petGroupConf = _conf
        break
      end
    end
  end
  if not petGroupConf then
    return
  end
  local investTaskStatus = {}
  local investTaskInfo = limitedSeedInfo and limitedSeedInfo.invest_task_info
  if investTaskInfo and #investTaskInfo > 0 then
    for _, _taskInfo in ipairs(investTaskInfo) do
      investTaskStatus[_taskInfo.task_id] = _taskInfo.task_state
    end
  end
  local tailTask = petGroupConf.task_id
  local tailTaskStatus = investTaskStatus[tailTask]
  if tailTaskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN or tailTaskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    return tailTaskStatus, tailTask
  end
  local beginTask = _G.DataConfigManager:GetTaskSwitchConf(petGroupConf.task_switch_id).begintask
  local curTasks = {beginTask}
  local addNextTaskFlag = true
  local processedTasks = {}
  while #curTasks > 0 do
    local nextTasks = {}
    local containsTailTask = false
    for _, _taskId in ipairs(curTasks) do
      if not processedTasks[_taskId] then
        processedTasks[_taskId] = true
        local taskStatus = investTaskStatus[_taskId]
        if taskStatus == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
          return taskStatus, _taskId
        end
        if addNextTaskFlag then
          local taskNext = _G.DataConfigManager:GetTaskConf(_taskId).next_task
          if taskNext then
            for _, _nextId in ipairs(taskNext) do
              if _nextId == tailTask then
                containsTailTask = true
              else
                table.insert(nextTasks, _nextId)
              end
            end
          end
        end
      end
    end
    curTasks = nextTasks
    if containsTailTask then
      addNextTaskFlag = false
    end
  end
end

function LimitedFlowerSeedActivityObject:GetPetRaiseConf()
  return self.petRaiseConf
end

function LimitedFlowerSeedActivityObject:GetPreTaskId()
  if not self.tailTaskID or 0 == self.tailTaskID then
    return nil
  end
  return self.preTaskId
end

function LimitedFlowerSeedActivityObject:GetPreTaskStatus()
  return self.preTaskStatus
end

function LimitedFlowerSeedActivityObject:SyncActivityDataOnAvailable()
  self:SendZoneGetLimitedFlowerSeedInfoReq()
end

function LimitedFlowerSeedActivityObject:SendZoneSelectLimitedFlowerSeedPetReq(seedId)
  local req = _G.ProtoMessage:newZoneSelectLimitedFlowerSeedPetReq()
  req.spec_flower_seed_id = seedId
  req.activity_id = self:GetActivityId()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_SELECT_LIMITED_FLOWER_SEED_PET_REQ, req, self, self.OnZoneSelectLimitedFlowerSeedPetRsp)
end

function LimitedFlowerSeedActivityObject:SendZoneGetLimitedFlowerSeedInfoReq()
  if self:GetSvrStatus() ~= ActivityEnum.ActivitySvrStatus.Available then
    return
  end
  local req = _G.ProtoMessage:newZoneGetLimitedFlowerSeedInfoReq()
  req.activity_id = self:GetActivityId()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_LIMITED_FLOWER_SEED_INFO_REQ, req, self, self.OnZoneGetLimitedFlowerSeedInfoRsp)
end

function LimitedFlowerSeedActivityObject:OnZoneSelectLimitedFlowerSeedPetRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not _req or _req.activity_id ~= self:GetActivityId() then
    return
  end
  if _req.spec_flower_seed_id and self.playerLimitedFlowerSeedInfo then
    self.playerLimitedFlowerSeedInfo.spec_flower_seed_id = _req.spec_flower_seed_id
    self:SendZoneGetLimitedFlowerSeedInfoReq()
  end
end

function LimitedFlowerSeedActivityObject:OnZoneGetLimitedFlowerSeedInfoRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not _req or _req.activity_id ~= self:GetActivityId() then
    return
  end
  self.playerLimitedFlowerSeedInfo = _protoData.limited_flower_seed_info
  self:SendEvent(ActivityModuleEvent.RefreshPlayerLimitedFlowerSeedInfo, self)
  self:SendEvent(ActivityModuleEvent.RefreshLimitedFlowerSeedTaskState, self)
end

function LimitedFlowerSeedActivityObject:UpdatePreTaskStatus(_id, _taskStatus)
  if self.TaskMap[_id] then
    self.TaskMap[_id] = _taskStatus
  end
  if _taskStatus == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN or _id == self.tailTaskID then
    self.preTaskId = _id
    self.preTaskStatus = _taskStatus
  end
  self:SendEvent(ActivityModuleEvent.RefreshLimitedFlowerSeedTaskState, self)
end

function LimitedFlowerSeedActivityObject:HasAcceptedTask()
  if not self.tailTaskID or 0 == self.tailTaskID then
    return true
  end
  for Task, Status in pairs(self.TaskMap) do
    if 0 ~= Status then
      return true
    end
  end
  return false
end

function LimitedFlowerSeedActivityObject:SendZoneTaskQueryReq(_taskList)
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

function LimitedFlowerSeedActivityObject:OnZoneTaskQueryRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  local taskInfoList = _protoData.task_info_list
  if taskInfoList then
    for _, _taskInfo in ipairs(taskInfoList) do
      self:UpdatePreTaskStatus(_taskInfo.id, _taskInfo.state)
    end
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OnAddTaskInfos, taskInfoList)
  end
end

return LimitedFlowerSeedActivityObject
