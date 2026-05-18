local UMG_Camping_FontFX_C = _G.NRCPanelBase:Extend("UMG_Camping_FontFX_C")

function UMG_Camping_FontFX_C:OnConstruct()
end

function UMG_Camping_FontFX_C:OnDestruct()
end

function UMG_Camping_FontFX_C:OnActive()
end

function UMG_Camping_FontFX_C:OnDeactive()
end

function UMG_Camping_FontFX_C:PlayChangeAnimation(caller, callback)
  self.caller = caller
  self.callback = callback
  self:PlayAnimation(self.change)
end

function UMG_Camping_FontFX_C:OnAnimationFinished(Animation)
  if Animation == self.change and self.callback and self.caller then
    self.callback(self.caller)
    self.callback = nil
    self.caller = nil
  end
end

return UMG_Camping_FontFX_C
