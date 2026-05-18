local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local LegendaryBattleActivityObject = Base:Extend("LegendaryBattleActivityObject")

function LegendaryBattleActivityObject:OnConstruct(_conf)
  self.legendaryBattleConf = _G.DataConfigManager:GetLegendaryBattleEvent(self:GetSinglePartId())
end

function LegendaryBattleActivityObject:GetActivityTaskRewards()
  local taskId = self.legendaryBattleConf.task_id
  if taskId then
    local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
    if taskConf then
      local taskRewardId = taskConf.Reward
      local Rewards = _G.DataConfigManager:GetRewardConf(taskRewardId).RewardItem
      return Rewards
    else
      return {}
    end
  else
    return {}
  end
end

function LegendaryBattleActivityObject:GetTaskId()
  return self.legendaryBattleConf.task_id
end

function LegendaryBattleActivityObject:GetActivityUniqueName()
  return self.legendaryBattleConf.quest_name
end

function LegendaryBattleActivityObject:GetActivityUniqueDesc()
  return self.legendaryBattleConf.quest_brief
end

function LegendaryBattleActivityObject:GetBossPetBaseId()
  return self.legendaryBattleConf.pet_base_id
end

function LegendaryBattleActivityObject:GetRefreshId()
  return self.legendaryBattleConf.refresh_content_id_2
end

function LegendaryBattleActivityObject:GetShowGraphPath()
  return self.legendaryBattleConf.photo_path
end

function LegendaryBattleActivityObject:GetStartAndEndTimeStamp()
  local startStamp = ActivityUtils.ToTimestamp(self.legendaryBattleConf.start_time)
  if not string.IsNilOrEmpty(self.legendaryBattleConf.duration) then
    local param = string.Split(self.legendaryBattleConf.duration, " ")
    local param1 = string.Split(param[2], ":")
    local durationSec = tonumber(param[1]) * 24 * 60 * 60 + tonumber(param1[1]) * 60 * 60 + tonumber(param1[2]) * 60 + tonumber(param1[3])
    local endStamp = startStamp + durationSec
    return startStamp, endStamp
  else
    return startStamp, -1
  end
end

function LegendaryBattleActivityObject:GetActivityIcon()
  local partIds = self:GetPartIds()
  if partIds and #partIds > 0 then
    local petBaseId = _G.DataConfigManager:GetLegendaryBattleEvent(partIds[1]).pet_base_id
    local filePath = string.format("%s%d%s", "/Game/NewRoco/Modules/System/Activity/Raw/LegendaryBattle/", petBaseId, "/")
    local selectPath = string.format("%s%s", filePath, "img_icon1.img_icon1")
    local normalPath = string.format("%s%s", filePath, "img_icon.img_icon")
    return selectPath, normalPath
  end
  return Base.GetActivityIcon(self)
end

function LegendaryBattleActivityObject:GetTabRedPointCustomExtraKeyList()
  return {
    {
      self:GetTaskId()
    }
  }
end

function LegendaryBattleActivityObject:OnZoneTaskQueryReq(taskList)
  local req = _G.ProtoMessage:newZoneTaskQueryReq()
  req.task_list = taskList
  req.task_state = 0
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_QUERY_REQ, req, self, self.OnZoneTaskQueryRsp)
end

function LegendaryBattleActivityObject:OnZoneTaskQueryRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    if rsp.task_info_list and rsp.task_info_list[1] then
      self:SendEvent(ActivityModuleEvent.LBActivityTaskStateChange, rsp.task_info_list[1].state)
    else
      self:SendEvent(ActivityModuleEvent.LBActivityTaskStateChange, -1)
    end
  end
end

function LegendaryBattleActivityObject:OnZoneTaskRewardReq(taskList)
  local req = _G.ProtoMessage:newZoneTaskRewardReq()
  req.task_list = taskList
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_REQ, req, self, self.OnZoneTaskRewardRsp)
end

function LegendaryBattleActivityObject:OnZoneTaskRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    if rsp.rewarded_task_list and rsp.rewarded_task_list[1] then
      self:SendEvent(ActivityModuleEvent.LBActivityTaskStateChange, rsp.rewarded_task_list[1].state)
      self:ShowRewardsPanel(rsp.ret_info.goods_reward.rewards)
    else
      self:SendEvent(ActivityModuleEvent.LBActivityTaskStateChange, -1)
    end
  end
end

function LegendaryBattleActivityObject:ShowRewardsPanel(rewards)
  local rewardList = {}
  for k, v in ipairs(rewards) do
    table.insert(rewardList, {
      id = v.id,
      num = v.num,
      type = v.type
    })
  end
  if #rewardList > 0 then
    _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, rewardList)
  end
end

return LegendaryBattleActivityObject
