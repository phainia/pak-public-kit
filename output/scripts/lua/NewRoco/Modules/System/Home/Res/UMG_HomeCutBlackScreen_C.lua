local UMG_HomeCutBlackScreen_C = _G.NRCPanelBase:Extend("UMG_HomeCutBlackScreen_C")

function UMG_HomeCutBlackScreen_C:OnActive(OnFadeInFinish, OnFadeOutFinish)
  self.OnFadeInFinish = OnFadeInFinish
  self.OnFadeOutFinish = OnFadeOutFinish
  _G.NRCAudioManager:PlaySound2DAuto(40008045, "UMG_HomeCutBlackScreen_C:OnActive")
  self:PlayAnimation(self.Transition_In)
end

function UMG_HomeCutBlackScreen_C:OnPcClose()
end

function UMG_HomeCutBlackScreen_C:OnDeactive()
end

function UMG_HomeCutBlackScreen_C:OnAddEventListener()
end

function UMG_HomeCutBlackScreen_C:DoFadeOut()
  if self.bDisableFadeout then
    return
  end
  if not self.bFadeInFinish then
    self.bEnabledFadeout = true
  else
    self:PlayAnimation(self.Transition_Out)
    self.bDisableFadeout = true
  end
end

function UMG_HomeCutBlackScreen_C:OnAnimationFinished(Anim)
  if Anim == self.Transition_In then
    if self.OnFadeInFinish then
      self.OnFadeInFinish()
    end
    self.bFadeInFinish = true
    if self.bEnabledFadeout and not self.bDisableFadeout then
      self:PlayAnimation(self.Transition_Out)
      self.bDisableFadeout = true
    end
  elseif Anim == self.Transition_Out then
    if self.OnFadeOutFinish then
      self.OnFadeOutFinish()
    end
    self:OnClose()
  end
end

return UMG_HomeCutBlackScreen_C
