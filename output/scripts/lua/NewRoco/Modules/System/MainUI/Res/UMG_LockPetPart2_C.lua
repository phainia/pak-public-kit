local UMG_LockPetPart2_C = _G.NRCPanelBase:Extend("UMG_LockPetPart2_C")

function UMG_LockPetPart2_C:OnConstruct()
end

function UMG_LockPetPart2_C:OnDestruct()
end

function UMG_LockPetPart2_C:OnActive()
end

function UMG_LockPetPart2_C:OnDeactive()
end

function UMG_LockPetPart2_C:PlayOpenAnim()
  self:PlayAnimation(self.open)
end

function UMG_LockPetPart2_C:PlayLoopAnim()
  self:PlayAnimation(self.loop, 0, 0, 0)
end

function UMG_LockPetPart2_C:PlayCloseAnim()
  self:PlayAnimation(self.close)
end

function UMG_LockPetPart2_C:PlayLockAnim()
  self:StopAnimation(self.loop)
  self:StopAnimation(self.Lock_loop)
  self:PlayAnimation(self.Lock)
end

function UMG_LockPetPart2_C:PlayLockLoopAnim()
  self:PlayAnimation(self.Lock_loop, 0.0, 0)
end

function UMG_LockPetPart2_C:PlayLockCancelAnim()
  self:PlayAnimation(self.Lock_close)
end

function UMG_LockPetPart2_C:PlayClickAnim()
  self:PlayAnimation(self.click)
end

function UMG_LockPetPart2_C:OnAnimationFinished(anim)
  if anim == self.open then
    self:PlayLoopAnim()
  elseif anim == self.Lock then
    self:PlayLockLoopAnim()
  elseif anim == self.Lock_close then
    self:StopAnimation(self.Lock_loop)
    self:PlayLoopAnim()
  elseif anim == self.Uninteraction_Out then
    if self.isLockIn then
      self:PlayLockAnim()
    else
      self:PlayLockCancelAnim()
    end
  end
end

function UMG_LockPetPart2_C:StopAllAnim()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

function UMG_LockPetPart2_C:PlayUnInteractionIn()
  self.Pivot:SetRenderOpacity(1)
  self:PlayAnimation(self.Uninteraction_In)
end

function UMG_LockPetPart2_C:PlayUnInteractionOut(isLockIn)
  self.Pivot:SetRenderOpacity(1)
  self.isLockIn = isLockIn
  self:PlayAnimation(self.Uninteraction_Out)
end

return UMG_LockPetPart2_C
