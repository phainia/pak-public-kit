local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local SeasonSignActivityObject = Base:Extend("PetCollectActivityObject")

function SeasonSignActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.svrActivityData = _updateData
    local _activityData = _updateData
    self.season_checkin_data = _activityData and _activityData.season_checkin_data
    self:SendEvent(ActivityModuleEvent.RefreshSeasonSignData, self, true)
  end
end

function SeasonSignActivityObject:ReqGetRewards(pointIndexGroup)
  if not pointIndexGroup or #pointIndexGroup <= 0 then
    return
  end
  if self:IsActivityInactive() then
    ActivityUtils.ShowActivityExpiredTips()
    return
  end
  local req = _G.ProtoMessage:newZoneReceivePlayerActivitySeasonCheckinRewardReq()
  req.activity_id = self:GetActivityId()
  req.activity_reward_index = pointIndexGroup[1]
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_SEASON_CHECKIN_REWARD_REQ, req, self, self.OnZoneReceivePlayerActivityPetCatchRewardRsp)
end

function SeasonSignActivityObject:OnZoneReceivePlayerActivityPetCatchRewardRsp(_protoData, _req)
  if not _protoData or 0 ~= _protoData.ret_info.ret_code then
    return
  end
  if not _req or _req.activity_id ~= self:GetActivityId() then
    Log.ErrorFormat("parameter error! req[%d] != cur[%d]", _req and _req.activity_id or 0, self:GetActivityId())
    return
  end
  self:UpdateReceivedRewardsIndex(_req.activity_reward_index, true, _protoData)
end

function SeasonSignActivityObject:UpdateReceivedRewardsIndex(_receivedRewardsIndex, _userOperation, _protoData)
  if not _receivedRewardsIndex then
    return
  end
  for _, _index in ipairs({_receivedRewardsIndex}) do
    if not table.contains(self.receivedRewardsIndex, _index) then
      table.insert(self.receivedRewardsIndex, _index)
    end
  end
  self:SendEvent(ActivityModuleEvent.RefreshReceivePetCatchRewards, self, _receivedRewardsIndex, _userOperation, _protoData)
end

function SeasonSignActivityObject:IsRewardGet(pointIndex)
  local RewardsData = self.season_checkin_data.reward_data
  local receivedRewardsIndex = {}
  for i, v in ipairs(RewardsData) do
    if v.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      table.insert(receivedRewardsIndex, v.activity_rewards_index)
    end
  end
  return table.contains(receivedRewardsIndex, pointIndex)
end

function SeasonSignActivityObject:GetPoints()
  local SeasonCheckinConf = self.SeasonCheckinConf
  local curNum = 0
  if SeasonCheckinConf then
    if SeasonCheckinConf.change_goods_type == Enum.GoodsType.GT_VITEM then
      curNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(SeasonCheckinConf.change_goods_id)
    elseif SeasonCheckinConf.change_goods_type == Enum.GoodsType.GT_BAGITEM then
      local BagItem = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, SeasonCheckinConf.change_goods_id)
      curNum = BagItem and BagItem.num or 0
    end
  end
  return curNum
end

function SeasonSignActivityObject:GetPointsRewards()
  return self.SeasonCheckinConf and self.SeasonCheckinConf.reward_group
end

function SeasonSignActivityObject:GetPointsMax()
  local SeasonCheckinConf = self.SeasonCheckinConf
  local targetNum = 0
  local reward_group = SeasonCheckinConf and SeasonCheckinConf.reward_group
  for i, v in ipairs(reward_group) do
    if v.points_condition and v.points_condition > 0 and targetNum < v.points_condition then
      targetNum = v.points_condition
    end
  end
  return targetNum
end

function SeasonSignActivityObject:OnConstruct(_conf)
  local base_id = self.activityConf and self.activityConf.base_id and self.activityConf.base_id[1]
  self.SeasonCheckinConf = _G.DataConfigManager:GetActivitySeasonCheckinConf(base_id)
end

return SeasonSignActivityObject
