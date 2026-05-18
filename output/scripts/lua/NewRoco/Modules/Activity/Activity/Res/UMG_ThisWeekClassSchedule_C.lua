local UMG_ThisWeekClassSchedule_C = _G.NRCPanelBase:Extend("UMG_ThisWeekClassSchedule_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")

function UMG_ThisWeekClassSchedule_C:OnConstruct()
  self:AddButtonListener(self.FullScreen_Close, self.OnClickClose)
  self:AddButtonListener(self.DailyKnowBtn.btnLevelUp, self.OnClickDailyKnowBtn)
  self:AddButtonListener(self.ClaimBtn_1, self.OnClickClaimBtn_1)
  self.ClaimBtn_1.OnPressed:Add(self, self.OnClaimBtn1Pressed)
  self.ClaimBtn_1.OnReleased:Add(self, self.OnClaimBtn1Released)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivitySvrDataChanged, self.OnMixActivitySvrDataChanged)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivitySelectFactionChanged, self.OnMixActivitySelectFactionChanged)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleProgressChange, self.OnMixActivityClassScheduleProgressChange)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleStatusChange, self.OnMixActivityClassScheduleStatusChange)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleTaskChange, self.OnMixActivityClassScheduleTaskChange)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnProgressVItemChanged)
  self.CourseScheduleTitle:SetText(_G.LuaText.Activity_CollegeGlory_schedule_title)
  self.ThisWeekClassSchedule_Item2:SetClickCallback(_G.MakeWeakFunctor(self, self.OnClickGetTheLastProgressReward), _G.MakeWeakFunctor(self, self.OnTheLastProgressRewardPressed), _G.MakeWeakFunctor(self, self.OnTheLastProgressRewardReleased))
end

function UMG_ThisWeekClassSchedule_C:OnDestruct()
  self.ClaimBtn_1.OnPressed:Clear()
  self.ClaimBtn_1.OnReleased:Clear()
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivitySvrDataChanged)
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivitySelectFactionChanged)
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleProgressChange)
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleStatusChange)
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivityClassScheduleTaskChange)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnProgressVItemChanged)
  local activityInst = self.activityInst
  if activityInst then
    local classScheduleCountDownObject = activityInst:GetClassScheduleCountDownObject()
    if classScheduleCountDownObject then
      classScheduleCountDownObject:UnbindCtrl(self.UpdateTime)
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnActive(activityInst)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_ThisWeekClassSchedule_C:OnActive")
  self.activityInst = activityInst
  activityInst:ReqGetPlayerActivityData()
  local mixData = activityInst:GetMixData()
  self.remainRefreshTimes = mixData and mixData.remain_refresh_times or 0
  local mixCfg = activityInst:GetMixConf()
  self.NRCText_0:SetText(mixCfg and mixCfg.progress_title or "")
  self.NRCText_1:SetText(mixCfg and mixCfg.progress_vitem_name or "")
  local classScheduleCountDownObject = activityInst:GetClassScheduleCountDownObject()
  if classScheduleCountDownObject then
    classScheduleCountDownObject:BindCtrl(self.UpdateTime, function(leftSeconds)
      if leftSeconds > 0 then
        local timeStr = ActivityUtils.GetTimeFormatStr(leftSeconds)
        return string.format(_G.LuaText.Activity_CollegeGlory_schedule_RefreshRule_txt1, timeStr)
      end
    end, nil, self.OnUpdateTimeTick, self)
  end
  local vItemId = activityInst:GetProgressVItemData()
  self.CurrencyIcon:SetPath(ActivityUtils.GetItemIconAndQuality(_G.Enum.GoodsType.GT_VITEM, vItemId))
  self:OnMixActivitySelectFactionChanged(activityInst)
  self:RefreshData()
end

function UMG_ThisWeekClassSchedule_C:RefreshData()
  local activityInst = self.activityInst
  if not activityInst then
    return
  end
  local mixData = activityInst:GetMixData()
  local oldRemainRefreshTimes = self.remainRefreshTimes or 0
  local remainRefreshTimes = mixData and mixData.remain_refresh_times or 0
  self.remainRefreshTimes = remainRefreshTimes
  self.RemainingRefresh:SetText(string.format(_G.LuaText.Activity_CollegeGlory_schedule_RefreshRule_txt2, remainRefreshTimes))
  if oldRemainRefreshTimes ~= remainRefreshTimes and (oldRemainRefreshTimes <= 0 or remainRefreshTimes <= 0) then
    for i = 1, self.List:GetItemCount() do
      self.List:OpItemByIndex(i, ActivityEnum.ItemOpType.RefreshPartData1)
    end
  end
  self:RefreshTotalRewardProgress()
end

function UMG_ThisWeekClassSchedule_C:RefreshLastProgress(status)
  if status == ActivityEnum.RewardStatus.Received then
    self.Completed:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.ThisWeekClassSchedule_Item2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#8D8D8DFF"))
  else
    self.Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ThisWeekClassSchedule_Item2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFFFF"))
  end
  if status == ActivityEnum.RewardStatus.Available then
    self.ThisWeekClassSchedule_Item2:SetBgColor("#FFC755FF")
  else
    self.ThisWeekClassSchedule_Item2:SetBgColor("#FFFFFFFF")
  end
end

function UMG_ThisWeekClassSchedule_C:OnUpdateTimeTick(_ctrl, _leftTimeStr)
  if _ctrl == self.UpdateTime then
    self.UpdateTime:SetVisibility(not string.IsNilOrEmpty(_leftTimeStr) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ThisWeekClassSchedule_C:RefreshTotalRewardProgress()
  local activityInst = self.activityInst
  if activityInst then
    local _, vItemCnt = activityInst:GetProgressVItemData()
    if vItemCnt == self.vItemCnt then
      return
    end
    self.vItemCnt = vItemCnt
    if vItemCnt > 99999 then
      self.QuantityText:SetText("99999+")
    else
      self.QuantityText:SetText(tostring(vItemCnt))
    end
    do
      local segCnt = #self.progressItems
      local curSeg = 0
      for index, progressData in ipairs(self.progressItems) do
        if vItemCnt >= progressData.score then
          curSeg = index
        else
          break
        end
      end
      if segCnt > curSeg then
        local firstSegPercent = 0.142
        local lastSegPercent = 0.225
        local otherSegPercent = (1.0 - firstSegPercent - lastSegPercent) / (segCnt - 2)
        local firstPercent = firstSegPercent * math.min(1, vItemCnt / self.progressItems[1].score)
        local otherPercent = 0
        local lastPercent = 0
        if curSeg >= segCnt - 1 then
          otherPercent = otherSegPercent * (segCnt - 2)
          local curSegScore = self.progressItems[segCnt - 1].score
          local nextSegScore = self.progressItems[segCnt].score
          lastPercent = lastSegPercent * ((vItemCnt - curSegScore) / (nextSegScore - curSegScore))
        elseif curSeg >= 1 then
          local curSegScore = self.progressItems[curSeg].score
          local nextSegScore = self.progressItems[curSeg + 1].score
          otherPercent = otherSegPercent * (curSeg - 1) + otherSegPercent * ((math.min(vItemCnt, nextSegScore) - curSegScore) / (nextSegScore - curSegScore))
        end
        self.JinduProgressBar:SetPercent(firstPercent + otherPercent + lastPercent)
      else
        self.JinduProgressBar:SetPercent(1)
      end
    end
    local progressTaskQuery = activityInst:GetProgressTaskRewardQuery()
    if progressTaskQuery then
      progressTaskQuery:QueryTaskStatus(self, self.OnProgressRewardChanged)
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnClickDailyKnowBtn()
  local activityInst = self.activityInst
  local factionConf = activityInst and activityInst:GetFactionConf()
  if factionConf then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    Context:SetTitle(_G.LuaText.Activity_CollegeGlory_WeekRule_TipsTitle):SetContent(factionConf.rule_txt):SetContentTextJustify(UE4.ETextJustify.Left):SetMode(DialogContext.Mode.NotBtn):SetClickAnywhereClose(true)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
  else
    Log.Error("UMG_ThisWeekClassSchedule_C:OnClickDailyKnowBtn: factionConf is nil")
  end
end

function UMG_ThisWeekClassSchedule_C:OnClickClaimBtn_1(index)
  local activityInst = self.activityInst
  if activityInst then
    local vItemId = activityInst:GetProgressVItemData()
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, vItemId, Enum.GoodsType.GT_VITEM, false)
  end
end

function UMG_ThisWeekClassSchedule_C:OnClickGetTheLastProgressReward()
  local progressItems = self.progressItems
  if progressItems then
    local progressData = progressItems[#progressItems]
    if progressData and not self:OnClickGetProgressReward(#progressItems) then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, progressData.itemId, progressData.itemType, false)
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnClickGetProgressReward(index)
  local activityInst = self.activityInst
  local progressItems = self.progressItems
  local progressData = progressItems and progressItems[index]
  if progressData and progressData.itemStatus == ActivityEnum.RewardStatus.Available then
    local progressTaskQuery = activityInst and activityInst:GetProgressTaskRewardQuery()
    if progressTaskQuery then
      progressTaskQuery:RequestGetTaskReward(progressData.customData, true, self, self.OnProgressRewardChanged)
      return true
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnClickClose()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_ThisWeekClassSchedule_C:OnActive")
  self:OnClose()
end

function UMG_ThisWeekClassSchedule_C:OnPcClose()
  self:OnClickClose()
end

function UMG_ThisWeekClassSchedule_C:OnClaimBtn1Pressed()
  self:PlayPressedOrReleasedAnimation(true, self.Press_1, self.Up_1)
end

function UMG_ThisWeekClassSchedule_C:OnClaimBtn1Released()
  self:PlayPressedOrReleasedAnimation(false, self.Press_1, self.Up_1)
end

function UMG_ThisWeekClassSchedule_C:OnTheLastProgressRewardPressed()
  self:PlayPressedOrReleasedAnimation(true, self.Press_3, self.Up_3)
end

function UMG_ThisWeekClassSchedule_C:OnTheLastProgressRewardReleased()
  self:PlayPressedOrReleasedAnimation(false, self.Press_3, self.Up_3)
end

function UMG_ThisWeekClassSchedule_C:OnProgressVItemChanged()
  self:RefreshTotalRewardProgress()
end

function UMG_ThisWeekClassSchedule_C:OnProgressRewardChanged()
  local progressItems = self.progressItems
  local activityInst = self.activityInst
  if activityInst and progressItems then
    for index, progressData in ipairs(progressItems) do
      local oldItemStatus = progressData.itemStatus
      if oldItemStatus ~= ActivityEnum.RewardStatus.Received then
        progressData.itemStatus = activityInst:GetProgressTaskRewardStatus(progressData.customData)
        if progressData.itemStatus ~= oldItemStatus then
          self.List_1:OpItemByIndex(index, ActivityEnum.ItemOpType.RewardStatusChange, progressData.itemStatus)
          if index == #progressItems then
            self:RefreshLastProgress(progressData.itemStatus)
          end
        end
      end
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnMixActivitySvrDataChanged(_activityInst)
  if _activityInst and _activityInst == self.activityInst then
    self:RefreshData()
  end
end

function UMG_ThisWeekClassSchedule_C:OnMixActivitySelectFactionChanged(activityInst)
  if activityInst and activityInst == self.activityInst then
    self.List:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, activityInst:GetClassScheduleItems()))
    local progressItems = {}
    self.progressItems = progressItems
    local lastProgressData
    local selectFactionConf = activityInst:GetSelectFactionConf()
    if selectFactionConf then
      local activityId = activityInst:GetActivityId()
      for index, taskId in ipairs(selectFactionConf.progress_reward_task_id or {}) do
        local taskConf = _G.DataConfigManager:GetTaskConf(taskId)
        if taskConf then
          local rewardData = ActivityUtils.GetActivityRewardData(taskConf.Reward, true)
          local progressData = {}
          progressData.itemStatus = activityInst:GetProgressTaskRewardStatus(taskId)
          progressData.redPointKey = 455
          progressData.redPointExtraKey = {activityId, taskId}
          progressData.itemType = rewardData.itemType
          progressData.itemId = rewardData.itemId
          progressData.itemIcon = rewardData.showIcon
          progressData.itemNum = rewardData.itemNum
          progressData.itemQuality = rewardData.itemQuality
          progressData.itemName = rewardData.itemName
          progressData.showTips = true
          progressData.score = 0
          if taskConf.task_condition and #taskConf.task_condition > 0 then
            local taskConditionCnt = taskConf.task_condition[1].count
            if taskConditionCnt and taskConditionCnt > 0 then
              progressData.score = taskConditionCnt
            end
          end
          progressData.clickCallback = _G.MakeWeakFunctor(self, self.OnClickGetProgressReward, index)
          progressData.customData = taskId
          table.insert(progressItems, progressData)
          lastProgressData = progressData
        end
      end
    end
    self.ThisWeekClassSchedule_Item2:SetName(lastProgressData and lastProgressData.itemName or "")
    self.ThisWeekClassSchedule_Item2:SetQuantityText(lastProgressData and lastProgressData.score or 0)
    self.ThisWeekClassSchedule_Item2:SetIcon(lastProgressData and lastProgressData.itemIcon or "")
    if lastProgressData then
      self.redPointNew:SetupKey(lastProgressData.redPointKey, lastProgressData.redPointExtraKey)
    end
    self:RefreshLastProgress(lastProgressData and lastProgressData.itemStatus)
    if #progressItems > 0 then
      table.remove(progressItems, #progressItems)
    end
    self.List_1:InitGridView(progressItems)
    if lastProgressData then
      table.insert(progressItems, lastProgressData)
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnMixActivityClassScheduleProgressChange(_activityInst, _itemObj)
  if _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetScheduleItemIndexByObj(_itemObj)
    self.List:OpItemByIndex(itemIndex, ActivityEnum.ItemOpType.ProgressChange)
  end
end

function UMG_ThisWeekClassSchedule_C:OnMixActivityClassScheduleStatusChange(_activityInst, _itemObj, _userOperation)
  if _itemObj and _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetScheduleItemIndexByObj(_itemObj)
    self.List:OpItemByIndex(itemIndex, ActivityEnum.ItemOpType.RewardStatusChange, _userOperation)
  end
end

function UMG_ThisWeekClassSchedule_C:OnMixActivityClassScheduleTaskChange(_activityInst, _itemObj)
  if _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetScheduleItemIndexByObj(_itemObj)
    self.List:OpItemByIndex(itemIndex, ActivityEnum.ItemOpType.RefreshData)
  end
end

function UMG_ThisWeekClassSchedule_C:GetScheduleItemIndexByObj(_itemObject)
  local itemIndex = self.List:GetIndexByData(_itemObject, function(_data, _valueInList)
    return _valueInList and _valueInList.customData == _data
  end)
  return itemIndex
end

function UMG_ThisWeekClassSchedule_C:OnItemRefreshView(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  _itemObject:UpdateProgress()
  if _itemInst then
    _itemInst:SetDesc(_itemObject:GetDesc())
    _itemInst:SetProgress(_itemObject:GetProgress())
    _itemInst:SetCurrencyIconAndCnt(_itemObject:GetRewardData())
    _itemInst:SetRedPoint(_itemObject:GetRedPointData())
    _itemInst:SetHideRefreshBtn(self.remainRefreshTimes <= 0)
  end
  self:OnItemRefreshRewardStatus(_itemInst, _itemObject)
end

function UMG_ThisWeekClassSchedule_C:OnItemRefreshRewardStatus(_itemInst, _itemObject, _userOperation)
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardStatus = _itemObject:GetRewardStatus()
    if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      if _itemObject:IsCanJump() then
        _itemInst:SetBtnSwitcher(1)
      else
        _itemInst:SetBtnSwitcher(0)
      end
      _itemInst:SetCompleted(false)
      _itemInst:PlayRewardUnAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetBtnSwitcher(2)
      _itemInst:SetCompleted(false)
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      _itemInst:SetBtnSwitcher(3)
      _itemInst:SetCompleted(true)
      if _userOperation then
        _itemInst:PlayRewardGetAnimation()
      else
        _itemInst:PlayRewardReceivedAnimation()
      end
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnItemUpdate(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  self:OnItemRefreshView(_itemInst, _index, _itemObject)
  if _itemInst then
    _itemInst:PlayInAnimation()
  end
end

function UMG_ThisWeekClassSchedule_C:OnItemSelected(_itemInst, _index, _itemObject, _bSelected)
  if not _itemObject then
    return
  end
end

function UMG_ThisWeekClassSchedule_C:OnItemOp(_itemInst, _index, _itemObject, _opType, _opParam)
  if not _itemObject then
    return
  end
  if _itemInst then
    if _opType == ActivityEnum.ItemOpType.RefreshData then
      self:OnItemRefreshView(_itemInst, _index, _itemObject)
    elseif _opType == ActivityEnum.ItemOpType.RewardStatusChange then
      self:OnItemRefreshRewardStatus(_itemInst, _itemObject, _opParam)
    elseif _opType == ActivityEnum.ItemOpType.ProgressChange then
      _itemInst:SetProgress(_itemObject:GetProgress())
    elseif _opType == ActivityEnum.ItemOpType.RefreshPartData1 then
      _itemInst:SetHideRefreshBtn(self.remainRefreshTimes <= 0)
    end
  end
end

function UMG_ThisWeekClassSchedule_C:OnRefreshBtnClick(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  local activityInst = self.activityInst
  if activityInst then
    activityInst:SendZoneRefreshMixActivityTaskReq(_itemObject:GetConditionParam())
  end
end

function UMG_ThisWeekClassSchedule_C:OnJumpBtnClick(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  _itemObject:ExecuteJump()
end

function UMG_ThisWeekClassSchedule_C:OnRewardBtnClick(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  local activityInst = self.activityInst
  if activityInst then
    local rewardStatus = _itemObject:GetRewardStatus()
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      activityInst:SendZoneTaskRewardReq(_itemObject:GetConditionParam())
    end
  end
end

return UMG_ThisWeekClassSchedule_C
