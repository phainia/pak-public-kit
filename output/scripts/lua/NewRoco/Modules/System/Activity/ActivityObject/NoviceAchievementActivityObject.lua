local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local NoviceAchievementActivityObject = Base:Extend("NoviceAchievementActivityObject")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityConditionRewardHandler = require("NewRoco.Modules.System.Activity.ActivityObject.ConditionRewardHandler")

function NoviceAchievementActivityObject:OnConstruct(_conf)
  self.activityGroupConf = _G.DataConfigManager:GetActivityConditionGroupConf(self:GetActivityId())
  self.rewardItemMap = {}
  for i = Enum.ActivityConditionTaskGroup.ACTG_GROUP_1, Enum.ActivityConditionTaskGroup.ACTG_GROUP_4 do
    local conf = self:GetSingleGroupConf(i)
    if conf and conf.include_condition_id then
      for j, v in ipairs(conf.include_condition_id) do
        local itemObject = ActivityConditionRewardHandler.CreateConditionRewardItemObject(self, _G.DataConfigManager:GetActivityConditionRewardConf(v))
        self.rewardItemMap[v] = itemObject
      end
    end
  end
end

function NoviceAchievementActivityObject:OnDestruct()
end

function NoviceAchievementActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local _activityData = _updateData
    self.condGroupData = _activityData.cond_group_data
    self:SendEvent(ActivityModuleEvent.RefreshNoviceAchievementActivityData, self:GetActivityId(), self.condGroupData)
  end
end

function NoviceAchievementActivityObject:GetActivityGroupConf()
  return self.activityGroupConf
end

function NoviceAchievementActivityObject:GetCondGroupData()
  return self.condGroupData
end

function NoviceAchievementActivityObject:SingleGroupIsLock(groupId, bShowTips)
  local bIsLock = false
  local conf = self:GetSingleGroupConf(groupId)
  local data = self:GetSingleGroupData(groupId)
  if data then
    bIsLock = data.is_unlock
  else
    local level = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
    bIsLock = level >= (conf.require_world_level or 0)
  end
  if not bIsLock and bShowTips and conf then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, conf.unlock_tips)
  end
  return bIsLock
end

function NoviceAchievementActivityObject:GetSingleGroupConf(groupId)
  if self.activityGroupConf and self.activityGroupConf.part_group then
    for i, v in ipairs(self.activityGroupConf.part_group) do
      if v.part_enum == groupId then
        return v
      end
    end
  end
  return nil
end

function NoviceAchievementActivityObject:GetSingleGroupData(groupId)
  if self.condGroupData and self.condGroupData.group_data then
    for i, v in ipairs(self.condGroupData.group_data) do
      if v.group_id == groupId then
        return v
      end
    end
  end
  return nil
end

function NoviceAchievementActivityObject:GetSingleConditionState(groupId, conditionId)
  local data = self:GetSingleGroupData(groupId)
  if data and data.cond_data then
    for j, v2 in ipairs(data.cond_data) do
      if v2.condition_id == conditionId then
        return v2.reward_state
      end
    end
  end
  return nil
end

function NoviceAchievementActivityObject:GetGroupConfName(groupId)
  if self.activityGroupConf and self.activityGroupConf.part_group then
    for i, v in ipairs(self.activityGroupConf.part_group) do
      if v.part_enum == groupId then
        return v.part_name
      end
    end
  end
  return nil
end

function NoviceAchievementActivityObject:GetSingleGroupProgressInfo(groupId)
  local groupConf = self:GetSingleGroupConf(groupId)
  local groupData = self:GetSingleGroupData(groupId)
  local totalNum = 0
  local completedNum = 0
  local hasRewardWait = false
  local bIsLock = self:SingleGroupIsLock(groupId, false)
  if groupConf and groupConf.include_condition_id then
    totalNum = #groupConf.include_condition_id
  end
  if groupData and groupData.cond_data then
    for i, v in ipairs(groupData.cond_data) do
      if v.reward_state ~= ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
        completedNum = completedNum + 1
        if v.reward_state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
          hasRewardWait = true
        end
      end
    end
  end
  if 0 == completedNum or 0 == totalNum then
    return 0, hasRewardWait, bIsLock
  end
  return math.floor(completedNum / totalNum * 100 + 0.5), hasRewardWait, bIsLock
end

function NoviceAchievementActivityObject:GetBigRewardProgressInfo()
  local totalNum = 0
  local completedGroupNum = 0
  local state = self.condGroupData and self.condGroupData.reward_state or ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNOPEN
  if self.activityGroupConf and self.activityGroupConf.part_group then
    for i, v in ipairs(self.activityGroupConf.part_group) do
      totalNum = totalNum + 1
      local groupData = self:GetSingleGroupData(v.part_enum)
      if groupData and groupData.is_finish_all and groupData.is_unlock then
        completedGroupNum = completedGroupNum + 1
      end
    end
  end
  return state, completedGroupNum, totalNum
end

function NoviceAchievementActivityObject:GetBigRewardInfo()
  local dataList = {}
  if self.activityGroupConf then
    local rewardConf = _G.DataConfigManager:GetRewardConf(self.activityGroupConf.entire_reward)
    if rewardConf and rewardConf.RewardItem and #rewardConf.RewardItem > 0 then
      for i, v in ipairs(rewardConf.RewardItem) do
        local data = {
          itemId = v.Id,
          itemType = v.Type,
          itemNum = v.Count
        }
        table.insert(dataList, data)
      end
    end
  end
  return dataList
end

function NoviceAchievementActivityObject:GetDialogTextList()
  local dialogTextList = {}
  if self.activityGroupConf and self.activityGroupConf.dialogue_group then
    for i, v in ipairs(self.activityGroupConf.dialogue_group) do
      table.insert(dialogTextList, v.dialogue_text)
    end
  end
  return dialogTextList
end

function NoviceAchievementActivityObject:GetReward(groupId, conditionId)
  local req = _G.ProtoMessage:newZoneReceiveActivityConditionGroupRewardReq()
  req.activity_id = self:GetActivityId()
  req.group_id = groupId or 0
  req.condition_id = conditionId or 0
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_ACTIVITY_CONDITION_GROUP_REWARD_REQ, req, self, self.OnGetRewardResponse)
end

function NoviceAchievementActivityObject:OnGetRewardResponse(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:ReqGetPlayerActivityData()
    if rsp.ret_info.goods_reward and rsp.ret_info.goods_reward.rewards and #rsp.ret_info.goods_reward.rewards > 0 then
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, table.deepCopy(rsp.ret_info.goods_reward.rewards))
    end
  end
end

function NoviceAchievementActivityObject:GetConditionRewardProgress(conditionId)
  if self.rewardItemMap[conditionId] then
    return self.rewardItemMap[conditionId]:GetProgress()
  end
  return nil
end

function NoviceAchievementActivityObject:RefreshAllConditionProgress()
  if self.rewardItemMap then
    for i, v in pairs(self.rewardItemMap) do
      v:UpdateProgress()
    end
  end
end

return NoviceAchievementActivityObject
