local UMG_LockPetPart1_C = _G.NRCPanelBase:Extend("UMG_LockPetPart1_C")

function UMG_LockPetPart1_C:OnConstruct()
end

function UMG_LockPetPart1_C:OnDestruct()
end

function UMG_LockPetPart1_C:OnActive()
end

function UMG_LockPetPart1_C:OnDeactive()
end

function UMG_LockPetPart1_C:PlayOpenAnim()
  self:PlayAnimation(self.open)
end

function UMG_LockPetPart1_C:PlayCloseAnim()
  self:PlayAnimation(self.close)
end

function UMG_LockPetPart1_C:PlayLoopAnim()
  self:PlayAnimation(self.loop, 0.0, 0)
end

function UMG_LockPetPart1_C:PlayLockAnim()
  self:StopAnimation(self.loop)
  self:StopAnimation(self.Lock_loop)
  self:PlayAnimation(self.Lock)
end

function UMG_LockPetPart1_C:PlayLockLoopAnim()
  self:PlayAnimation(self.Lock_loop, 0.0, 0)
end

function UMG_LockPetPart1_C:PlayLockCancelAnim()
  self:PlayAnimation(self.Lock_close)
end

function UMG_LockPetPart1_C:PlayClickAnim()
  self:PlayAnimation(self.click)
end

function UMG_LockPetPart1_C:OnAnimationFinished(anim)
  if anim == self.open then
    self:PlayLoopAnim()
  elseif anim == self.Lock then
    self:PlayLockLoopAnim()
  elseif anim == self.Lock_close then
    self:StopAnimation(self.Lock_loop)
    self:PlayLoopAnim()
  end
end

function UMG_LockPetPart1_C:StopAllAnim()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

return UMG_LockPetPart1_C
