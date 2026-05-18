local UMG_AppearanceBlackBg_C = _G.NRCPanelBase:Extend("UMG_AppearanceBlackBg_C")

function UMG_AppearanceBlackBg_C:OnActive()
  self:PlayAnimation(self.In)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
end

function UMG_AppearanceBlackBg_C:OnDeactive()
end

function UMG_AppearanceBlackBg_C:OnAddEventListener()
end

function UMG_AppearanceBlackBg_C:OnConstruct()
end

function UMG_AppearanceBlackBg_C:OnDestruct()
end

function UMG_AppearanceBlackBg_C:StopLoopAnim()
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function UMG_AppearanceBlackBg_C:OnAnimationFinished(anim)
  if anim == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    self:PlayAnimation(self.Loop)
  elseif anim == self.Loop then
    self:PlayAnimation(self.Out)
  elseif anim == self.Out then
    self:DoClose()
  end
end

return UMG_AppearanceBlackBg_C
