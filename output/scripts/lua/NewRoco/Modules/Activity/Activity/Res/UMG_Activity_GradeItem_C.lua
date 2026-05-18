local Base = require("NewRoco.Modules.Activity.Activity.Res.UMG_Activity_StageAwardItem_C")
local UMG_Activity_GradeItem_C = Base:Extend("UMG_Activity_GradeItem_C")

function UMG_Activity_GradeItem_C:OnItemSelected(_bSelected)
  Base.OnItemSelected(self, _bSelected)
  if _bSelected then
    self:PlayAnimationImmediately(self.Click, false)
  end
end

function UMG_Activity_GradeItem_C:SetDescribe(desc)
end

function UMG_Activity_GradeItem_C:SetProgress(cur, total)
  self.Text_Describe:SetText(total)
  cur = cur or 0
  total = total or 0
  if cur >= total then
    self.Text_Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CA911CFF"))
  else
    self.Text_Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#423F6FFF"))
  end
end

function UMG_Activity_GradeItem_C:PlayInAnimation()
  self:DelayPlayAnimation(self.In, false)
end

function UMG_Activity_GradeItem_C:PlayRewardGetAnimation()
  self:TryStopAnimation(self.Ready_loop, true)
  self:TryPlayAnimation(self.Ready_get, false, 10)
end

function UMG_Activity_GradeItem_C:PlayRewardUnAvailableAnimation()
  self:TryPlayAnimation(self.Normal, false, 0)
end

function UMG_Activity_GradeItem_C:PlayRewardAvailableAnimation()
  self:TryPlayAnimation(self.Ready_loop, false, 0, true)
end

function UMG_Activity_GradeItem_C:PlayRewardReceivedAnimation()
  self:TryStopAnimation(self.Ready_loop, true)
  self:TryPlayAnimation(self.Get_normal)
end

function UMG_Activity_GradeItem_C:PlaySelectAnimation(_bSelected)
end

return UMG_Activity_GradeItem_C
