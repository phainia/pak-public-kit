local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_KingCelebration_HeatRewardItem_C = Base:Extend("UMG_KingCelebration_HeatRewardItem_C")

function UMG_KingCelebration_HeatRewardItem_C:OnConstruct()
  self.currentAnimState = 0
  self.isDotUpLit = false
  self.isDotDownLit = false
  Log.Debug("[HeatRewardItem] OnConstruct")
  _G.NRCEventCenter:RegisterEvent("UMG_KingCelebration_HeatRewardItem_C", self, ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, self.OnProgressAnimUpdate)
end

function UMG_KingCelebration_HeatRewardItem_C:OnDestruct()
  Log.Debug("[HeatRewardItem] OnDestruct")
  _G.NRCEventCenter:UnRegisterEvent(self, ActivityModuleEvent.OnKingCelebrationProgressAnimUpdate, self.OnProgressAnimUpdate)
end

function UMG_KingCelebration_HeatRewardItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.datalist = datalist
  self.index = index
  local taskId = _data.taskID
  local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
  if not taskConf then
    Log.Warning("UMG_KingCelebration_HeatRewardItem_C:OnItemUpdate taskConf not found, taskId: ", taskId)
    return
  end
  self.rewardId = taskConf.Reward
  local rewardData = ActivityUtils.GetActivityRewardData(self.rewardId, true)
  if rewardData then
    self:SetItemIcon(rewardData)
    local numText = string.format("x%d", rewardData.itemNum)
    self.Text_Day_2:SetText(numText)
    ActivityUtils:SetQuality(self.QualityColor, rewardData.itemQuality)
  end
  local SpringFestivalActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_SPRING_FESTIVAL)
  if SpringFestivalActivityObject and SpringFestivalActivityObject[1] then
    self.RedDot:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    local ActivityID = SpringFestivalActivityObject[1]:GetActivityId()
    self.RedDot:SetupKey(443, {ActivityID, taskId})
    local taskInfo = SpringFestivalActivityObject[1]:GetSpringTaskInfo(taskId)
    if taskInfo then
      self.taskInfo = taskInfo
      local lastGlobalTaskID = datalist[#datalist].taskID
      local lastGlobalTaskInfo = SpringFestivalActivityObject[1]:GetSpringTaskInfo(lastGlobalTaskID)
      local currentGlobalNum = 0
      if lastGlobalTaskInfo then
        currentGlobalNum = lastGlobalTaskInfo.task_target_list[1]
      end
      self:UpdateTaskProgressDisplay(taskInfo, currentGlobalNum)
      self:UpdateReceivedState(taskInfo.state)
      self:UpdateAnimationByState(taskInfo.state)
    end
  end
end

function UMG_KingCelebration_HeatRewardItem_C:UpdateTaskProgressDisplay(taskInfo, currentGlobalNum)
  if not (taskInfo and taskInfo.task_target_list) or 0 == #taskInfo.task_target_list then
    self.Text_DayUp:SetText("0")
    return
  end
  local progressNum = 0
  local personalNum = 0
  local currentSprintNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_SPRING_FESTIVAL_COIN) or 0
  local taskConf = _G.DataConfigManager:GetTaskConf(taskInfo.id)
  if taskConf and taskConf.task_condition and #taskConf.task_condition > 1 then
    progressNum = taskConf.task_condition[1].count
    personalNum = taskConf.task_condition[2].count
    self.Text_DayDown:SetText(tostring(personalNum))
  end
  self.progressNum = progressNum
  self.personalNum = personalNum
  self.isDotUpLit = false
  self.isDotDownLit = false
  local SpringFestivalActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_SPRING_FESTIVAL)
  if SpringFestivalActivityObject and SpringFestivalActivityObject[1] then
    local lastGlobalNum = SpringFestivalActivityObject[1]:GetLastGlobalNum() or 0
    local lastPersonalNum = SpringFestivalActivityObject[1]:GetLastSpringFestivalNum() or 0
    if progressNum > 0 then
      if 0 == lastGlobalNum then
        if currentGlobalNum >= progressNum then
          self:LightUpDotUp()
        end
      elseif progressNum <= lastGlobalNum then
        self:LightUpDotUp()
      end
    end
    if personalNum > 0 then
      if 0 == lastPersonalNum then
        if currentSprintNum >= personalNum then
          self:LightUpDotDown()
        end
      elseif personalNum <= lastPersonalNum then
        self:LightUpDotDown()
      end
    end
  end
  local text = ActivityUtils.GetSprintFormatText(progressNum)
  self.Text_DayUp:SetText(text)
end

function UMG_KingCelebration_HeatRewardItem_C:OnProgressAnimUpdate(eventData)
  Log.Debug("[HeatRewardItem] OnProgressAnimUpdate")
  if not eventData then
    return
  end
  if eventData.globalNum and self.progressNum then
    Log.Debug("[HeatRewardItem] OnProgressAnimUpdate globalNum:", eventData.globalNum, "progressNum:", self.progressNum, "isDotUpLit:", self.isDotUpLit)
    if not self.isDotUpLit and eventData.globalNum >= self.progressNum then
      Log.Debug("[HeatRewardItem] OnProgressAnimUpdate LightUpDotUp triggered")
      self:LightUpDotUp()
    end
  end
  if eventData.personalNum and self.personalNum then
    Log.Debug("[HeatRewardItem] OnProgressAnimUpdate personalNum:", eventData.personalNum, "personalNum:", self.personalNum, "isDotDownLit:", self.isDotDownLit)
    if not self.isDotDownLit and eventData.personalNum >= self.personalNum then
      Log.Debug("[HeatRewardItem] OnProgressAnimUpdate LightUpDotDown triggered")
      self:LightUpDotDown()
    end
  end
end

function UMG_KingCelebration_HeatRewardItem_C:LightUpDotUp()
  if self.isDotUpLit then
    Log.Debug("[HeatRewardItem] LightUpDotUp skipped, already lit")
    return
  end
  if self.Var_DotUp and self.DotUp then
    local outColor = UE4.FLinearColor(0, 0, 0, 1)
    UE4.UKismetMathLibrary.LinearColor_SetFromSRGB(outColor, self.Var_DotUp)
    self.DotUp:SetColorAndOpacity(outColor)
    Log.Debug("[HeatRewardItem] LightUpDotUp success, progressNum:", self.progressNum)
  else
    Log.Debug("[HeatRewardItem] LightUpDotUp failed, Var_DotUp:", self.Var_DotUp ~= nil, "DotUp:", self.DotUp ~= nil)
  end
  self.isDotUpLit = true
end

function UMG_KingCelebration_HeatRewardItem_C:LightUpDotDown()
  if self.isDotDownLit then
    Log.Debug("[HeatRewardItem] LightUpDotDown skipped, already lit")
    return
  end
  if self.Var_DotDown and self.DotDown then
    local outColor = UE4.FLinearColor(0, 0, 0, 1)
    UE4.UKismetMathLibrary.LinearColor_SetFromSRGB(outColor, self.Var_DotDown)
    self.DotDown:SetColorAndOpacity(outColor)
    Log.Debug("[HeatRewardItem] LightUpDotDown success, personalNum:", self.personalNum)
  else
    Log.Debug("[HeatRewardItem] LightUpDotDown failed, Var_DotDown:", self.Var_DotDown ~= nil, "DotDown:", self.DotDown ~= nil)
  end
  self.isDotDownLit = true
end

function UMG_KingCelebration_HeatRewardItem_C:UpdateReceivedState(taskState)
  if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_KingCelebration_HeatRewardItem_C:UpdateAnimationByState(taskState)
  self:StopAllAnimations()
  if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    if self.Reward_get_loop then
      self:PlayAnimation(self.Reward_get_loop, 0, 0)
      self.currentAnimState = taskState
    end
  elseif taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    if self.Reward_ready_loop then
      self:PlayAnimation(self.Reward_ready_loop, 0, 0)
      self.currentAnimState = taskState
    end
  elseif self.Normal then
    self:PlayAnimation(self.Normal, 0, 0)
    self.currentAnimState = taskState
  end
end

function UMG_KingCelebration_HeatRewardItem_C:GetReqTaskList()
  local reqTaskList = {}
  if not self.datalist then
    return reqTaskList, self.data and self.data.taskType or 0
  end
  local SpringFestivalActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_SPRING_FESTIVAL)
  if SpringFestivalActivityObject and SpringFestivalActivityObject[1] then
    for _, data in pairs(self.datalist) do
      if data and data.taskID then
        local taskInfo = SpringFestivalActivityObject[1]:GetSpringTaskInfo(data.taskID)
        if taskInfo and taskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
          table.insert(reqTaskList, data.taskID)
        end
      end
    end
  end
  local taskType = self.data and self.data.taskType or 0
  return reqTaskList, taskType
end

function UMG_KingCelebration_HeatRewardItem_C:OnItemSelected(_bSelected)
  if not _bSelected or not self.taskInfo then
    return
  end
  local taskState = self.taskInfo.state
  if taskState == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    local reqTaskList = self:GetReqTaskList()
    local req = _G.ProtoMessage:newZoneTaskRewardReq()
    req.task_list = reqTaskList
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_REQ, req, self, self.OnZoneTaskRewardRsp, false, true)
  else
    ActivityUtils.ShowRewardTips(self.rewardId)
  end
end

function UMG_KingCelebration_HeatRewardItem_C:OnZoneTaskRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:PlayRewardGetAnimation()
    local SpringFestivalActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_SPRING_FESTIVAL)
    if SpringFestivalActivityObject and SpringFestivalActivityObject[1] then
      SpringFestivalActivityObject[1]:ReqGetGlobalAndPersonalFestivalTaskData()
    end
    local curRewardConf = rsp.ret_info.goods_reward
    if curRewardConf and #curRewardConf.rewards > 0 then
      local newRewards = self:MergeRewards(curRewardConf.rewards)
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, newRewards, "")
    end
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
end

function UMG_KingCelebration_HeatRewardItem_C:PlayRewardGetAnimation()
  self:StopAllAnimations()
  if self.Reward_get then
    self:PlayAnimation(self.Reward_get)
  end
end

function UMG_KingCelebration_HeatRewardItem_C:MergeRewards(_rspRewards)
  local newRewards = {}
  for _, goodsItem in ipairs(_rspRewards) do
    if goodsItem.reward_reason ~= _G.ProtoEnum.FlowReason.FLOW_REASON_LEVEL_REWARD then
      table.insert(newRewards, goodsItem)
    end
  end
  return newRewards
end

function UMG_KingCelebration_HeatRewardItem_C:OnDeactive()
end

function UMG_KingCelebration_HeatRewardItem_C:OnAnimationFinished(Animation)
  if Animation == self.Reward_get then
    if self.Reward_get_loop then
      self:PlayAnimation(self.Reward_get_loop, 0, 0)
    end
  else
    if Animation == self.select then
    else
    end
  end
end

function UMG_KingCelebration_HeatRewardItem_C:SetItemIcon(rewardData)
  if rewardData and self.IconSwitcher and rewardData.itemType == Enum.GoodsType.GT_BAGITEM then
    local bag_item_conf = _G.DataConfigManager:GetBagItemConf(rewardData.itemId)
    if bag_item_conf and bag_item_conf.type == _G.Enum.BagItemType.BI_PET_EGG and bag_item_conf.item_behavior and bag_item_conf.item_behavior[1] and bag_item_conf.item_behavior[1].ratio2 and bag_item_conf.item_behavior[1].ratio2[1] then
      local eggInfo = {}
      eggInfo.random_egg_conf = bag_item_conf.item_behavior[1].ratio2[1]
      self.IconSwitcher:SetActiveWidgetIndex(1)
      self.PetEggIcon:SetEggIcon(eggInfo, rewardData.showIcon)
      return
    end
  end
  if self.IconSwitcher then
    self.IconSwitcher:SetActiveWidgetIndex(0)
  end
  self.Item:SetPath(rewardData.showIcon)
end

return UMG_KingCelebration_HeatRewardItem_C
