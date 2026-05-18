local UMG_Common_Tutorial_C = _G.NRCPanelBase:Extend("UMG_Common_Tutorial_C")

function UMG_Common_Tutorial_C:OnActive()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Point_R)
end

function UMG_Common_Tutorial_C:OnDeactive()
  self:Hide()
end

function UMG_Common_Tutorial_C:OnEnable()
  self:OnActive()
end

function UMG_Common_Tutorial_C:OnDisable()
  self:Hide()
end

function UMG_Common_Tutorial_C:OnAddEventListener()
end

function UMG_Common_Tutorial_C:Hide()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Common_Tutorial_C:OnAnimationFinished(Anim)
  if Anim == self.Point_R then
    self:PlayAnimation(self.Point_R_loop, 0, 9999)
  end
end

return UMG_Common_Tutorial_C
