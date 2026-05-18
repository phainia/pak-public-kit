local UMG_AntiAddiction_PullDown_C = _G.NRCPanelBase:Extend("UMG_AntiAddiction_PullDown_C")

function UMG_AntiAddiction_PullDown_C:OnConstruct()
end

function UMG_AntiAddiction_PullDown_C:OnDestruct()
end

function UMG_AntiAddiction_PullDown_C:OnActive(_instruction)
  self.data = _instruction
  self.ContentText:SetText(self.data.msg)
  self:PlayAnimation(self.open)
end

function UMG_AntiAddiction_PullDown_C:OnDeactive()
end

function UMG_AntiAddiction_PullDown_C:OnAddEventListener()
end

function UMG_AntiAddiction_PullDown_C:OnAnimationFinished(Animation)
  if Animation == self.open then
    self:DelaySeconds(4, function()
      self:PlayAnimation(self.close)
    end)
  elseif Animation == self.close then
    self:DoClose()
  end
end

return UMG_AntiAddiction_PullDown_C
