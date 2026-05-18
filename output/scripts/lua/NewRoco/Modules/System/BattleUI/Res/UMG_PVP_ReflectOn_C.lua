local UMG_PVP_ReflectOn_C = _G.NRCPanelBase:Extend("UMG_PVP_ReflectOn_C")

function UMG_PVP_ReflectOn_C:OnActive()
end

function UMG_PVP_ReflectOn_C:OnDeactive()
end

function UMG_PVP_ReflectOn_C:OnAddEventListener()
end

function UMG_PVP_ReflectOn_C:OnAnimationStarted(Animation)
  if Animation == self.In then
    self:PlayAnimation(self.HeidianLoop, nil, 999999)
  end
end

function UMG_PVP_ReflectOn_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    self:PlayAnimation(self.Loop, nil, 999999)
  end
end

return UMG_PVP_ReflectOn_C
