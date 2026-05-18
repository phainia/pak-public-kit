local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_SignInTemplate_C")
local UMG_Activity_SummaryRecall_C = Base:Extend("UMG_Activity_SummaryRecall_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_SummaryRecall_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.BtnSurvey, self.ShowStarDebrisTip)
  self:SetBasicInfo()
  local activityId = self.activityInst:GetActivityId()
  self.RedDot:SetupKey(307, {activityId})
end

function UMG_Activity_SummaryRecall_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:PlayAnimation(self.In)
end

function UMG_Activity_SummaryRecall_C:SetBasicInfo()
  local stage_data = self.activityInst.returnActivityData
  if not (stage_data and stage_data.stage_timestamp) or not stage_data.open_timestamp then
    Log.Error("UMG_Activity_SummaryRecall_C:SetBasicInfo stage_data is invalid")
    return
  end
  self.openTimeStamp = stage_data.open_timestamp
  local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
  StarDebrisNum = StarDebrisNum or 0
  self.Text_quantity:SetText(StarDebrisNum)
  local starDebrisConf = _G.DataConfigManager:GetVisualItemConf(Enum.VisualItem.VI_STAR_DEBRIS)
  self:SetItemNameTextSize(starDebrisConf.displayName)
  self.ItemNameText:SetText(starDebrisConf.displayName)
  local recallText = _G.DataConfigManager:GetLocalizationConf("Recall_Postcard_Text").msg
  if recallText then
    self.TextDescribe:SetText(recallText)
  end
end

function UMG_Activity_SummaryRecall_C:RefreshTimeRemaining()
  local svrTimeStamp = ActivityUtils.GetSvrTimestamp()
  local timeOpenStamp = self.openTimeStamp
  local timeOpenDetailData = ActivityUtils.ToTimeDetailData(timeOpenStamp)
  local timeCloseStamp
  if timeOpenDetailData.hour < 4 then
    timeCloseStamp = timeOpenStamp + 1209600
  else
    timeCloseStamp = timeOpenStamp + 1296000
  end
  timeCloseStamp = os.date("*t", timeCloseStamp)
  timeCloseStamp.hour = 4
  timeCloseStamp.min = 0
  timeCloseStamp.sec = 0
  timeCloseStamp = os.time(timeCloseStamp)
  local timeRemainStamp = math.max(timeCloseStamp - svrTimeStamp, 0)
  local timeRemainingText = ActivityUtils.GetTimeFormatStr(timeRemainStamp)
  self.TimeRemaining:SetText(timeRemainingText)
end

function UMG_Activity_SummaryRecall_C:SetItemNameTextSize(inputText)
  local text = inputText
  local textStr = tostring(text)
  local length = string.len(textStr)
  local Font = self.ItemNameText.Font
  if length <= 15 then
    Font.Size = 26
    self.ItemNameText:SetFont(Font)
  elseif length > 15 and length <= 18 then
    Font.Size = 22
    self.ItemNameText:SetFont(Font)
  elseif length > 18 and length <= 21 then
    Font.Size = 20
    self.ItemNameText:SetFont(Font)
  end
end

function UMG_Activity_SummaryRecall_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.signStages = {}
  uiElements.signStages[self.List] = {
    1,
    2,
    3,
    4,
    5,
    6
  }
  uiElements.signStages[self.List_1] = {7}
  uiElements.openAnimName = "In"
  return uiElements
end

function UMG_Activity_SummaryRecall_C:OnItemSelected(_itemInst, _index, _stage, _bSelected)
  local _activityInst = self.activityInst
  if _bSelected and _activityInst then
    local handled = _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Auto, _stage)
    if not handled then
      ActivityUtils.ShowRewardTips(_activityInst:GetStageRewardId(_stage))
    end
  end
end

function UMG_Activity_SummaryRecall_C:OnItemUpdate(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardData = _itemObject:GetStageRewardData(_stage) or {}
    _itemInst:SetRewardIcon(rewardData.showIcon)
    _itemInst:SetRewardNum(rewardData.itemNum)
    _itemInst:SetQuality(rewardData.itemQuality)
    _itemInst:SetSignStage(_stage)
    _itemInst:SetupRedPoint(_itemObject:GetRewardRedPointData(_stage))
  end
  self:OnItemRefreshView(_itemInst, _index, _stage)
end

function UMG_Activity_SummaryRecall_C:ShowStarDebrisTip()
  if self.RedDot:IsRed() then
    local activityId = self.activityInst:GetActivityId()
    self.RedDot:EraseRedPoint(307, {activityId})
  end
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, Enum.VisualItem.VI_STAR_DEBRIS, _G.Enum.GoodsType.GT_VITEM, false)
end

function UMG_Activity_SummaryRecall_C:OnItemRefreshView(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardStatus = _itemObject:GetStageRewardStatus(_stage)
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetSignStageColor("d56c1fff")
      _itemInst:TryPlayAnimation(_itemInst.Reward_ready_loop, false, 0, true)
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      _itemInst:SetSignStageColor("050505FF")
      _itemInst:SetRewardNumColor("47463CFF")
      _itemInst:SetReceiveState()
      _itemInst:PlayAnimationReverse(_itemInst.select)
    else
      _itemInst:SetSignStageColor("050505FF")
    end
  end
end

return UMG_Activity_SummaryRecall_C
