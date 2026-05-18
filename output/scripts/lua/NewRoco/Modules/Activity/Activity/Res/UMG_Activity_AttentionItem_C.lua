local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_AttentionItem_C = Base:Extend("UMG_Activity_AttentionItem_C")

function UMG_Activity_AttentionItem_C:OnConstruct()
  Base.OnConstruct(self)
  self.Btn6.btnLevelUp.OnClicked:Add(self, self.JoinActivityOrClaimReward)
  if self.Btn6_1 then
    self.Btn6_1.btnLevelUp.OnClicked:Add(self, self.JoinActivityOrClaimReward)
  end
  self.Text_luoke:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Activity_AttentionItem_C:OnDestruct()
  Base.OnDestruct(self)
  self.Btn6.btnLevelUp.OnClicked:Clear()
  if self.Btn6_1 then
    self.Btn6_1.btnLevelUp.OnClicked:Clear()
  end
end

function UMG_Activity_AttentionItem_C:OnEnter()
  self:EnableAnimations(true)
  self:PlayInAnimation()
end

function UMG_Activity_AttentionItem_C:OnLeave()
  self:DisableAnimations()
end

function UMG_Activity_AttentionItem_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  self:PlaySelectAnimation(_bSelected)
end

function UMG_Activity_AttentionItem_C:JoinActivityOrClaimReward()
  return self:InvokeParentFunc("DoJoinActivityOrClaimReward")
end

function UMG_Activity_AttentionItem_C:PlayInAnimation()
  self:PlayAnimationImmediately(self.In, false)
end

function UMG_Activity_AttentionItem_C:PlayRewardGetAnimation()
  self:TryStopAnimation(self.Reward_ready_loop, true)
  self:TryPlayAnimation(self.Reward_get, false, 10)
end

function UMG_Activity_AttentionItem_C:PlayRewardUnAvailableAnimation()
  self:TryPlayAnimation(self.Reward_normal, false, 0)
end

function UMG_Activity_AttentionItem_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Reward_ready_loop, false, 0, true)
end

function UMG_Activity_AttentionItem_C:PlayRewardReceivedAnimation()
  self:TryPlayAnimation(self.Get)
end

function UMG_Activity_AttentionItem_C:PlaySelectAnimation(_bSelected)
  if _bSelected then
    self:PlayAnimationImmediately(self.select_On, false)
  end
end

function UMG_Activity_AttentionItem_C:SetDescribe(desc)
  self.Text_Describe:SetText(desc)
end

function UMG_Activity_AttentionItem_C:SetRewardId(rewardId)
  local activityRewardData = ActivityUtils.GetActivityRewardData(rewardId, true)
  self.Icon:SetPath(activityRewardData.showIcon)
  self.Num:SetText("x" .. activityRewardData.itemNum)
  ActivityUtils.SetRewardItemQuality(self.Quality, activityRewardData.itemQuality)
end

function UMG_Activity_AttentionItem_C:SetRewardNumColor(_colorStr)
  self.Num:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(_colorStr))
end

function UMG_Activity_AttentionItem_C:SetupRedPoint(key, extraKey)
  self.redPointReward:EnableAnimation()
  self.redPointReward:SetupKey(key, extraKey)
end

function UMG_Activity_AttentionItem_C:SetBtnText(_btnText)
  self.Btn6:SetShowLockIcon(false)
  self.Btn6:SetBtnText(_btnText)
end

function UMG_Activity_AttentionItem_C:SetBtnVisible(_visible)
  self.Btn6.BG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_btn1_white_png.img_btn1_white_png'")
  self.Btn6:SetVisibility(_visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_AttentionItem_C:SetReminderSwitcher(_Text)
  self.Reminder:SetShowLockIcon(false)
  self.Reminder:SetBtnText(_Text)
end

function UMG_Activity_AttentionItem_C:SetReminderVisible(_visible)
  self.Reminder:SetVisibility(_visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_AttentionItem_C:SetAlreadyReceived(_received)
  if _received then
    self:TryStopAnimation(self.Reward_ready_loop, true)
  end
  self.Panel_AlreadyReceived:SetVisibility(_received and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_AttentionItem_C:SetBtnState(index)
  self.Switcher:SetActiveWidgetIndex(index)
end

function UMG_Activity_AttentionItem_C:SetParticleVisible(_visible)
  self.ParticleSystemWidget:SetVisibility(_visible and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_AttentionItem_C:SetUnfinished(_visible)
end

return UMG_Activity_AttentionItem_C
