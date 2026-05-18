local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_PetCatch_C = Base:Extend("UMG_Activity_PetCatch_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_PetCatch_C:OnConstruct()
  Base.OnConstruct(self)
  self.Text_Title:SetText(self.activityInst:GetActivityName())
  self.Text_Describe:SetText(self.activityInst:GetActivityPromptText())
  self:OnRefreshPetCatchPoints(self.activityInst, false)
  self:OnRefreshPetCatchTaskState(self.activityInst)
  do
    local rewardsTable = {}
    local rewardsGroup = self.activityInst:GetPreviewRewards()
    if rewardsGroup then
      for _, _reward in ipairs(rewardsGroup) do
        local itemData = {}
        itemData.itemType = _reward.preview_reward_type
        itemData.itemId = _reward.preview_reward_param
        itemData.itemNum = _reward.preview_reward_count
        itemData.bShowNum = true
        itemData.bShowTip = true
        table.insert(rewardsTable, itemData)
      end
    end
    ActivityUtils.AdjustCtrlAutoSize(self.AwardList, #rewardsTable <= 4)
    ActivityUtils.AdjustCtrlSize(self.BG, {
      175,
      326,
      477,
      627,
      702
    }, #rewardsTable)
    self.AwardList:InitList(rewardsTable)
  end
  local activityId = self.activityInst:GetActivityId()
  self.redPointReward:EnableAnimation()
  self.redPointReward:SetupKey(ActivityEnum.RedPointKey.DetailReward, {activityId})
  self.Btn_Claimable:SetRedDotExtraKey(247, {activityId})
  self.NotUnlocked:SetTitleTextColor("#c7494aFF")
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnClickTaskGuid)
  self:AddButtonListener(self.Btn_integral, self.OnClickOpenScorePanel)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPetCatchTaskState, self.OnRefreshPetCatchTaskState)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPetCatchPoints, self.OnRefreshPetCatchPoints)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshReceivePetCatchRewards, self.OnRefreshReceivePetCatchRewards)
end

function UMG_Activity_PetCatch_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshPetCatchTaskState)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshPetCatchPoints)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshReceivePetCatchRewards)
end

function UMG_Activity_PetCatch_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_PetCatch_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self.activityInst:SendZoneTaskQueryReq(self.activityInst:GetTaskList())
  local preTaskId = self.activityInst:GetPreTaskId()
  if preTaskId then
    self.activityInst:SendZoneTaskQueryReq({preTaskId})
  end
end

function UMG_Activity_PetCatch_C:OnClickTaskGuid()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_Activity_PetCatch_C:OnClickTaskGuid")
  local preTaskId = self.activityInst:GetPreTaskId()
  if preTaskId then
    _G.NRCPanelManager:CloseAllPanelByLayer(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnClickTaskTrackToWorldFast)
    _G.NRCModeManager:DoCmd(_G.TaskModuleCmd.OnSetTraceTaskInfo, preTaskId, true)
  else
    Log.Debug("UMG_Activity_PetCatch_C:OnClickTaskGuid() -- not found preTaskId")
  end
end

function UMG_Activity_PetCatch_C:OnClickOpenScorePanel()
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenPetCatchReward, self.activityInst)
end

function UMG_Activity_PetCatch_C:OnRefreshPetCatchTaskState(_activityInst)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  if not _activityInst:HasAcceptedTask() then
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self.NotUnlocked:SetTitleTextAndIcon(nil, nil, nil, nil, self.activityInst:GetActivityBanText())
    self.NotUnlocked:SetBtnText(_G.LuaText.Role_Award_Look_Last_Tips)
    self.PointsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif _activityInst:IsInProgress() then
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    self.PointsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BtnSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if _activityInst:GetSvrStatus() == ActivityEnum.ActivitySvrStatus.Available then
      self.BtnSwitcher:SetActiveWidgetIndex(0)
      self.Btn_Claimable:SetBtnText(_G.LuaText.activity_button_tips_previous_task)
    else
      self.BtnSwitcher:SetActiveWidgetIndex(1)
      self.NotUnlocked:SetTitleTextAndIcon()
      self.NotUnlocked:SetBtnText(_G.LuaText.Role_Award_Look_Last_Tips)
    end
    self.PointsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_PetCatch_C:OnRefreshPetCatchPoints(_activityInst, _userOperation)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  self.Text_quantity:SetText(_activityInst:GetPoints() .. "/" .. _activityInst:GetPointsMax())
end

function UMG_Activity_PetCatch_C:OnRefreshReceivePetCatchRewards(_activityInst, _receivedRewardsIndex, _userOperation, _protoData)
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

return UMG_Activity_PetCatch_C
