local UMG_Compass_Sneak_C = _G.NRCPanelBase:Extend("UMG_Compass_Sneak_C")

function UMG_Compass_Sneak_C:ChangeTo(state)
  if 2 == state then
    self:StopAnimation(self.Out)
    self:PlayAnimation(self.In)
    self:PlayAnimation(self.Loop, 0.0, 0)
  elseif 3 == state then
    self:StopAnimation(self.In)
    self:StopAnimation(self.Loop)
    self:PlayAnimation(self.Out)
  end
end

return UMG_Compass_Sneak_C
