local UMG_BlackBarAnimation_C = _G.NRCPanelBase:Extend("UMG_BlackBarAnimation_C")

function UMG_BlackBarAnimation_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_BlackBarAnimation_C:OnActive()
end

function UMG_BlackBarAnimation_C:OnDeactive()
end

function UMG_BlackBarAnimation_C:OnAddEventListener()
  HomeIndoorSandbox:RegisterEvent(HomeIndoorSandbox.Event.OnReqCloseBlackBarAnimation, self, self.OnReqClose)
end

function UMG_BlackBarAnimation_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  end
end

function UMG_BlackBarAnimation_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:PlayAnimation(self.Out)
  HomeIndoorSandbox:UnRegisterEvent(HomeIndoorSandbox.Event.OnReqCloseBlackBarAnimation, self)
end

return UMG_BlackBarAnimation_C
