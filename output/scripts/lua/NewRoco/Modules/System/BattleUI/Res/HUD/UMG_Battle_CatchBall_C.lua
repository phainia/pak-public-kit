local UMG_Battle_CatchBall_C = _G.NRCPanelBase:Extend("UMG_Battle_CatchBall_C")

function UMG_Battle_CatchBall_C:OnConstruct()
  self.bIsShining = false
end

function UMG_Battle_CatchBall_C:OnDestruct()
end

function UMG_Battle_CatchBall_C:OnActive()
end

function UMG_Battle_CatchBall_C:OnDeactive()
end

function UMG_Battle_CatchBall_C:SetCatchBallLevel(CatchBallLevel)
  if 1 == CatchBallLevel then
    self.ShiningIcon:SetPath(_G.UEPath.CATCH_BALL_LEVEL_1)
  elseif 2 == CatchBallLevel then
    self.ShiningIcon:SetPath(_G.UEPath.CATCH_BALL_LEVEL_2)
  elseif 3 == CatchBallLevel then
    self.ShiningIcon:SetPath(_G.UEPath.CATCH_BALL_LEVEL_3)
  end
end

function UMG_Battle_CatchBall_C:TurnToNormal(bImmediate)
  self:StopAllAnimations()
  if not self.bIsShining then
    self:PlayAnimation(self.normal)
  elseif bImmediate then
    self:PlayAnimation(self.normal)
  else
    self:PlayAnimation(self.change2)
  end
  self.bIsShining = false
end

function UMG_Battle_CatchBall_C:TurnToShining(bImmediate)
  self:StopAllAnimations()
  if self.bIsShining then
    self:PlayAnimation(self.shining)
  elseif bImmediate then
    self:PlayAnimation(self.shining)
  else
    self:PlayAnimation(self.change1)
  end
  self.bIsShining = true
end

return UMG_Battle_CatchBall_C
