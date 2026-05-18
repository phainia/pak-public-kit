local UMG_CZ_dianji_C = _G.NRCPanelBase:Extend("UMG_CZ_dianji_C")

function UMG_CZ_dianji_C:Reset()
  _G.DelayManager:DelaySeconds(0.85, function()
    self:StopAnimation(self.ANI)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end)
end

return UMG_CZ_dianji_C
