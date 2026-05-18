local UMG_BossTips_C = _G.NRCPanelBase:Extend("UMG_BossTips_C")

function UMG_BossTips_C:OnConstruct()
end

function UMG_BossTips_C:OnDestruct()
  self.tip = nil
end

function UMG_BossTips_C:OnActive(tip)
  self.tip = tip
  self:PlayAnimation(self.Anim)
end

function UMG_BossTips_C:OnAnimationFinished(Animation)
  if self.Anim == Animation then
    self.tip:MarkFinished()
    self:DoClose()
  end
end

function UMG_BossTips_C:OnDeactive()
  self.tip = nil
end

return UMG_BossTips_C
