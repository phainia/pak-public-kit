local UMG_Tracking_C = _G.NRCPanelBase:Extend("UMG_Tracking_C")

function UMG_Tracking_C:OnActive()
end

function UMG_Tracking_C:OnDeactive()
end

function UMG_Tracking_C:OnAddEventListener()
end

function UMG_Tracking_C:OnConstruct()
end

function UMG_Tracking_C:OnDestruct()
end

function UMG_Tracking_C:OnEnable()
  self:PlayAnimation(self.TraceStart)
end

function UMG_Tracking_C:OnAnimationFinished(anim)
  if anim == self.TraceStart then
    self:PlayAnimation(self.TraceLoop, 0, 0)
  end
end

return UMG_Tracking_C
