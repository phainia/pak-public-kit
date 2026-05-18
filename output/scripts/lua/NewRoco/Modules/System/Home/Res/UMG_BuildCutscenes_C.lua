local UMG_BuildCutscenes_C = _G.NRCPanelBase:Extend("UMG_BuildCutscenes_C")

function UMG_BuildCutscenes_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_BuildCutscenes_C:OnActive()
end

function UMG_BuildCutscenes_C:OnDeactive()
end

function UMG_BuildCutscenes_C:OnAddEventListener()
  HomeIndoorSandbox:RegisterEvent(HomeIndoorSandbox.Event.OnReqCloseBuildCutAnimation, self, self.OnReqClose)
end

function UMG_BuildCutscenes_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  elseif Anim == self.In then
    self:DelaySeconds(1, function()
      self:OnReqClose()
    end)
  end
end

function UMG_BuildCutscenes_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:PlayAnimation(self.Out)
  HomeIndoorSandbox:UnRegisterEvent(HomeIndoorSandbox.Event.OnReqCloseBuildCutAnimation, self)
end

return UMG_BuildCutscenes_C
