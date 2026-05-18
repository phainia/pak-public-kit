local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ClearanceReward_Item_C = Base:Extend("UMG_ClearanceReward_Item_C")

function UMG_ClearanceReward_Item_C:OnConstruct()
end

function UMG_ClearanceReward_Item_C:OnDestruct()
end

function UMG_ClearanceReward_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.challenge_data = nil
  self.ActivityType = nil
  self.ActivityId = nil
  self.RewardList = nil
  self:SetInfo()
  self.ViewBtn.btnLevelUp.OnClicked:Add(self, self.OnReceiveAward)
end

function UMG_ClearanceReward_Item_C:SetParent(parent)
  self.parent = parent
end

function UMG_ClearanceReward_Item_C:SetInfo()
  local bShouldAlignToLeft = false
  if not self.data.bIsTakingPhoto then
    local padding = UE4.UWidgetLayoutLibrary.SlotAsWidgetSwitcherSlot(self.NRCScrollView_79).Padding
    local defaultPadding = padding
    defaultPadding.Left = 0.0
    defaultPadding.Top = -2.0
    defaultPadding.Right = 0.0
    defaultPadding.Bottom = 0.0
    UE4.UWidgetLayoutLibrary.SlotAsWidgetSwitcherSlot(self.NRCScrollView_79):SetPadding(defaultPadding)
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    local RewardList = {}
    local RewardConf = _G.DataConfigManager:GetRewardConf(self.data.reward_id)
    if RewardConf and RewardConf.RewardItem then
      for i, reward in ipairs(RewardConf.RewardItem) do
        local rewards = _G.NRCCommonItemIconData()
        rewards.itemType = reward.Type
        rewards.itemId = reward.Id
        rewards.itemNum = reward.Count
        rewards.bShowNum = true
        rewards.bShowTip = true
        rewards.bShowGetTag = self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE or self.data.is_finish
        table.insert(RewardList, rewards)
      end
    end
    if #RewardList > 3 then
      self.NRCScrollView_79:InitList(RewardList)
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    else
      local size = 3 - #RewardList
      local tempList = {}
      for i = 1, size do
        local emptyItem = {}
        emptyItem.itemId = 0
        table.insert(tempList, emptyItem)
      end
      for i = 1, #RewardList do
        table.insert(tempList, RewardList[i])
      end
      self.NRCSwitcher_0:SetActiveWidgetIndex(2)
      self.NRCGridView_52:InitGridView(tempList)
      for i = 1, size do
        local item = self.NRCGridView_52:GetItemByIndex(i - 1)
        if item then
          item:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      end
    end
    self.RewardList = RewardList
    bShouldAlignToLeft = #RewardList < 3 and #RewardList > 0
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  end
  self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local data = self.data
  if data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE and not self.data.bIsTakingPhoto then
    self.Switcher:SetActiveWidgetIndex(2)
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Get)
  elseif data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT or data.finishedStarNum >= data.star_required_num then
    self.Switcher:SetActiveWidgetIndex(0)
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.data.bIsTakingPhoto then
      self.ViewBtn.Title_1:SetText(_G.LuaText.weekly_challenge_text_21)
    end
  elseif data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
    self.Switcher:SetActiveWidgetIndex(1)
  elseif data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNOPEN then
    self.Switcher:SetActiveWidgetIndex(3)
    local worldLevelConf = _G.DataConfigManager:GetWorldLevelConf(data.difficultyRequire + 1, true)
    if worldLevelConf then
      self.Quantity:SetText(string.format(_G.LuaText.weekly_challenge_text_29, worldLevelConf.title))
    end
  end
  self.Quantity_1:SetText(string.format("%d/%d", data.finishedStarNum, data.star_required_num))
  self.Text_Content:SetText(string.format(_G.LuaText.weekly_challenge_text_22, data.star_required_num))
  self.Text_Content_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCText:SetText(string.format("x%s", data.difficultyRequire))
  if bShouldAlignToLeft then
    _G.NRCViewBase:DelayFrames(1, function()
    end)
  end
end

function UMG_ClearanceReward_Item_C:UpdateReceiveAwardState(reward)
  self.data = reward
  if self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE and not self.data.bIsTakingPhoto then
    self.Switcher:SetActiveWidgetIndex(2)
    self:PlayAnimation(self.Get)
  elseif self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT or self.data.finishedStarNum >= self.data.star_required_num then
    self.Switcher:SetActiveWidgetIndex(0)
  elseif self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNFINISH then
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_ClearanceReward_Item_C:OnItemSelected(_bSelected)
end

function UMG_ClearanceReward_Item_C:OnDeactive()
end

function UMG_ClearanceReward_Item_C:OnReceiveAward()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_ClearanceReward_Item_C:OnReceiveAward")
  local WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if not WeeklyChallengeEventActivityObject or not WeeklyChallengeEventActivityObject[1] then
    Log.Error("UMG_ClearanceReward_Item_C:OnReceiveAward \232\142\183\229\143\150\230\180\187\229\138\168Object\229\164\177\232\180\165")
    return
  end
  local activityId = WeeklyChallengeEventActivityObject[1]:GetActivityId()
  if not self.data.bIsTakingPhoto then
    _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.SendReceiveRewardReq, activityId, self.data.star_required_num, self.RewardList, ProtoEnum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  else
    _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.OpenCurtainPopup, self, self.OnGoToTakingPhoto)
    if self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
      _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.SendReceiveRewardReq, activityId, self.data.star_required_num, self.RewardList, ProtoEnum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
    end
  end
end

function UMG_ClearanceReward_Item_C:OnGoToTakingPhoto()
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GoTakePhoto)
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.CloseCurtainPopup)
end

function UMG_ClearanceReward_Item_C:CheckIfScrollable()
  local bCanScroll = false
  local switcherHorizontalSize = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.NRCSwitcher_0):GetSize().x
  local padding = UE4.UWidgetLayoutLibrary.SlotAsWidgetSwitcherSlot(self.NRCScrollView_79).Padding
  local defaultPadding = padding
  defaultPadding.Left = 0.0
  defaultPadding.Top = -2.0
  defaultPadding.Right = 0.0
  defaultPadding.Bottom = 0.0
  local scrollBoxWidth = switcherHorizontalSize - defaultPadding.Left - defaultPadding.Right
  local TotalContentWidth = 0.0
  for i = 0, self.NRCScrollView_79:GetItemCount() - 1 do
    local item = self.NRCScrollView_79:GetItemByIndex(i)
    if item then
      TotalContentWidth = item:GetDesiredSize().X + TotalContentWidth
    end
  end
  bCanScroll = scrollBoxWidth < TotalContentWidth
  if bCanScroll then
    self.NRCScrollView_79:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRCScrollView_79:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.NRCScrollView_79.GetSubCanvasPanel then
      self.NRCScrollView_79:GetSubCanvasPanel():SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    padding.Left = scrollBoxWidth - TotalContentWidth
    UE4.UWidgetLayoutLibrary.SlotAsWidgetSwitcherSlot(self.NRCScrollView_79):SetPadding(padding)
  end
end

return UMG_ClearanceReward_Item_C
