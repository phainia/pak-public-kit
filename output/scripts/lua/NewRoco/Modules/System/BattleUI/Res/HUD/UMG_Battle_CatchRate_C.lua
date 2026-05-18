require("UnLuaEx")
local UMG_Battle_CatchRate_C = NRCUmgClass:Extend("")

function UMG_Battle_CatchRate_C:ShowRate(rate)
  rate = (rate > 1 and 1 or rate < 0 and 0 or rate) * 100
  if rate <= 30 then
    self._CatchRate:SetColorAndOpacity(self.RedColor)
  else
    self._CatchRate:SetColorAndOpacity(self.YellowColor)
  end
  self._CatchRate:SetText(string.format("%d%%", math.floor(rate)))
end

return UMG_Battle_CatchRate_C
