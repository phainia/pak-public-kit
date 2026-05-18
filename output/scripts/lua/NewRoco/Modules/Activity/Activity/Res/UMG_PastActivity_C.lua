local UMG_PastActivity_C = _G.NRCPanelBase:Extend("UMG_PastActivity_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_PastActivity_C:OnConstruct()
  self:SetChildViews(self.Popup)
  self.replace:SetBtnText(_G.LuaText.ShinyWeekend_get_egg_option)
  self.replace:SetTitleTextAndIcon("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/ActivityAttention/Frames/img_huaban_png.img_huaban_png'", nil, nil, nil, "3")
  self.replace:SetMoneyIconScale(0.7, 0.7)
  self.reminder:SetBtnText(_G.LuaText.ShinyWeekend_get_egg_tip)
  self.reminder:SetShowLockIcon(false)
  self.reminder:SetTitleTextAndIcon("PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/ActivityAttention/Frames/img_huaban_png.img_huaban_png'", nil, nil, nil, "3")
  self.reminder:SetTitleTextColor("#c7494aFF")
  self.reminder:SetMoneyIconScale(0.7, 0.7)
  self.redPointReward:SetupKey(298)
  self.QuantityObtainedText:SetText(ActivityUtils.GetActivityGlobalConfig("ShinyWeekend_get_petal_count").num)
  self.CaptureDescriptionText:SetText(_G.LuaText.ShinyWeekend_get_petal_tips)
  local vItemsConf = _G.DataConfigManager:GetVisualItemConf(Enum.VisualItem.VI_ACTIVITY_PETAL)
  if vItemsConf then
    self.IconImage:SetPath(vItemsConf.bigIcon)
  end
  self:AddButtonListener(self.btnClose.btnClose, self.ClosePanel)
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnClickSwitchShinyDataPopupVisibility)
  self:AddButtonListener(self.FullScreenClosed, self.OnClickSwitchShinyDataPopupVisibility)
  self:AddButtonListener(self.replace.btnLevelUp, self.OnClickReceiveShinyPetDayReward)
  self:AddButtonListener(self.CaptureAndObtainBtn, self.OnClickGetPetal)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshShinyHistoryData, self.OnRefreshActivityHistoryData)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshPlayerShinyPetDayDataInfo, self.OnRefreshPlayerShinyPetDayDataInfo)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshActivityShinyPetDayData, self.OnRefreshActivityShinyPetDayData)
  self:RegisterEvent(self, ActivityModuleEvent.ShinyWeekendActivityRewardReceived, self.OnShinyWeekendActivityRewardReceived)
  self:DispatchEvent(ActivityModuleEvent.ShowActivityMainPanelCloseBtn, false)
  self:SetCommonTitle()
end

function UMG_PastActivity_C:OnDestruct()
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshShinyHistoryData)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshPlayerShinyPetDayDataInfo)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshActivityShinyPetDayData)
  self:UnRegisterEvent(self, ActivityModuleEvent.ShinyWeekendActivityRewardReceived)
  self:DispatchEvent(ActivityModuleEvent.ShowActivityMainPanelCloseBtn, true)
end

function UMG_PastActivity_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002014, "UMG_PastActivity_Hearsay_C:ClosePanel")
  self:OnClose()
end

function UMG_PastActivity_C:OnActive(_activityInst)
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  self.activityInst = _activityInst
  if not _activityInst then
    Log.ErrorFormat("UMG_PastActivity_C: \229\191\133\233\161\187\228\188\160\229\133\165\228\184\128\228\184\170\230\180\187\229\138\168\229\174\158\228\190\139!")
  end
  self:OnRefreshPlayerShinyPetDayDataInfo(_activityInst)
  self:OnRefreshActivityHistoryData(_activityInst)
end

function UMG_PastActivity_C:OnClickSwitchShinyDataPopupVisibility()
  if self.Popup:IsVisible() then
    _G.NRCAudioManager:PlaySound2DAuto(40002014, "UMG_PastActivity_C:OnClickSwitchShinyDataPopupVisibility")
    self.Popup:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FullScreenClosed:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1078, "UMG_PastActivity_C:OnClickSwitchShinyDataPopupVisibility")
    self.Popup:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.FullScreenClosed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PastActivity_C:OnClickReceiveShinyPetDayReward()
  _G.NRCAudioManager:PlaySound2DAuto(1281, "UMG_PastActivity_C:OnClickReceiveShinyPetDayReward")
  local petName = ""
  local selectConf = _G.DataConfigManager:GetActivityConf(self.selectActivityId)
  if selectConf then
    local shinyWeekendConfId = selectConf.base_id[1]
    if self.activityInst:IsShinyWeekendDataShouldClear(shinyWeekendConfId, ActivityUtils.GetSvrTimestamp()) then
      ActivityUtils.ShowActivityExpiredTips()
      return
    end
    local shinyWeekEndConf = _G.DataConfigManager:GetActivityShinyWeekendConf(shinyWeekendConfId)
    local petBaseId = shinyWeekEndConf and shinyWeekEndConf.petbase_id
    if petBaseId and 0 ~= petBaseId then
      local petConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
      petName = petConf and petConf.name or ""
    end
  end
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  Context:SetTitle(_G.LuaText.shinyweekend_exchange_egg_tip_title):SetContent(string.format(_G.LuaText.shinyweekend_exchange_egg_tip, petName)):SetButtonText(_G.LuaText.umg_dialog_2, _G.LuaText.umg_dialog_1):SetContentTextJustify(UE4.ETextJustify.Center):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, self.DoReceiveShinyPetDayReward):SetClickAnywhereClose(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_PastActivity_C:DoReceiveShinyPetDayReward()
  local _activityInst = self.activityInst
  if _activityInst then
    _activityInst:SendZoneReceivePlayerActivityShinyPetDayRewardReq(self.selectActivityId)
  end
end

function UMG_PastActivity_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_PastActivity_C:OnClickGetPetal()
  _G.NRCAudioManager:PlaySound2DAuto(1197, "UMG_PastActivity_C:OnClickGetPetal")
  local _activityInst = self.activityInst
  if _activityInst then
    _activityInst:SendZoneReceivePlayerActivityShinyPetDayPetalReq()
  end
end

function UMG_PastActivity_C:GetItemIndexByActivityId(_activityId)
  local itemIndex = self.List:GetIndexByData(_activityId, function(_data, _valueInList)
    local _activityData = _valueInList and _valueInList.customData
    return _activityData and _activityData.activity_id == _data
  end)
  return itemIndex
end

function UMG_PastActivity_C:OnRefreshActivityHistoryData(_activityInst)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  local historyData = _activityInst:GetActivityHistoryData() or {}
  local selectIndex = 0
  if self.selectActivityId then
    for _index, _dataItem in ipairs(historyData) do
      if _dataItem.activity_id == self.selectActivityId then
        selectIndex = _index - 1
      end
    end
  end
  ActivityUtils.AdjustCtrlAutoSize(self.List, #historyData <= 3)
  self.List:InitList(ActivityUtils.CreateActivityItemBaseDataForList(self, historyData))
  self.SkipAudio = true
  self.List:SelectItemByIndex(selectIndex)
end

function UMG_PastActivity_C:OnSelectHistoryDataItem(_activityInst, _activityId, _shinyPetDayData)
  if not _activityInst or not _shinyPetDayData then
    return
  end
  if self.selectActivityId and self.selectActivityId ~= _activityId then
    self:PlayAnimation(self.switchover)
  end
  self.selectActivityId = _activityId
  local shinyWeekEndConf = _G.DataConfigManager:GetActivityShinyWeekendConf(_shinyPetDayData.activity_sub_id)
  local petBaseData = shinyWeekEndConf and _G.DataConfigManager:GetPetbaseConf(shinyWeekEndConf.petbase_id)
  local petName = petBaseData and petBaseData.name
  self.Attr:InitGridView(ActivityUtils.CreatePetCommonAttrListData(petBaseData and petBaseData.unit_type, ActivityUtils.GetPetBloodIdByShinyWeekendConf(shinyWeekEndConf)))
  self.TextName:SetText(petName)
  if _shinyPetDayData.total_catch_num and _shinyPetDayData.total_catch_num > 0 then
    self.Switcher:SetActiveWidgetIndex(0)
    local firstCaughtTime = ActivityUtils.ToTimeDetailData(_shinyPetDayData.frist_caught_timestamp)
    local caughtCamp = _shinyPetDayData.frist_caught_camp and _G.DataConfigManager:GetCampConf(_shinyPetDayData.frist_caught_camp)
    self.TextDescribe:SetText(string.format(_G.LuaText.ShinyWeekend_review_text1, _shinyPetDayData.frist_caught_ranking, _shinyPetDayData.total_catch_num, petName, firstCaughtTime.year, firstCaughtTime.month, firstCaughtTime.day, firstCaughtTime.hour, firstCaughtTime.minute, caughtCamp and caughtCamp.camp_name or ""))
    self.HeadIcon:SetPath(petBaseData and petBaseData.JL_shiny_res)
    if _shinyPetDayData.shiny_caught_timestamps and #_shinyPetDayData.shiny_caught_timestamps > 0 then
      self.Switcher_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Switcher_Btn:SetActiveWidgetIndex(0)
      local shinyCaughtTimeStr = {}
      local timeFormatString = _G.LuaText.ShinyWeekend_review_GlassTime
      for _index, _timestamps in ipairs(_shinyPetDayData.shiny_caught_timestamps) do
        local _timeData = ActivityUtils.ToTimeDetailData(_timestamps)
        table.insert(shinyCaughtTimeStr, string.format(timeFormatString, _index, _timeData.year, _timeData.month, _timeData.day, _timeData.hour, _timeData.minute))
      end
      self.Popup:SetShinyTimes(shinyCaughtTimeStr)
      self.Popup:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Switcher_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Switcher:SetActiveWidgetIndex(1)
    local activityConf = _G.DataConfigManager:GetActivityConf(_activityId)
    local activityStart = ActivityUtils.ToTimeDetailData(ActivityUtils.ToTimestamp(activityConf and activityConf.appear_time))
    local activityEnd = ActivityUtils.ToTimeDetailData(ActivityUtils.ToTimestamp(activityConf and activityConf.disappear_time))
    self.TextDescribe:SetText(string.format(_G.LuaText.ShinyWeekend_review_text2, activityStart.year, activityStart.month, activityStart.day, activityEnd.month, activityEnd.day, petName))
    local rewardData = ActivityUtils.GetActivityRewardData(shinyWeekEndConf and shinyWeekEndConf.egg_reward_id, true)
    self.icon:SetPath(rewardData.showIcon)
    self.Switcher_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 2 == _shinyPetDayData.received_reward then
      self.Switcher_Btn:SetActiveWidgetIndex(3)
    else
      local playerShinyPetDayInfo = _activityInst:GetPlayerShinyPetDayInfo()
      local petalNum = playerShinyPetDayInfo and playerShinyPetDayInfo.petal_num or 0
      if petalNum >= 3 then
        self.Switcher_Btn:SetActiveWidgetIndex(1)
        self.replace:SetRedDotExtraKey(299, {_activityId})
      else
        self.Switcher_Btn:SetActiveWidgetIndex(2)
      end
    end
  end
end

function UMG_PastActivity_C:OnRefreshPlayerShinyPetDayDataInfo(_activityInst)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  local playerShinyPetDayInfo = _activityInst:GetPlayerShinyPetDayInfo()
  if playerShinyPetDayInfo and playerShinyPetDayInfo.has_petal then
    self.AreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.AreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local petalNum = playerShinyPetDayInfo and playerShinyPetDayInfo.petal_num or 0
  local petalMax = ActivityUtils.GetActivityGlobalConfig("ShinyFlower_Petal_Max").num
  self.PetalMoney:SetInfo(Enum.VisualItem.VI_ACTIVITY_PETAL, petalNum)
  self.PetalMoney:SetSumText(string.format("%d/%d", petalNum, petalMax), petalNum == petalMax)
end

function UMG_PastActivity_C:OnRefreshActivityShinyPetDayData(_activityInst, _activityId, _shinyPetDayData)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  local itemIndex = self:GetItemIndexByActivityId(_activityId)
  if itemIndex and _activityId == self.selectActivityId then
    self:OnSelectHistoryDataItem(_activityInst, _activityId, _shinyPetDayData)
  end
end

function UMG_PastActivity_C:OnShinyWeekendActivityRewardReceived(_activityInst, _activityId, _shinyPetDayData)
  if not _activityInst or _activityInst ~= self.activityInst then
    return
  end
  if _shinyPetDayData then
  end
end

function UMG_PastActivity_C:OnItemUpdate(_itemInst, _index, _activityData)
  if _itemInst and _activityData then
    local shinyWeekEndConf = _G.DataConfigManager:GetActivityShinyWeekendConf(_activityData.shiny_pet_day_data and _activityData.shiny_pet_day_data.activity_sub_id)
    if shinyWeekEndConf then
      local petConf = _G.DataConfigManager:GetPetbaseConf(shinyWeekEndConf.petbase_id)
      _itemInst:SetSerialNumber(petConf and petConf.pictorial_book_id)
      _itemInst:SetImagePath(shinyWeekEndConf.shiny_pet_preview)
      _itemInst:SetRedPoint(299, {
        _activityData.activity_id
      })
      local activityConf = _G.DataConfigManager:GetActivityConf(_activityData.activity_id)
      local timeDetailStart = ActivityUtils.ToTimeDetailData(ActivityUtils.ToTimestamp(activityConf and activityConf.appear_time))
      local timeDetailEnd = ActivityUtils.ToTimeDetailData(ActivityUtils.ToTimestamp(activityConf and activityConf.disappear_time))
      _itemInst:SetTimeStr(string.format(_G.LuaText.ShinyWeekend_review_TabTime, timeDetailStart.year, timeDetailStart.month, timeDetailStart.day, timeDetailEnd.month, timeDetailEnd.day))
      _itemInst:PlayInAnimation()
    end
  end
end

function UMG_PastActivity_C:OnItemSelected(_itemInst, _index, _activityData, _bSelected)
  if self.SkipAudio then
    self.SkipAudio = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(1220002017, "UMG_PastActivity_C:OnItemSelected")
  end
  if _bSelected and _activityData then
    self:OnSelectHistoryDataItem(self.activityInst, _activityData.activity_id, _activityData.shiny_pet_day_data)
  end
end

return UMG_PastActivity_C
