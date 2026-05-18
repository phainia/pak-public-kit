local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local UMG_Activity_SeasonPreheating_C = Base:Extend("UMG_Activity_SeasonPreheating_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_SeasonPreheating_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_PREHEAT
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.titleLabelIcon = self.Label
  uiElements.titleLabelText = self.NRCText_61
  uiElements.timeRemainingRoot = self.shijian
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.particularsBtn = self.ParticularsBtn
  local activityInst = self.activityInst
  local finalRewardStatus = activityInst and activityInst:GetFinalRewardStatus()
  if finalRewardStatus == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT or finalRewardStatus == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
    uiElements.openAnimName = "In_2"
    uiElements.changeAnimName = "In_2"
  else
    uiElements.openAnimName = "In"
    uiElements.changeAnimName = "In_3"
  end
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_SeasonPreheating_C:OnConstruct()
  Base.OnConstruct(self)
  local clue1 = {
    root = self.ClueDetails1,
    switcher1 = self.Switcher_1,
    switcher2 = self.Switcher_2,
    UnlockTime = self.UnlockTime,
    redPoint = self.redPointSpecial,
    selectAnim = self.Clew_1_select,
    unselectAnim = self.Clew_1_deselect,
    completeAnim = self.Complete_1
  }
  local clue2 = {
    root = self.ClueDetails2,
    switcher1 = self.Switcher_3,
    switcher2 = self.Switcher_4,
    UnlockTime = self.UnlockTime_1,
    redPoint = self.redPointSpecial_1,
    selectAnim = self.Clew_2_select,
    unselectAnim = self.Clew_2_deselect,
    completeAnim = self.Complete_2
  }
  local clue3 = {
    root = self.ClueDetails3,
    switcher1 = self.Switcher_5,
    switcher2 = self.Switcher_6,
    UnlockTime = self.UnlockTime_2,
    redPoint = self.redPointSpecial_2,
    selectAnim = self.Clew_3_select,
    unselectAnim = self.Clew_3_deselect,
    completeAnim = self.Complete_3
  }
  local clue4 = {
    root = self.ClueDetails4,
    switcher1 = self.Switcher_7,
    switcher2 = self.Switcher_8,
    UnlockTime = self.UnlockTime_3,
    redPoint = self.redPointSpecial_3,
    selectAnim = self.Clew_4_select,
    unselectAnim = self.Clew_4_deselect,
    completeAnim = self.Complete_4
  }
  local clue5 = {
    root = self.ClueDetails5,
    switcher1 = self.Switcher_9,
    switcher2 = self.Switcher_10,
    UnlockTime = self.UnlockTime_4,
    redPoint = self.redPointSpecial_4,
    selectAnim = self.Clew_5_select,
    unselectAnim = self.Clew_5_deselect,
    completeAnim = self.Complete_5
  }
  self.items = {
    clue1,
    clue2,
    clue3,
    clue4,
    clue5
  }
  self:AddButtonListener(self.GoBtn.btnLevelUp, self.OnGoBtnClick)
  self:AddButtonListener(self.ProgressBtn.btnLevelUp, self.OnProgressBtnClick)
  self:AddButtonListener(self.ClaimRewardBtn.btnLevelUp, self.OnProgressBtnClick)
  self:AddButtonListener(self.ClaimRewardBtn2.btnLevelUp, self.OnClaimRewardBtnClick)
  self:AddButtonListener(self.ClueDetails1, self.OnClickRule_1)
  self:AddButtonListener(self.ClueDetails2, self.OnClickRule_2)
  self:AddButtonListener(self.ClueDetails3, self.OnClickRule_3)
  self:AddButtonListener(self.ClueDetails4, self.OnClickRule_4)
  self:AddButtonListener(self.ClueDetails5, self.OnClickRule_5)
  self:AddButtonListener(self.SwitchBtn.btnLevelUp, self.OnSwitchNewspaper)
  self:RegisterEvent(self, ActivityModuleEvent.PreHeatActivity_PreUnLockTaskStatusChanged, self.OnPreUnLockTaskStatusChanged)
  self:RegisterEvent(self, ActivityModuleEvent.PreHeatActivity_CollectItemStatusChanged, self.OnCollectItemStatusChanged)
  self:RegisterEvent(self, ActivityModuleEvent.PreHeatActivity_FinalRewardStatusChanged, self.OnFinalRewardStatusChanged)
  local activityInst = self.activityInst
  local preHeatCfg = activityInst:GetPreHeatCfg()
  self:InitNewspaper(preHeatCfg)
  for i, item in ipairs(self.items) do
    local itemObject = activityInst:GetCollectItemObject(i)
    if itemObject then
      self:IniCollectItem(item, itemObject)
    elseif item.root then
      item.root:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local rewards = {}
  if preHeatCfg and preHeatCfg.reward_id then
    local rewardItem = {}
    rewardItem.itemType = _G.Enum.GoodsType.GT_REWARD
    rewardItem.itemId = preHeatCfg.reward_id
    rewardItem.itemNum = 1
    rewardItem.bShowTip = true
    table.insert(rewards, rewardItem)
  end
  self.AwardList:InitList(rewards)
  self.PublicationDescription:SetText(preHeatCfg and preHeatCfg.final_task_title or "")
  self.ClaimRewardBtn:SetRedDotExtraKey(448, {
    activityInst:GetActivityId()
  })
  self.ClaimRewardBtn2:SetRedDotExtraKey(ActivityEnum.RedPointKey.DetailReward, {
    activityInst:GetActivityId()
  })
  self.ClaimRewardBtn2:SetShowOrHideTitleCanvas(false)
  self.Collected:SetShowLockIcon(false)
  self:OnPreUnLockTaskStatusChanged(activityInst)
end

function UMG_Activity_SeasonPreheating_C:OnDestruct()
  Base.OnDestruct(self)
  self:UnRegisterEvent(self, ActivityModuleEvent.PreHeatActivity_PreUnLockTaskStatusChanged)
  self:UnRegisterEvent(self, ActivityModuleEvent.PreHeatActivity_CollectItemStatusChanged)
end

function UMG_Activity_SeasonPreheating_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  local activityInst = self.activityInst
  if activityInst then
    activityInst:QueryPreUnLockTaskStatus()
  end
end

function UMG_Activity_SeasonPreheating_C:OnAnimationStarted(anim)
  Base.OnAnimationStarted(self, anim)
  if anim == self.In then
    local activityInst = self.activityInst
    if activityInst then
      local isUnlock = activityInst:GetPreUnLockTaskData()
      if self.heimu then
        self.heimu:SetVisibility(isUnlock and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
      end
    end
  elseif anim == self.In_2 then
    _G.NRCAudioManager:PlaySound2DAuto(40008032, "UMG_Activity_SeasonPreheating_C:BindUIElements")
  end
end

function UMG_Activity_SeasonPreheating_C:IniCollectItem(item, itemObject)
  item.itemObject = itemObject
  local countDownObject = itemObject:GetUnLockCountDown()
  if countDownObject then
    countDownObject:BindCtrl(item.UnlockTime, function(leftSeconds)
      if leftSeconds > 0 then
        if leftSeconds >= 86400 then
          return string.format(_G.LuaText.activity_preheat__unlock_time_daytips, math.floor(leftSeconds / 86400))
        elseif leftSeconds >= 3600 then
          return string.format(_G.LuaText.activity_preheat__unlock_time_hourtips, math.floor(leftSeconds / 3600))
        else
          return string.format(_G.LuaText.activity_preheat__unlock_time_mintips, math.ceil(leftSeconds / 60))
        end
      end
    end)
  end
  if item.redPoint then
    local key, extraKey = itemObject:GetRedpointData()
    if key then
      item.redPoint:SetupKey(key, extraKey)
    end
  end
  self:RefreshCollectItem(item, true)
end

function UMG_Activity_SeasonPreheating_C:RefreshCollectItem(item, initFlag)
  local itemObject = item and item.itemObject
  if not itemObject then
    return
  end
  local cfg = itemObject:GetCfg()
  if item.unlockImage then
    item.unlockImage:SetPath(cfg and cfg.unlock_picture or "")
  end
  if item.showImage then
    item.showImage:SetPath(cfg and cfg.show_picture or "")
  end
  local activityInst = itemObject:GetOwner()
  if activityInst then
    local isPreUnlock = activityInst:GetPreUnLockTaskData()
    if isPreUnlock then
      if item.root then
        item.root:SetVisibility(UE4.ESlateVisibility.Visible)
      end
      local itemStatus = itemObject:GetStatus()
      if itemStatus == ActivityEnum.ItemStatus.UnLocked or itemStatus == ActivityEnum.ItemStatus.Available then
        if item.switcher1 then
          item.switcher1:SetActiveWidgetIndex(0)
        end
        if item.switcher2 then
          item.switcher2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          item.switcher2:SetActiveWidgetIndex(1)
        end
      elseif itemStatus == ActivityEnum.ItemStatus.Finished then
        if item.switcher1 then
          item.switcher1:SetActiveWidgetIndex(1)
        end
        if item.switcher2 then
          item.switcher2:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
        if not initFlag then
          self:PlayAnimation(item.completeAnim)
        end
      else
        if item.switcher1 then
          item.switcher1:SetActiveWidgetIndex(0)
        end
        if item.switcher2 then
          item.switcher2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          item.switcher2:SetActiveWidgetIndex(0)
        end
      end
    elseif item.root then
      item.root:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Activity_SeasonPreheating_C:OnClickCollectItem(index)
  if self:IsAnimationPlaying(self.In) or self:IsAnimationPlaying(self.In_2) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_SeasonPreheating_C:OnClickCollectItem")
  local activityInst = self.activityInst
  if activityInst then
    local isUnlock = activityInst:GetPreUnLockTaskData()
    if not isUnlock then
      return
    end
    local item = self.items and self.items[index]
    if item and item.itemObject then
      item.itemObject:OnClick()
      self:PlayAnimation(item.selectAnim)
    end
    local selectItem = self.selectItem
    self.selectItem = item
    if selectItem then
      self:PlayAnimation(selectItem.unselectAnim)
    end
  end
end

function UMG_Activity_SeasonPreheating_C:RefreshCollectRuleProgress()
  local activityInst = self.activityInst
  if activityInst then
    local preHeatCfg = activityInst:GetPreHeatCfg()
    local itemFinishedCount, itemTotalCount = activityInst:GetCollectItemFinishedCount()
    local progressText = string.safeFormat("%s :%d/%d", preHeatCfg and preHeatCfg.final_task_text, itemFinishedCount, itemTotalCount)
    self.ProgressBtn:SetTitleTextAndIcon(nil, nil, nil, nil, progressText)
    self.ClaimRewardBtn:SetTitleTextAndIcon(nil, nil, nil, nil, progressText)
    if itemFinishedCount == itemTotalCount then
      self:OnFinalRewardStatusChanged(activityInst)
    end
  end
end

function UMG_Activity_SeasonPreheating_C:InitNewspaper(cfg)
  if self.Text_Title_1 then
    self.Text_Title_1:SetText(string.safeFormat(_G.LuaText.activity_preheat_paper_trailer, _G.DataModelMgr.PlayerDataModel:GetPlayerName()))
  end
  if self.TitleText_1 then
    self.TitleText_1:SetText(cfg and cfg.newspaper_txt_title_1 or "")
  end
  if self.ClueText_1 then
    self.ClueText_1:SetText(cfg and cfg.newspaper_txt_1 or "")
  end
  if self.TitleText_2 then
    self.TitleText_2:SetText(cfg and cfg.newspaper_txt_title_2 or "")
  end
  if self.ClueText_2 then
    self.ClueText_2:SetText(cfg and cfg.newspaper_txt_2 or "")
  end
  if self.TitleText_3 then
    self.TitleText_3:SetText(cfg and cfg.newspaper_txt_title_3 or "")
  end
  if self.ClueText_3 then
    self.ClueText_3:SetText(cfg and cfg.newspaper_txt_3 or "")
  end
  if self.TitleText_4 then
    self.TitleText_4:SetText(cfg and cfg.newspaper_txt_title_4 or "")
  end
  if self.ClueText_4 then
    self.ClueText_4:SetText(cfg and cfg.newspaper_txt_4 or "")
  end
  if self.TitleText_5 then
    self.TitleText_5:SetText(cfg and cfg.newspaper_txt_title_5 or "")
  end
  if self.ClueText_5 then
    self.ClueText_5:SetText(cfg and cfg.newspaper_txt_5 or "")
  end
end

function UMG_Activity_SeasonPreheating_C:OnSwitchNewspaper()
  _G.NRCAudioManager:PlaySound2DAuto(1220002026, "UMG_Activity_SeasonPreheating_C:OnSwitchNewspaper")
  local activeIndex = self.NRCSwitcher_134:GetActiveWidgetIndex()
  if 0 == activeIndex then
    self.NRCSwitcher_134:SetActiveWidgetIndex(1)
    self:PlayAnimation(self.TurnOver)
  else
    self.NRCSwitcher_134:SetActiveWidgetIndex(0)
    self:PlayAnimation(self.TurnOver_Back)
  end
end

function UMG_Activity_SeasonPreheating_C:OnGoBtnClick()
  local activityInst = self.activityInst
  if activityInst then
    activityInst:TrackPreUnLockTask()
  end
end

function UMG_Activity_SeasonPreheating_C:OnProgressBtnClick()
  local activityInst = self.activityInst
  if activityInst then
    local itemFinishedCount, itemTotalCount = activityInst:GetCollectItemFinishedCount()
    if itemFinishedCount < itemTotalCount then
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.activity_preheat_track_tips)
    else
      local preHeatCfg = activityInst:GetPreHeatCfg()
      if preHeatCfg and preHeatCfg.final_task_id then
        ActivityUtils.TraceTaskParagraph(preHeatCfg.final_task_id)
      end
    end
  end
end

function UMG_Activity_SeasonPreheating_C:OnClaimRewardBtnClick()
  local activityInst = self.activityInst
  if activityInst then
    activityInst:SendZoneActivityPreHeatRewardReq()
  end
end

function UMG_Activity_SeasonPreheating_C:OnClickRule_1()
  self:OnClickCollectItem(1)
end

function UMG_Activity_SeasonPreheating_C:OnClickRule_2()
  self:OnClickCollectItem(2)
end

function UMG_Activity_SeasonPreheating_C:OnClickRule_3()
  self:OnClickCollectItem(3)
end

function UMG_Activity_SeasonPreheating_C:OnClickRule_4()
  self:OnClickCollectItem(4)
end

function UMG_Activity_SeasonPreheating_C:OnClickRule_5()
  self:OnClickCollectItem(5)
end

function UMG_Activity_SeasonPreheating_C:OnPreUnLockTaskStatusChanged(_activityInst)
  if _activityInst and self.activityInst == _activityInst then
    local isUnlock, btnText = _activityInst:GetPreUnLockTaskData()
    if isUnlock then
      self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshCollectRuleProgress()
      self:OnFinalRewardStatusChanged(_activityInst)
    else
      self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.BtnSwitcher:SetActiveWidgetIndex(0)
      self.Switcher:SetActiveWidgetIndex(0)
      self.GoBtn:SetBtnText(btnText)
    end
    for _, item in ipairs(self.items) do
      self:RefreshCollectItem(item)
    end
  end
end

function UMG_Activity_SeasonPreheating_C:OnCollectItemStatusChanged(_activityInst, _itemObject)
  if _activityInst and self.activityInst == _activityInst and _itemObject then
    local slot = _itemObject:GetSlot()
    local item = slot and self.items[slot]
    if item then
      self:RefreshCollectItem(item)
    end
    if _itemObject:GetStatus() == ActivityEnum.ItemStatus.Finished then
      self:RefreshCollectRuleProgress()
    end
  end
end

function UMG_Activity_SeasonPreheating_C:OnFinalRewardStatusChanged(_activityInst)
  if _activityInst and self.activityInst == _activityInst then
    local finalRewardStatus = _activityInst:GetFinalRewardStatus()
    if finalRewardStatus == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
      self.BtnSwitcher:SetActiveWidgetIndex(4)
      self.Switcher:SetActiveWidgetIndex(1)
      self:PlayAnimation(self.Available, 0, 0)
    elseif finalRewardStatus == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      self.BtnSwitcher:SetActiveWidgetIndex(3)
      self.Switcher:SetActiveWidgetIndex(1)
      self:StopAnimation(self.Available)
      self:PlayAnimation(self.Get)
    else
      self:StopAnimation(self.Available)
      local itemFinishedCount, itemTotalCount = _activityInst:GetCollectItemFinishedCount()
      if itemFinishedCount < itemTotalCount then
        self.BtnSwitcher:SetActiveWidgetIndex(1)
      else
        self.BtnSwitcher:SetActiveWidgetIndex(2)
      end
      self.Switcher:SetActiveWidgetIndex(0)
    end
  end
end

return UMG_Activity_SeasonPreheating_C
