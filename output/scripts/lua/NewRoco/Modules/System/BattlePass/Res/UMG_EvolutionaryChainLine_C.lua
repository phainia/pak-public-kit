local UMG_EvolutionaryChainLine_C = _G.NRCPanelBase:Extend("UMG_EvolutionaryChainLine_C")

function UMG_EvolutionaryChainLine_C:SetLine(length, angle)
  self:PlayAnimation(self.In)
  local size = self.Line1.Slot:GetSize()
  size.X = length
  self.Line1:SetRenderTransformAngle(angle)
  self.Line1.Slot:SetSize(size)
end

function UMG_EvolutionaryChainLine_C:PlayOutAnimation()
  self:PlayAnimation(self.Out)
end

function UMG_EvolutionaryChainLine_C:OnDeactive()
end

function UMG_EvolutionaryChainLine_C:OnAddEventListener()
end

return UMG_EvolutionaryChainLine_C
