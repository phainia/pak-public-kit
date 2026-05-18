local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_SignInTemplate_C")
local UMG_Activity_Login_SignIn_C = Base:Extend("UMG_Activity_Login_SignIn_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_Login_SignIn_C:BindUIElements()
  local uiElements = {}
  uiElements.bgImage = self.BG
  uiElements.openAnimName = "In"
  uiElements.closeAnimName = "Close"
  uiElements.changeAnimName = "In"
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.signStages = {}
  if self.List then
    uiElements.signStages[self.List] = {1}
  end
  return uiElements
end

function UMG_Activity_Login_SignIn_C:OnConstruct()
  Base.OnConstruct(self)
  self.Text_Title_1:SetText(self.activityInst:GetActivityName())
  self.Text_Describe:SetText(self.activityInst:GetActivityPromptText())
end

function UMG_Activity_Login_SignIn_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:ForeachSignInItem(nil, function(itemInst, _firstLoad)
    if itemInst then
      itemInst:OnEnable(_firstLoad)
    end
  end, firstLoad)
end

function UMG_Activity_Login_SignIn_C:OnStageRewardStatusChange(_activityInst, _stage, _rewardStatus, _userOperation)
  Base.OnStageRewardStatusChange(self, _activityInst, _stage, _rewardStatus, _userOperation)
  if _activityInst and _activityInst == self.activityInst and _rewardStatus == ActivityEnum.RewardStatus.Received then
    local stageCfg = _activityInst:GetStageRewardsCfg()
    self.Text_TimeRemaining_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_TimeRemaining_1:SetText(stageCfg and stageCfg.next_tips_text or "")
  end
end

function UMG_Activity_Login_SignIn_C:OnItemSelected(_itemInst, _index, _stage, _bSelected)
  local _itemObject = self.activityInst
  if _bSelected and _itemObject then
    ActivityUtils.ShowRewardTips(_itemObject:GetStageRewardId(_stage))
  end
end

function UMG_Activity_Login_SignIn_C:DoJoinActivityOrClaimReward(_itemInst, _index, _stage)
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_Login_SignIn_C:DoJoinActivityOrClaimReward")
  local _activityInst = self.activityInst
  if _activityInst then
    if _activityInst:GetSvrStatus() ~= ActivityEnum.ActivitySvrStatus.Available then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.activity_tomorrow_tips)
      return true
    end
    return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Auto, _stage)
  end
  return false
end

function UMG_Activity_Login_SignIn_C:OnItemUpdate(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  self.Text_TimeRemaining_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _itemInst then
    _itemInst:SetDescribe(_G.LuaText.Holiday_Login_Bonus_Text)
    _itemInst:SetRewardId(_itemObject:GetStageRewardId(_stage))
    _itemInst:SetupRedPoint(_itemObject:GetRewardRedPointData(_stage))
    _itemInst:SetClickableWhenUnlocked()
    _itemInst:PlayInAnimation()
  end
  self:OnItemRefreshView(_itemInst, _index, _stage)
end

function UMG_Activity_Login_SignIn_C:OnItemRefreshView(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardStatus = _itemObject:GetStageRewardStatus(_stage)
    local stageCfg = _itemObject:GetStageRewardsCfg()
    local btnText = ""
    if _itemObject:GetSvrStatus() ~= ActivityEnum.ActivitySvrStatus.Available or rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      btnText = stageCfg and stageCfg.unlock_text or ""
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      btnText = _G.LuaText.activity_checkin_tip1
    else
      btnText = _G.LuaText.activity_checkin_tip3
    end
    if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnState(1, btnText)
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(true)
      _itemInst:SetBtnState(0, btnText)
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      _itemInst:SetAlreadyReceived(true)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnState(2, btnText)
      self.Text_TimeRemaining_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text_TimeRemaining_1:SetText(stageCfg and stageCfg.next_tips_text or "")
    end
    _itemInst:SetLeftTime(rewardStatus ~= ActivityEnum.RewardStatus.Received, math.maxinteger)
  end
end

return UMG_Activity_Login_SignIn_C
