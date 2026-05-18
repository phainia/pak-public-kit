local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_KingCelebrationHeatItem_C = Base:Extend("UMG_KingCelebrationHeatItem_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleCmd = require("NewRoco.Modules.System.Activity.ActivityModuleCmd")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_KingCelebrationHeatItem_C:OnConstruct()
  if self.icon_1 then
    local vConf = _G.DataConfigManager:GetVisualItemConf(_G.Enum.VisualItem.VI_SPRING_FESTIVAL_COIN)
    if vConf then
      self.icon_1:SetPath(vConf.bigIcon)
    end
  end
end

function UMG_KingCelebrationHeatItem_C:OnDestruct()
end

function UMG_KingCelebrationHeatItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local taskId = _data.taskID
  self.RedDot:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.RedDot:SetupKey(443, {taskId})
  local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
  if not taskConf then
    Log.Warning("UMG_KingCelebrationHeatItem_C:OnItemUpdate taskConf not found, taskId: ", taskId)
    return
  end
  local SpringFestivalActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_SPRING_FESTIVAL)
  if SpringFestivalActivityObject and SpringFestivalActivityObject[1] then
    local taskInfo = SpringFestivalActivityObject[1]:GetSpringTaskInfo(taskId)
    if taskInfo then
      self.taskInfo = taskInfo
    end
  end
  self.rewardId = taskConf.Reward
  local rewardData = ActivityUtils.GetActivityRewardData(self.rewardId, true)
  if rewardData then
    self.Icon:SetPath(rewardData.showIcon)
    self.Text_Quantity:SetText(rewardData.itemNum)
    self:SetQuality(rewardData.itemQuality)
  end
  local Count = taskConf.task_condition[1].count
  if Count then
    self.HeatText:SetText(Count)
  end
  local taskState = self.taskInfo.state
  if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_KingCelebrationHeatItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_KingCelebrationHeatItem_C:OnItemSelected(_bSelected)
  local taskState = self.taskInfo.state
  if _bSelected then
    if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      local req = _G.ProtoMessage:newZoneTaskRewardReq()
      req.task_list = {
        self.taskInfo.id
      }
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_REQ, req, self, self.OnZoneTaskRewardRsp, false, true)
    elseif taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      ActivityUtils.ShowRewardTips(self.rewardId)
    else
      ActivityUtils.ShowRewardTips(self.rewardId)
    end
  end
end

function UMG_KingCelebrationHeatItem_C:OnZoneTaskRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
    local CurRewardConf = rsp.ret_info.goods_reward
    if #CurRewardConf.rewards > 0 then
      local newRewards = self:MergeRewards(CurRewardConf.rewards)
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, newRewards, "")
    end
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
end

function UMG_KingCelebrationHeatItem_C:MergeRewards(_rspRewards)
  local newRewards = {}
  for _, goodsItem in ipairs(_rspRewards) do
    if goodsItem.reward_reason ~= _G.ProtoEnum.FlowReason.FLOW_REASON_LEVEL_REWARD then
      table.insert(newRewards, goodsItem)
    end
  end
  return newRewards
end

function UMG_KingCelebrationHeatItem_C:OnDeactive()
end

return UMG_KingCelebrationHeatItem_C
