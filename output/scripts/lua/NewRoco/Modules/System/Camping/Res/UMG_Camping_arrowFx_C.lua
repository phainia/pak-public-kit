local UMG_Camping_arrowFx_C = _G.NRCPanelBase:Extend("UMG_Camping_arrowFx_C")

function UMG_Camping_arrowFx_C:OnConstruct()
  self:BeginLoop()
end

function UMG_Camping_arrowFx_C:OnDestruct()
end

function UMG_Camping_arrowFx_C:OnActive()
end

function UMG_Camping_arrowFx_C:OnDeactive()
end

function UMG_Camping_arrowFx_C:BeginLoop()
  self.isLooping = true
  self:PlayAnimation(self.loop)
end

function UMG_Camping_arrowFx_C:OnAnimationFinished(Animation)
  if Animation == self.loop and self.isLooping then
    self:PlayAnimation(self.loop)
  end
end

return UMG_Camping_arrowFx_C
