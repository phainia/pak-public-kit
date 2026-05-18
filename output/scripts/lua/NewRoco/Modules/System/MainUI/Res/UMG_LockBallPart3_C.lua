local UMG_LockBallPart3_C = _G.NRCPanelBase:Extend("UMG_LockBallPart3_C")

function UMG_LockBallPart3_C:OnConstruct()
end

function UMG_LockBallPart3_C:OnDestruct()
end

function UMG_LockBallPart3_C:OnActive()
end

function UMG_LockBallPart3_C:OnDeactive()
end

function UMG_LockBallPart3_C:PlayOpenAnim()
  self:PlayAnimation(self.open)
end

function UMG_LockBallPart3_C:PlayLoopAnim()
  self:PlayAnimation(self.loop, 0, 0)
end

function UMG_LockBallPart3_C:PlayCloseAnim()
  self:PlayAnimation(self.close)
end

function UMG_LockBallPart3_C:PlayClickAnim()
  self:PlayAnimation(self.click)
end

function UMG_LockBallPart3_C:PlayLockAnim()
  Log.Debug("UMG_LockBallPart3_C:PlayLockAnim")
  self:StopAnimation(self.loop)
  self:StopAnimation(self.lock_loop)
  self:PlayAnimation(self.lock)
end

function UMG_LockBallPart3_C:PlayLockLoopAnim()
  self:PlayAnimation(self.lock_loop, 0, 0)
end

function UMG_LockBallPart3_C:PlayLockCancelAnim()
  self:PlayAnimation(self.lock_cancle)
end

function UMG_LockBallPart3_C:OnAnimationFinished(anim)
  if anim == self.open then
    self:PlayLoopAnim()
  elseif anim == self.lock then
    self:PlayLockLoopAnim()
  elseif anim == self.lock_cancle then
    self:StopAnimation(self.lock_loop)
    self:PlayLoopAnim()
  end
end

function UMG_LockBallPart3_C:StopAllAnim()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

function UMG_LockBallPart3_C:StopAllLoopAnim()
  self:StopAnimation(self.loop)
  self:StopAnimation(self.lock_loop)
end

return UMG_LockBallPart3_C
