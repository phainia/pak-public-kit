local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_SignInTemplate_C")
local UMG_Activity_SignIn_C = Base:Extend("UMG_Activity_SignIn_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_SignIn_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.ExamineBtn, self.JumpToPetDesc)
  self:AddButtonListener(self.Btn_Pet, self.EnterClick)
  if self.bgSpine then
    self.bgSpine.Scale = 1.275
    self.bgSpine:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.yajjSpine then
    self.yajjSpine.Scale = 1
    self.yajjSpine:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Activity_SignIn_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:EnterStart()
end

function UMG_Activity_SignIn_C:BindUIElements()
  local uiElements = {}
  uiElements.changeAnimName = "Open"
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.TimeRemaining
  uiElements.signStages = {}
  if self.List then
    uiElements.signStages[self.List] = {
      1,
      2,
      4,
      5,
      6,
      7
    }
  end
  if self.List_1 then
    uiElements.signStages[self.List_1] = {3, 8}
  end
  return uiElements
end

function UMG_Activity_SignIn_C:OnTick(deltaTime)
  if self.isShowing then
    if self.bgSpine then
      self.bgSpine:Tick(deltaTime, false)
    end
    if self.yajjSpine then
      self.yajjSpine:Tick(deltaTime, false)
    end
  end
end

function UMG_Activity_SignIn_C:SetSpineAnimation(animName, loop)
  if self.bgSpine then
    self.bgSpine:ClearTracks()
    self.bgSpine:SetAnimation(0, animName, loop)
  end
  if self.yajjSpine then
    self.yajjSpine:ClearTracks()
    self.yajjSpine:SetAnimation(0, animName, loop)
  end
  self.playingAnimName = animName
end

function UMG_Activity_SignIn_C:EnterStart()
  self:SetSpineAnimation("start", false)
  self:CancelDelay()
  self:DelaySeconds(1.5, self.EnterIdle, self)
end

function UMG_Activity_SignIn_C:EnterIdle()
  self:CancelDelay()
  self:SetSpineAnimation("idle", true)
end

function UMG_Activity_SignIn_C:EnterClick()
  if self.playingAnimName == "start" then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40009001, "UMG_Activity_SignIn_C:EnterClick")
  self:SetSpineAnimation("click", false)
  self:CancelDelay()
  self:DelaySeconds(2, self.EnterIdle, self)
end

function UMG_Activity_SignIn_C:JumpToPetDesc()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_SignIn_C:JumpToPetDesc")
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, 3452, true)
end

function UMG_Activity_SignIn_C:OnItemSelected(_itemInst, _index, _stage, _bSelected)
  local _activityInst = self.activityInst
  if _bSelected and _activityInst then
    local handled = _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Auto, _stage)
    if not handled then
      ActivityUtils.ShowRewardTips(_activityInst:GetStageRewardId(_stage))
    end
  end
end

function UMG_Activity_SignIn_C:OnItemUpdate(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardData = _itemObject:GetStageRewardData(_stage) or {}
    _itemInst:SetRewardIcon(rewardData.showIcon)
    _itemInst:SetRewardNum(rewardData.itemNum)
    _itemInst:SetSignStage(_stage)
    _itemInst:SetupRedPoint(_itemObject:GetRewardRedPointData(_stage))
    _itemInst:PlayRewardUnAvailableAnimation()
  end
  self:OnItemRefreshView(_itemInst, _index, _stage)
end

function UMG_Activity_SignIn_C:OnItemRefreshView(_itemInst, _index, _stage)
  local _itemObject = self.activityInst
  if not _itemObject then
    return
  end
  if _itemInst then
    local rewardStatus = _itemObject:GetStageRewardStatus(_stage)
    if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      _itemInst:SetSwitcherActiveIndex(0)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:PlayRewardUnAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetSwitcherActiveIndex(1)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      _itemInst:SetSwitcherActiveIndex(2)
      _itemInst:SetAlreadyReceived(true)
      _itemInst:PlayRewardReceivedAnimation()
    end
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetSignStageColor("d56c1fff")
      _itemInst:SetRewardNumColor("f4eee1ff")
    else
      _itemInst:SetSignStageColor("050505FF")
      _itemInst:SetRewardNumColor("47463CFF")
    end
  end
end

return UMG_Activity_SignIn_C
