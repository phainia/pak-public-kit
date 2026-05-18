local UMG_PVPcongratulation_C = _G.NRCPanelBase:Extend("UMG_PVPcongratulation_C")

function UMG_PVPcongratulation_C:OnActive()
  self:PlayAnimation(self.Congratulation)
end

function UMG_PVPcongratulation_C:OnDeactive()
end

function UMG_PVPcongratulation_C:OnAddEventListener()
end

function UMG_PVPcongratulation_C:OnLogin()
end

function UMG_PVPcongratulation_C:OnConstruct()
end

function UMG_PVPcongratulation_C:OnDestruct()
end

function UMG_PVPcongratulation_C:OnAnimationFinished(anim)
  if anim == self.Congratulation then
  end
end

return UMG_PVPcongratulation_C
