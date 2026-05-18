local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_SurveyItem_C = Base:Extend("UMG_Activity_SurveyItem_C")

function UMG_Activity_SurveyItem_C:OnConstruct()
  Base.OnConstruct(self)
  self.Btn6.btnLevelUp.OnClicked:Add(self, self.JoinActivityOrClaimReward)
  self.Btn6_1.btnLevelUp.OnClicked:Add(self, self.JoinActivityOrClaimReward)
end

function UMG_Activity_SurveyItem_C:OnDestruct()
  Base.OnDestruct(self)
  self.Btn6.btnLevelUp.OnClicked:Clear()
  self.Btn6_1.btnLevelUp.OnClicked:Clear()
  local reason = _G.Enum.RedPointReason.RPR_ACTIVITY_WEBSITE_PART_NOTIFY
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithReason, reason, self.newRedPointExtraKey)
end

function UMG_Activity_SurveyItem_C:OnEnter()
  self:EnableAnimations(true)
  self:PlayInAnimation()
end

function UMG_Activity_SurveyItem_C:OnLeave()
  self:DisableAnimations()
  local reason = _G.Enum.RedPointReason.RPR_ACTIVITY_WEBSITE_PART_NOTIFY
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithReason, reason, self.newRedPointExtraKey)
end

function UMG_Activity_SurveyItem_C:OnItemSelected(_bSelected)
  if self.bOpenTip then
    Base.OnItemSelected(self, _bSelected)
  else
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("no_reward_preview_tips").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt)
  end
  self:PlaySelectAnimation(_bSelected)
end

function UMG_Activity_SurveyItem_C:JoinActivityOrClaimReward()
  local reason = _G.Enum.RedPointReason.RPR_ACTIVITY_WEBSITE_PART_NOTIFY
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithReason, reason, self.newRedPointExtraKey)
  return self:InvokeParentFunc("DoJoinActivityOrClaimReward")
end

function UMG_Activity_SurveyItem_C:PlayRewardGetAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Get, false, 10)
end

function UMG_Activity_SurveyItem_C:PlayInAnimation()
  self:PlayAnimationImmediately(self.In, false)
end

function UMG_Activity_SurveyItem_C:PlaySelectAnimation(_bSelected)
  if _bSelected then
    self:PlayAnimationImmediately(self.select_On, false)
  end
end

function UMG_Activity_SurveyItem_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Reward_ready_loop, false, 0, true)
end

function UMG_Activity_SurveyItem_C:SetDescribe(_desc)
  self.Text_Describe:SetText(_desc)
end

function UMG_Activity_SurveyItem_C:SetRewardId(rewardId)
  if rewardId and 0 ~= rewardId then
    self.Switcher:SetActiveWidgetIndex(1)
    self.bOpenTip = true
    local activityRewardData = ActivityUtils.GetActivityRewardData(rewardId, true)
    self.ItemIcon:SetPath(activityRewardData.showIcon)
    self.Num:SetText("x" .. activityRewardData.itemNum)
    ActivityUtils.SetRewardItemQuality(self.Quality, activityRewardData.itemQuality)
  else
    self.bOpenTip = false
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Activity_SurveyItem_C:SetupRedPoint(key, extraKey)
  self.redPointNew:EnableAnimation()
  self.redPointNew:SetupKey(key, extraKey)
end

function UMG_Activity_SurveyItem_C:SetupRedPointNew(key, extraKey)
  self.redPointNew_1:EnableAnimation()
  self.redPointNew_1:SetupKey(key, extraKey)
  local parts = {}
  for _, value in ipairs(extraKey) do
    if type(value) == "number" then
      table.insert(parts, tostring(value))
    end
  end
  self.newRedPointExtraKey = table.concat(parts, ".")
end

function UMG_Activity_SurveyItem_C:SetBtnText(_btnText)
  self.Btn6:SetBtnText(_btnText)
end

function UMG_Activity_SurveyItem_C:SetBtnVisible(_visible)
  self.Btn6:SetVisibility(_visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_SurveyItem_C:SetAlreadyReceived(_received)
  if _received then
    self:TryStopAnimation(self.Reward_ready_loop, true)
  end
  self.AlreadyReceived:SetVisibility(_received and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if self.NRCImage_1 then
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("F5EEE1FF"))
  end
end

function UMG_Activity_SurveyItem_C:SetBtnState(index, btnText)
  self.Switcher_Btn:SetActiveWidgetIndex(index)
  if 0 == index then
    if btnText then
      self.Btn6:SetBtnText(btnText)
    end
  elseif 3 == index then
    self.Btn6_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if btnText then
      self.Btn6_1:SetBtnText(btnText)
    end
  end
  if 1 == index then
    self.NotYetUnlocked:SetBtnText(btnText)
    self.NotYetUnlocked:SetShowLockIcon(false)
  elseif 2 == index then
    self.Claimable:SetShowLockIcon(false)
    self.Claimable:SetBtnText(btnText)
  end
end

function UMG_Activity_SurveyItem_C:SetClickableWhenUnlocked()
  self:AddButtonListener(self.NotYetUnlocked.btnLevelUp, self.JoinActivityOrClaimReward)
end

function UMG_Activity_SurveyItem_C:SetParticleVisible(_visible)
  if self.ParticleSystemWidget then
    self.ParticleSystemWidget:SetVisibility(_visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_SurveyItem_C:SetLeftTime(_visible, leftTime)
  if not _visible or leftTime == math.maxinteger then
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_luoke:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_luoke:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if leftTime > 0 then
      self.Switcher_Text:SetActiveWidgetIndex(0)
      self.Text_Time:SetText(ActivityUtils.GetTimeFormatStr(leftTime))
    else
      self.Switcher_Text:SetActiveWidgetIndex(1)
    end
  end
end

return UMG_Activity_SurveyItem_C
