local UMG_Pass_Select_Light_C = _G.NRCPanelBase:Extend("UMG_Pass_Select_Light_C")

function UMG_Pass_Select_Light_C:PlayLoop()
  self:PlayAnimation(self.Loop, 0, 0)
end

function UMG_Pass_Select_Light_C:StopLoop()
  self:StopAnimation(self.Loop)
end

return UMG_Pass_Select_Light_C
