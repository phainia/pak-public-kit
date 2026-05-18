local UMG_LockBallPart2_C = _G.NRCPanelBase:Extend("UMG_LockBallPart2_C")

function UMG_LockBallPart2_C:OnConstruct()
end

function UMG_LockBallPart2_C:OnDestruct()
end

function UMG_LockBallPart2_C:OnActive()
end

function UMG_LockBallPart2_C:OnDeactive()
end

function UMG_LockBallPart2_C:PlayOpenAnim()
  self:PlayAnimation(self.open)
end

function UMG_LockBallPart2_C:PlayLoopAnim()
  self:PlayAnimation(self.loop, 0.0, 0)
end

function UMG_LockBallPart2_C:PlayCloseAnim()
  self:PlayAnimation(self.close)
end

function UMG_LockBallPart2_C:PlayLockAnim()
  self:StopAnimation(self.loop)
  self:StopAnimation(self.Lock_loop)
  self:PlayAnimation(self.Lock)
end

function UMG_LockBallPart2_C:PlayLockLoopAnim()
  self:PlayAnimation(self.Lock_loop, 0.0, 0)
end

function UMG_LockBallPart2_C:PlayLockCancelAnim()
  self:PlayAnimation(self.Lock_cancle)
end

function UMG_LockBallPart2_C:PlayClickAnim()
  self:PlayAnimation(self.click)
end

function UMG_LockBallPart2_C:OnAnimationFinished(anim)
  if anim == self.open then
    self:PlayLoopAnim()
  elseif anim == self.Lock then
    self:PlayLockLoopAnim()
  elseif anim == self.Lock_cancle then
    self:StopAnimation(self.Lock_loop)
    self:PlayLoopAnim()
  end
end

function UMG_LockBallPart2_C:StopAllAnim()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

function UMG_LockBallPart2_C:StopAllLoopAnim()
  self:StopAnimation(self.loop)
  self:StopAnimation(self.Lock_loop)
end

function UMG_LockBallPart2_C:SetAimColor(bCatch)
  if bCatch then
    self.left:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
    self.right:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
    self.up:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
    self.down:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
  else
    self.left:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ff0000ff"))
    self.right:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ff0000ff"))
    self.up:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ff0000ff"))
    self.down:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ff0000ff"))
  end
end

function UMG_LockBallPart2_C:SetLockColor(color)
  self.left:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  self.right:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  self.up:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
  self.down:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color))
end

return UMG_LockBallPart2_C
