local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ThisWeekClassSchedule_Item1_C = Base:Extend("UMG_ThisWeekClassSchedule_Item1_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_ThisWeekClassSchedule_Item1_C:OnConstruct()
  self:AddButtonListener(self.Btn, self.OnClicked)
  self.Btn.OnPressed:Add(self, self.OnBtnPressed)
  self.Btn.OnReleased:Add(self, self.OnBtnReleased)
end

function UMG_ThisWeekClassSchedule_Item1_C:OnDestruct()
  self.Btn.OnPressed:Clear()
  self.Btn.OnReleased:Clear()
  self:RemoveButtonListener(self.Btn)
end

function UMG_ThisWeekClassSchedule_Item1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Text_quantity:SetText(tostring(_data.score))
  self.Icon:SetPath(_data.itemIcon)
  self.Num:SetText("x" .. _data.itemNum)
  self:SetRewardStatus(_data.itemStatus)
  self:RefreshRedPoint(_data.itemStatus)
end

function UMG_ThisWeekClassSchedule_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
  end
end

function UMG_ThisWeekClassSchedule_Item1_C:SetRewardStatus(rewardStatus)
  self:StopAllAnimations()
  if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
    self.Switcher:SetActiveWidgetIndex(0)
    self:PlayAnimation(self.Normal)
  elseif rewardStatus == ActivityEnum.RewardStatus.Available then
    self.Switcher:SetActiveWidgetIndex(1)
    self:PlayAnimation(self.Achieve)
    self:PlayAnimation(self.Achieve_Loop, 0, 0)
  elseif rewardStatus == ActivityEnum.RewardStatus.Received then
    self.Switcher:SetActiveWidgetIndex(1)
    self:PlayAnimation(self.Reward_get)
  end
  self:RefreshRedPoint(rewardStatus)
end

function UMG_ThisWeekClassSchedule_Item1_C:RefreshRedPoint(rewardStatus)
  local data = self.data
  if not data then
    return
  end
  if data.redPointKey then
    if rewardStatus == ActivityEnum.RewardStatus.Available then
      self.redPointNew:SetupKey(data.redPointKey, data.redPointExtraKey)
    else
      self.redPointNew:SetupKey(0)
    end
  end
end

function UMG_ThisWeekClassSchedule_Item1_C:OpItem(opType, param1)
  if opType == ActivityEnum.ItemOpType.RewardStatusChange then
    self:SetRewardStatus(param1)
  end
end

function UMG_ThisWeekClassSchedule_Item1_C:OnClicked()
  local data = self.data
  if data then
    local handled = false
    if data.clickCallback then
      handled = data.clickCallback()
    end
    if not handled and data.showTips then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, data.itemId, data.itemType, false)
    end
  end
end

function UMG_ThisWeekClassSchedule_Item1_C:OnBtnPressed()
  self:StopAnimation(self.Press)
  self:StopAnimation(self.Up)
  self:PlayAnimation(self.Press)
end

function UMG_ThisWeekClassSchedule_Item1_C:OnBtnReleased()
  self:StopAnimation(self.Press)
  self:StopAnimation(self.Up)
  self:PlayAnimation(self.Up)
end

return UMG_ThisWeekClassSchedule_Item1_C
