local UMG_DebugTips_C = _G.NRCPanelBase:Extend("UMG_DebugTips_C")

function UMG_DebugTips_C:OnActive(Text)
  self:PlayTweenIn(Text)
end

function UMG_DebugTips_C:PlayTweenIn(Text)
  self:StopAllAnimations()
  self:PlayAnimation(self.TweenIn)
  self.Text_Tips:SetText(Text)
end

function UMG_DebugTips_C:OnDeactive()
  self:CancelDelay()
end

function UMG_DebugTips_C:OnAddEventListener()
end

function UMG_DebugTips_C:OnAnimationFinished(Anim)
  if Anim == self.TweenIn then
    self:DelaySeconds(0.5, function()
      self:PlayAnimation(self.TweenOut)
    end)
  elseif Anim == self.TweenOut then
    self:DoClose()
  end
end

return UMG_DebugTips_C
