local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_FightItem_C = Base:Extend("UMG_Activity_FightItem_C")

function UMG_Activity_FightItem_C:OnConstruct()
end

function UMG_Activity_FightItem_C:OnDestruct()
end

function UMG_Activity_FightItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_Activity_FightItem_C:SetInfo()
  local Content
  local ActivityType = self.data:GetActivityType()
  self.Ordinary:SetPath(self.data.SecondTabIcon)
  self.IconSelect:SetPath(self.data.SecondTabIcon)
  if ActivityType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    Content = string.format("%d/%d", self.data:GetFinishNPCChallengeEventSchedule(), self.data:GetNPCChallengeEventStarNum())
  elseif ActivityType == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    Content = string.format("%d/%d", self.data:GetFinishBossChallengeEventSchedule(), self.data:GetNPCChallengeEventStarNum())
  elseif ActivityType == Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT then
    self.NRCImage_0:SetPath("PaperSprite'/Game/NewRoco/Modules/System/WeeklyChallengeBattle/Raw/Frames/img_CheerIcon1_png.img_CheerIcon1_png'")
    self.NRCImage_0.Brush.ImageSize = UE.FVector2D(36, 37)
    Content = string.format("%d/%d", self.data:GetFinishWeeklyChallengeEventSchedule(), self.data:GetWeeklyChallengeEventStarNum())
  end
  self.Text_Content_1:SetText(Content)
  self:IsShowSandClock(false)
end

function UMG_Activity_FightItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:DoCmd(ActivityModuleCmd.SelectCyclicalChallengeTab, self.data)
    self:StopAllAnimations()
    self:PlayAnimation(self.select1)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_Activity_FightItem_C:IsShowSandClock(_IsShow)
  if _IsShow then
    self.SandClock:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SandClock_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.SandClock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SandClock_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_FightItem_C:OnAnimationFinished(Anim)
  if self.select1 == Anim then
    self:PlayAnimation(self.select_loop, 0, 999999)
  end
end

function UMG_Activity_FightItem_C:OnDeactive()
end

return UMG_Activity_FightItem_C
