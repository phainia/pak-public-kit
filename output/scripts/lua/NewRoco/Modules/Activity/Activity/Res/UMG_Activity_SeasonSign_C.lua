local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_SeasonSign_C = Base:Extend("UMG_Activity_SeasonSign_C")

function UMG_Activity_SeasonSign_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.promptText = self.Text_Describe
  return uiElements
end

function UMG_Activity_SeasonSign_C:OnConstruct()
  Base.OnConstruct(self)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshSeasonSignData, self.OnRefreshSeasonSignData)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshReceivePetCatchRewards, self.OnRefreshReceivePetCatchRewards)
  self:InitActivity()
  local activityId = self.activityInst:GetActivityId()
  self.redPointReward:SetupKey(427, {activityId})
  local ItemType = self.activityInst.SeasonCheckinConf and self.activityInst.SeasonCheckinConf.change_goods_type
  local ItemId = self.activityInst.SeasonCheckinConf and self.activityInst.SeasonCheckinConf.change_goods_id
  if ItemType and ItemId then
    if ItemType == Enum.GoodsType.GT_BAGITEM then
      local item_conf = _G.DataConfigManager:GetBagItemConf(ItemId)
      if item_conf then
        self.icon:SetPath(item_conf.big_icon)
      end
    end
    if ItemType == Enum.GoodsType.GT_VITEM then
      local item_conf = _G.DataConfigManager:GetVisualItemConf(ItemId)
      if item_conf then
        self.icon:SetPath(item_conf.big_icon)
      end
    end
  end
  self:AddButtonListener(self.Btn_integral, self.OpenRewardPanel)
end

function UMG_Activity_SeasonSign_C:OpenRewardPanel()
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenPetCatchReward, self.activityInst)
end

function UMG_Activity_SeasonSign_C:OnRefreshSeasonSignData(activityInst, InitTask)
  if activityInst then
    self.activityInst = activityInst
  end
  if InitTask then
    self:InitTask()
  end
  self:InitReward()
end

function UMG_Activity_SeasonSign_C:InitTask()
  local TaskList = self.activityInst and self.activityInst.task_data
  if TaskList and #TaskList > 0 then
    local List = {}
    for i, v in ipairs(TaskList) do
      table.insert(List, {
        data = v,
        activityId = self.activityInst:GetActivityId()
      })
    end
    self.List:InitList(List)
  end
end

function UMG_Activity_SeasonSign_C:InitReward()
  local curNum = self.activityInst:GetPoints()
  local targetNum = self.activityInst:GetPointsMax()
  self.Text_quantity:SetText(string.format("%d/%d", curNum, targetNum))
end

function UMG_Activity_SeasonSign_C:InitActivity()
  local activityInst = self.activityInst
  local activityConf = activityInst.activityConf
  self.Text_Title:SetText(activityConf.activity_name)
  if activityInst.svrActivityData then
    self:OnSvrUpdateActivityData(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP, activityInst.svrActivityData, true)
  end
  self:InitTask()
  self:InitReward()
end

function UMG_Activity_SeasonSign_C:OnRefreshReceivePetCatchRewards(_activityInst, _receivedRewardsIndex, _userOperation, _protoData)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  if not _userOperation then
    return
  end
  local receivedRewards = {}
  if _protoData and 0 == _protoData.ret_info.ret_code then
    for _, rewardItem in ipairs(_protoData.ret_info.goods_reward.rewards) do
      local rewardsItemData = {}
      rewardsItemData.type = rewardItem.type
      rewardsItemData.id = rewardItem.id
      rewardsItemData.num = rewardItem.num
      table.insert(receivedRewards, rewardsItemData)
    end
  else
    local rewardsGroup = _activityInst:GetPointsRewards()
    if rewardsGroup then
      for _slot, _reward in ipairs(rewardsGroup) do
        if table.contains(_receivedRewardsIndex, _slot - 1) then
          local rewardConf = _G.DataConfigManager:GetRewardConf(_reward.reward_id)
          if rewardConf then
            for _, rewardItem in ipairs(rewardConf.RewardItem) do
              local findExists = false
              for _, _cachedItem in ipairs(receivedRewards) do
                if _cachedItem.type == rewardItem.Type and _cachedItem.id == rewardItem.Id then
                  findExists = true
                  _cachedItem.num = _cachedItem.num + rewardItem.Count
                  break
                end
              end
              if not findExists then
                local rewardsItemData = {}
                rewardsItemData.type = rewardItem.Type
                rewardsItemData.id = rewardItem.Id
                rewardsItemData.num = rewardItem.Count
                table.insert(receivedRewards, rewardsItemData)
              end
            end
          end
        end
      end
    end
  end
  if #receivedRewards > 0 then
    _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, receivedRewards, "")
  end
end

function UMG_Activity_SeasonSign_C:OnSvrUpdateActivityData(_cmdId, _activityData, _initUpdate)
  if not _activityData.score_reward_comp_data then
    return
  end
  local activityInst = self.activityInst
  if _activityData.first_open == nil then
    local req = _G.ProtoMessage:newZonePlayerOpenActivityReq()
    req.activity_id = activityInst:GetActivityId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_PLAYER_OPEN_ACTIVITY_REQ, req, self, self.FirstPlayActivityVideoRsp)
  end
end

function UMG_Activity_SeasonSign_C:FirstPlayActivityVideoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local activityInst = self.activityInst
    activityInst.svrActivityData.first_open = false
  end
end

function UMG_Activity_SeasonSign_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshSeasonSignData)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshReceivePetCatchRewards)
  _G.NRCAudioManager:SetStateByName("Story_Movie", "None")
end

function UMG_Activity_SeasonSign_C:OnEnable()
  Base.OnEnable(self)
  local bHasTimeLeft = self.activityInst:GetActivityTimeLeft() ~= math.maxinteger
  self.CanvasPanel_356:SetVisibility(bHasTimeLeft and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  if self.activityInst.svrActivityData and self.activityInst.svrActivityData.first_open == nil then
    self:PlayAnimationByName("In")
  else
    self:PlayAnimationByName("In_2")
  end
end

function UMG_Activity_SeasonSign_C:OnAddEventListener()
end

return UMG_Activity_SeasonSign_C
