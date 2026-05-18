local UMG_LightMagic_C = _G.NRCPanelBase:Extend("UMG_LightMagic_C")

function UMG_LightMagic_C:OnActive()
end

function UMG_LightMagic_C:OnDeactive()
end

function UMG_LightMagic_C:OnShow()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
    self:PlayAnimation(self.In)
  end
end

function UMG_LightMagic_C:OnCancel(CancelType)
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
    self:PlayAnimation(self.Out)
  end
end

function UMG_LightMagic_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self:PlayAnimationTimeRange(self.In, 0.25, 1, 999)
  end
end

return UMG_LightMagic_C
