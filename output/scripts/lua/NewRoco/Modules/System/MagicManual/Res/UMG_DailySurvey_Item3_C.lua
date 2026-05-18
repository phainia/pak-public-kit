local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DailySurvey_Item3_C = Base:Extend("UMG_DailySurvey_Item3_C")

function UMG_DailySurvey_Item3_C:OnConstruct()
end

function UMG_DailySurvey_Item3_C:OnDestruct()
end

function UMG_DailySurvey_Item3_C:SetReward(rewardList)
  self.List:InitGridView(rewardList)
end

function UMG_DailySurvey_Item3_C:PlayInAnim()
  if self:IsAnimationPlaying(self.out) then
  end
  self:PlayAnimation(self.In)
end

function UMG_DailySurvey_Item3_C:PlayOutAnim()
  if self:IsAnimationPlaying(self.In) then
  end
  self:PlayAnimation(self.Out)
end

function UMG_DailySurvey_Item3_C:OnAnimationFinished(aim)
  if aim == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif aim == self.In then
  end
end

function UMG_DailySurvey_Item3_C:OnDeactive()
end

return UMG_DailySurvey_Item3_C
