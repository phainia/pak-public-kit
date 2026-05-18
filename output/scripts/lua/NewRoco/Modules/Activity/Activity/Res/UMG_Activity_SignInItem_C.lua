local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_SignInItem_C = Base:Extend("UMG_Activity_SignInItem_C")

function UMG_Activity_SignInItem_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_Activity_SignInItem_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_SignInItem_C:PlayRewardGetAnimation()
  self:TryPlayAnimation(self.Reward_get, false, 10)
end

function UMG_Activity_SignInItem_C:PlayRewardUnAvailableAnimation()
  self:TryPlayAnimation(self.Reward_normal, false, 0)
end

function UMG_Activity_SignInItem_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Reward_ready, false, 0)
end

function UMG_Activity_SignInItem_C:PlayRewardReceivedAnimation()
  self:TryPlayAnimation(self.Get_loop)
end

function UMG_Activity_SignInItem_C:SetSignStage(stage)
  self.SignStage:SetText(stage)
end

function UMG_Activity_SignInItem_C:SetSignStageColor(color)
  self.SignStage:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
end

function UMG_Activity_SignInItem_C:SetRewardNum(num)
  self:SetNumSize(num)
  self.RewardNum:SetText("x" .. num)
end

function UMG_Activity_SignInItem_C:SetRewardNumColor(color)
  self.RewardNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
end

function UMG_Activity_SignInItem_C:SetRewardIcon(iconPath)
  self.Icon:SetPath(iconPath)
end

function UMG_Activity_SignInItem_C:SetupRedPoint(key, extraKey)
  self.redPointReward:EnableAnimation()
  self.redPointReward:SetupKey(key, extraKey)
end

function UMG_Activity_SignInItem_C:SetSwitcherActiveIndex(index)
  self.Switcher:SetActiveWidgetIndex(index)
end

function UMG_Activity_SignInItem_C:SetAlreadyReceived(_received)
  self.AlreadyPanel:SetVisibility(_received and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_SignInItem_C:SetNumSize(Count)
  local number = Count
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local Font = self.RewardNum.Font
  if length > 5 then
    Font.Size = 22
    self.RewardNum:SetFont(Font)
  end
end

return UMG_Activity_SignInItem_C
