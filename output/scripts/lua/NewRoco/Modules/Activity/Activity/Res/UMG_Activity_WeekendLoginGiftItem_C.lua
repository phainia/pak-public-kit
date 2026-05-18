local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_WeekendLoginGiftItem_C = Base:Extend("UMG_Activity_WeekendLoginGiftItem_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_WeekendLoginGiftItem_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.HaveExpiredBtn, self.OnReceiveAwardBtnClick)
end

function UMG_Activity_WeekendLoginGiftItem_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveButtonListener(self.HaveExpiredBtn)
end

function UMG_Activity_WeekendLoginGiftItem_C:OnReceiveAwardBtnClick()
  self:InvokeParentFunc("OnItemSelected", true)
end

function UMG_Activity_WeekendLoginGiftItem_C:SetSignStage(stage)
  self.Text:SetText(tostring(stage))
end

function UMG_Activity_WeekendLoginGiftItem_C:SetRewards(rewards)
  local rewardIcons = {
    [1] = {
      self.Icon_9
    },
    [2] = {
      self.Icon_5,
      self.Icon_6
    },
    [3] = {
      self.Icon_3,
      self.Icon_4,
      self.Icon_7
    },
    [4] = {
      self.Icon,
      self.Icon_1,
      self.Icon_2,
      self.Icon_8
    }
  }
  local rewardCtrlGroup
  local rewardCnt = rewards and #rewards or 0
  if rewardCnt > 0 then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if rewardCnt >= 4 then
      rewardCtrlGroup = rewardIcons[4]
      self.Switcher:SetActiveWidgetIndex(0)
    elseif 3 == rewardCnt then
      rewardCtrlGroup = rewardIcons[3]
      self.Switcher:SetActiveWidgetIndex(1)
    elseif 2 == rewardCnt then
      rewardCtrlGroup = rewardIcons[2]
      self.Switcher:SetActiveWidgetIndex(2)
    else
      rewardCtrlGroup = rewardIcons[1]
      self.Switcher:SetActiveWidgetIndex(3)
    end
  else
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.rewardCtrlGroup = rewardCtrlGroup
  if rewardCtrlGroup then
    for _index, _ctrl in ipairs(rewardCtrlGroup) do
      local rewardItemData = rewards[_index]
      rewardItemData.callbackWhenSelect = _G.MakeWeakFunctor(self, self.OnStageAwardItemSelect)
      _ctrl:SetData(rewardItemData)
    end
  end
end

function UMG_Activity_WeekendLoginGiftItem_C:OnStageAwardItemSelect(_itemInst)
  if not _itemInst then
    return
  end
  local CurStageAwardSelectData = self.CurStageAwardSelectData
  if not CurStageAwardSelectData then
    CurStageAwardSelectData = _G.MakeWeakTable({}, "v")
    self.CurStageAwardSelectData = CurStageAwardSelectData
  end
  local curSelectItemInst = CurStageAwardSelectData.curSelectItemInst
  if curSelectItemInst and UE.UObject.IsValid(curSelectItemInst) then
    curSelectItemInst:SetSelect(false)
  end
  _itemInst:SetSelect(true)
  CurStageAwardSelectData.curSelectItemInst = _itemInst
end

function UMG_Activity_WeekendLoginGiftItem_C:SetRewardStatus(status, isExpired, tips)
  self.Text_Time:SetText(tips or "")
  if status == ActivityEnum.RewardStatus.UnAvailable then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_BG:SetActiveWidgetIndex(0)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Text:SetActiveWidgetIndex(0)
  elseif status == ActivityEnum.RewardStatus.Available then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_BG:SetActiveWidgetIndex(1)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Text:SetActiveWidgetIndex(1)
  elseif status == ActivityEnum.RewardStatus.Received then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_BG:SetActiveWidgetIndex(0)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local rewardCtrlGroup = self.rewardCtrlGroup
  if rewardCtrlGroup then
    local iconVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    if status == ActivityEnum.RewardStatus.Available then
      iconVisibility = UE4.ESlateVisibility.HitTestInvisible
    end
    for _, _ctrl in ipairs(rewardCtrlGroup) do
      _ctrl:SetVisibility(iconVisibility)
    end
  end
  self:SetClickable(status == ActivityEnum.RewardStatus.Available)
  local showExpiredBtn = isExpired and status == ActivityEnum.RewardStatus.UnAvailable
  if self.HaveExpiredBtn then
    self.HaveExpiredBtn:SetVisibility(showExpiredBtn and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_WeekendLoginGiftItem_C:SetupRedPoint(key, extraKey)
  self.RedPoint:EnableAnimation()
  self.RedPoint:SetupKey(key, extraKey)
end

function UMG_Activity_WeekendLoginGiftItem_C:PlayInAnimation()
  self:DelayPlayAnimation(self.In, false)
end

function UMG_Activity_WeekendLoginGiftItem_C:PlayRewardGetAnimation()
end

function UMG_Activity_WeekendLoginGiftItem_C:PlayRewardUnAvailableAnimation()
end

function UMG_Activity_WeekendLoginGiftItem_C:PlayRewardAvailableAnimation()
end

function UMG_Activity_WeekendLoginGiftItem_C:PlayRewardReceivedAnimation()
end

return UMG_Activity_WeekendLoginGiftItem_C
