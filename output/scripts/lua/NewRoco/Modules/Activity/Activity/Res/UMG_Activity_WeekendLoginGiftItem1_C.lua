local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_WeekendLoginGiftItem1_C = Base:Extend("UMG_Activity_WeekendLoginGiftItem1_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_WeekendLoginGiftItem1_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.ReceiveAwardBtn.btnLevelUp, self.OnReceiveAwardBtnClick)
  self:AddButtonListener(self.HaveExpiredBtn, self.OnReceiveAwardBtnClick)
  self:SetClickable(false)
end

function UMG_Activity_WeekendLoginGiftItem1_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveButtonListener(self.ReceiveAwardBtn.btnLevelUp)
  self:RemoveButtonListener(self.HaveExpiredBtn)
end

function UMG_Activity_WeekendLoginGiftItem1_C:OnReceiveAwardBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Activity_WeekendLoginGiftItem1_C:OnReceiveAwardBtnClick")
  self:InvokeParentFunc("OnItemSelected", true)
end

function UMG_Activity_WeekendLoginGiftItem1_C:SetSignStage(stage)
  self.Text:SetText(tostring(stage))
end

function UMG_Activity_WeekendLoginGiftItem1_C:SetRewards(rewards)
  local rewardIcons = {}
  for _, reward in ipairs(rewards) do
    local iconData = {}
    iconData.itemType = reward.itemType
    iconData.itemId = reward.itemId
    iconData.itemNum = reward.itemNum
    iconData.bShowNum = true
    iconData.bShowTip = true
    table.insert(rewardIcons, iconData)
  end
  self.ItemGridView:InitGridView(rewardIcons)
end

function UMG_Activity_WeekendLoginGiftItem1_C:SetRewardStatus(status, isExpired, tips)
  self.Text_Time:SetText(tips or "")
  if status == ActivityEnum.RewardStatus.UnAvailable then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Text:SetActiveWidgetIndex(0)
  elseif status == ActivityEnum.RewardStatus.Available then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Text:SetActiveWidgetIndex(1)
  elseif status == ActivityEnum.RewardStatus.Received then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher_Text:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local showExpiredBtn = isExpired and status == ActivityEnum.RewardStatus.UnAvailable
  if self.HaveExpiredBtn then
    self.HaveExpiredBtn:SetVisibility(showExpiredBtn and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_WeekendLoginGiftItem1_C:SetupRedPoint(key, extraKey)
  self.RedPoint:EnableAnimation()
  self.RedPoint:SetupKey(key, extraKey)
end

function UMG_Activity_WeekendLoginGiftItem1_C:PlayInAnimation()
  self:DelayPlayAnimation(self.In, false)
end

function UMG_Activity_WeekendLoginGiftItem1_C:PlayRewardGetAnimation()
  self:TryPlayAnimation(self.Get, false, 10)
end

function UMG_Activity_WeekendLoginGiftItem1_C:PlayRewardUnAvailableAnimation()
end

function UMG_Activity_WeekendLoginGiftItem1_C:PlayRewardAvailableAnimation()
end

function UMG_Activity_WeekendLoginGiftItem1_C:PlayRewardReceivedAnimation()
end

return UMG_Activity_WeekendLoginGiftItem1_C
