local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local UMG_Activity_BindMobilePhone_C = Base:Extend("UMG_Activity_BindMobilePhone_C")
local BindPhoneEnum = {
  None = 0,
  Bind = 1,
  Award = 2,
  HasGet = 3
}

function UMG_Activity_BindMobilePhone_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self.CurType = BindPhoneEnum.None
  self.IsGetBindPhoneInfo = false
  self.Reminder:SetShowLockIcon(false)
  self:InitInfo()
  self.Reminder.btnLevelUp:SetIsEnabled(false)
end

function UMG_Activity_BindMobilePhone_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveEventListener()
end

function UMG_Activity_BindMobilePhone_C:OnAddEventListener()
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnBindPhone)
  self:AddButtonListener(self.BtnReward.btnLevelUp, self.OnGetAward)
  self:AddButtonListener(self.NRCButton_53, self.OpenRewardTips)
  self:RegisterEvent(self, ActivityModuleEvent.WebSiteItemStatusChange, self.OnWebSiteItemStatusChange)
  self:RegisterEvent(self, ActivityModuleEvent.RefreshActiveWebSiteItems, self.RefreshWebSiteItems)
  _G.NRCEventCenter:RegisterEvent(self.name, self, SystemSettingModuleEvent.UnLockGetBindPhoneInfoReq, self.UnLockGetBindPhoneInfo)
end

function UMG_Activity_BindMobilePhone_C:RemoveEventListener()
  self:RemoveButtonListener(self.Btn6.btnLevelUp, self.OnBindPhone)
  self:RemoveButtonListener(self.BtnReward.btnLevelUp, self.OnGetAward)
  self:RemoveButtonListener(self.NRCButton_53, self.OpenRewardTips)
  self:UnRegisterEvent(self, ActivityModuleEvent.WebSiteItemStatusChange)
  self:UnRegisterEvent(self, ActivityModuleEvent.RefreshActiveWebSiteItems)
  _G.NRCEventCenter:UnRegisterEvent(self, SystemSettingModuleEvent.UnLockGetBindPhoneInfoReq, self.UnLockGetBindPhoneInfo)
end

function UMG_Activity_BindMobilePhone_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.title = self.Text_Title
  uiElements.promptText = self.PromptText
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_BindMobilePhone_C:SetRedPoints()
  local activityId = self.activityInst:GetActivityId()
  self.redPointReward:SetupKey(ActivityEnum.RedPointKey.DetailReward, {activityId})
end

function UMG_Activity_BindMobilePhone_C:InitInfo()
  if self.activityInst then
    local partId = self.activityInst:GetSinglePartId()
    local webSiteConf = _G.DataConfigManager:GetActivityWebsitePartConf(partId)
    local rewardId = webSiteConf.reward_id
    local activityRewardData = ActivityUtils.GetActivityRewardData(rewardId, true)
    self.Icon:SetPath(activityRewardData.showIcon)
    self.Num:SetText("x" .. activityRewardData.itemNum)
    self.Text_Describe:SetText(webSiteConf.part_name)
    ActivityUtils.SetRewardItemQuality(self.Quality, activityRewardData.itemQuality)
    self:RefreshWebSiteItems(self.activityInst)
    self:SetRedPoints()
  end
end

function UMG_Activity_BindMobilePhone_C:OnBindPhone()
  if self.IsGetBindPhoneInfo then
    return
  end
  self.IsGetBindPhoneInfo = true
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_Activity_BindMobilePhone_C:OnBindPhone")
  if self.activityInst then
    local webSiteItem = self.activityInst.webSiteItems[1]
    ActivityUtils.SendTLogActivityAction(webSiteItem.owner:GetActivityId(), webSiteItem.conf.id, ActivityEnum.TLogActionType.Join, webSiteItem.conf.flag_num_join)
  end
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqGetMobileBindInfo)
end

function UMG_Activity_BindMobilePhone_C:OnGetAward()
  _G.NRCAudioManager:PlaySound2DAuto(1220002029, "UMG_Activity_BindMobilePhone_C:OnGetAward")
  if self.activityInst then
    local partId = self.activityInst:GetSinglePartId()
    local itemObject = self.activityInst:GetWebSiteItem(partId)
    self.activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.GetReward, itemObject)
  end
end

function UMG_Activity_BindMobilePhone_C:OnWebSiteItemStatusChange(_activityInst, _webSiteItemObj, _userOperation)
  if _activityInst and _activityInst == self.activityInst then
    local status = _webSiteItemObj:GetRewardStatus()
    if status == ActivityEnum.RewardStatus.Available then
      self:ShowAwardBtn()
    elseif status == ActivityEnum.RewardStatus.Received then
      if _userOperation then
        ActivityUtils.ShowRewardGetTips(_webSiteItemObj:GetRewardID())
      end
      self:ShowHasGetBtn()
      if self.activityInst then
        self.activityInst:SetActivityCompleted()
      end
    end
  end
end

function UMG_Activity_BindMobilePhone_C:ShowHasGetBtn()
  self.Btn6:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Reminder:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Reminder:SetBtnText(_G.DataConfigManager:GetLocalizationConf("activity_checkin_tip3").msg)
  self.CurType = BindPhoneEnum.HasGet
  self:StopAnimation(self.Reward_ready_loop)
  self:PlayAnimation(self.get, 0)
end

function UMG_Activity_BindMobilePhone_C:ShowAwardBtn()
  self.Btn6:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Reminder:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local webSiteItem = self.activityInst.webSiteItems[1]
  local btnText = webSiteItem:GetInteractiveText()
  self.BtnReward:SetBtnText(btnText)
  self.CurType = BindPhoneEnum.Award
  self:PlayAnimation(self.Reward_ready_loop, 0, 0)
end

function UMG_Activity_BindMobilePhone_C:ShowBindPhoneBtn()
  self.Btn6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BtnReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Reminder:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local webSiteItem = self.activityInst.webSiteItems[1]
  local btnText = webSiteItem:GetInteractiveText()
  self.Btn6:SetBtnText(btnText)
  self.Btn6:SetClickAble(true)
  self.CurType = BindPhoneEnum.Bind
end

function UMG_Activity_BindMobilePhone_C:OpenRewardTips()
  self:PlayAnimation(self.select_Press)
  if self.activityInst then
    local partId = self.activityInst:GetSinglePartId()
    local webSiteConf = _G.DataConfigManager:GetActivityWebsitePartConf(partId)
    ActivityUtils.ShowRewardTips(webSiteConf.reward_id)
  end
end

function UMG_Activity_BindMobilePhone_C:OnAnimationFinished(anim)
  if anim == self.select_Press then
    self:PlayAnimation(self.select_On)
  end
end

function UMG_Activity_BindMobilePhone_C:RefreshWebSiteItems(_activityInst)
  if _activityInst and _activityInst == self.activityInst then
    local completedTimeStamp = self.activityInst:GetActivityCompletedTimeStamp()
    if 0 ~= completedTimeStamp then
      self:ShowHasGetBtn()
    elseif self.activityInst.webSiteItems and #self.activityInst.webSiteItems > 0 then
      local webSiteItem = self.activityInst.webSiteItems[1]
      local status = webSiteItem:GetRewardStatus()
      if status == ActivityEnum.RewardStatus.UnAvailable then
        self:ShowBindPhoneBtn()
      elseif status == ActivityEnum.RewardStatus.Available then
        self:ShowAwardBtn()
      elseif status == ActivityEnum.RewardStatus.Received then
        self:ShowHasGetBtn()
      end
    else
      Log.Error("\230\178\161\230\156\137\232\142\183\229\143\150\229\136\176webSiteItems\230\149\176\230\141\174\239\188\129\239\188\129\239\188\129")
    end
  end
end

function UMG_Activity_BindMobilePhone_C:UnLockGetBindPhoneInfo()
  self.IsGetBindPhoneInfo = false
end

return UMG_Activity_BindMobilePhone_C
