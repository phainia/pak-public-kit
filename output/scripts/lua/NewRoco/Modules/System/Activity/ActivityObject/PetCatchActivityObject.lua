local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectWithPreTaskBase")
local PetCatchActivityObject = Base:Extend("PetCatchActivityObject")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function PetCatchActivityObject:OnConstruct(_conf)
  self.petCatchConf = _G.DataConfigManager:GetActivityPetCatchConf(self:GetSinglePartId())
  self.first_task_id = self.petCatchConf and self.petCatchConf.first_task_id
  self.preTaskId = self.petCatchConf and self.petCatchConf.first_task_id
  self.tailTaskID = self.petCatchConf and self.petCatchConf.unlock_task_id
  self:InitTaskList()
  self.preTaskStatus = 0
  self.receivedRewardsIndex = {}
  self.points = 0
end

function PetCatchActivityObject:InitTaskList()
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

function PetCatchActivityObject:GetTaskList()
  return self.TaskList
end

function PetCatchActivityObject:GetPoints()
  return self.points or 0
end

function PetCatchActivityObject:GetPointsMax()
  return self.petCatchConf and self.petCatchConf.points_max
end

function PetCatchActivityObject:GetPointsRewards()
  return self.petCatchConf and self.petCatchConf.reward_group
end

function PetCatchActivityObject:GetPreviewRewards()
  return self.petCatchConf and self.petCatchConf.preview_reward_group
end

function PetCatchActivityObject:IsRewardGet(pointIndex)
  return table.contains(self.receivedRewardsIndex, pointIndex)
end

function PetCatchActivityObject:ReqGetRewards(pointIndexGroup)
  if not pointIndexGroup or #pointIndexGroup <= 0 then
    return
  end
  if self:IsActivityInactive() then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  local req = _G.ProtoMessage:newZoneReceivePlayerActivityPetCatchRewardReq()
  req.activity_id = self:GetActivityId()
  req.point_index = pointIndexGroup
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PET_CATCH_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityPetCatchRewardRsp)
end

function PetCatchActivityObject:UpdatePoints(_newPoints, _userOperation)
  if not _newPoints then
    return
  end
  self.points = _newPoints
  self:SendEvent(ActivityModuleEvent.RefreshPetCatchPoints, self, _userOperation)
end

function PetCatchActivityObject:UpdateReceivedRewardsIndex(_receivedRewardsIndex, _userOperation, _protoData)
  if not _receivedRewardsIndex then
    return
  end
  for _, _index in ipairs(_receivedRewardsIndex) do
    if not table.contains(self.receivedRewardsIndex, _index) then
      table.insert(self.receivedRewardsIndex, _index)
    end
  end
  self:SendEvent(ActivityModuleEvent.RefreshReceivePetCatchRewards, self, _receivedRewardsIndex, _userOperation, _protoData)
end

function PetCatchActivityObject:OnZoneReceivePlayerActivityPetCatchRewardRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not _req or _req.activity_id ~= self:GetActivityId() then
    Log.ErrorFormat("parameter error! req[%d] != cur[%d]", _req and _req.activity_id or 0, self:GetActivityId())
    return
  end
  self:UpdateReceivedRewardsIndex(_req.point_index, true, _protoData)
end

function PetCatchActivityObject:GetPreTaskId()
  if not self.tailTaskID or 0 == self.tailTaskID then
    return nil
  end
  return self.preTaskId
end

function PetCatchActivityObject:GetPreTaskStatus()
  return self.preTaskStatus
end

function PetCatchActivityObject:UpdatePreTaskStatus(_id, _taskStatus)
  if self.TaskMap[_id] then
    self.TaskMap[_id] = _taskStatus
  end
  self.preTaskId = _id
  self.preTaskStatus = _taskStatus
  self:SendEvent(ActivityModuleEvent.RefreshPetCatchTaskState, self)
end

function PetCatchActivityObject:HasAcceptedTask()
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

function PetCatchActivityObject:SyncActivityDataOnAvailable()
  self:SendZoneTaskQueryReq()
end

function PetCatchActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local _activityData = _updateData
    local _petCatchData = _activityData and _activityData.pet_catch_data
    if _petCatchData then
      self:UpdatePoints(_petCatchData.points, false)
      self:UpdateReceivedRewardsIndex(_petCatchData.received_rewards_index, false, nil)
    end
  end
end

return PetCatchActivityObject
