require("UnLuaEx")
local UMG_Battle_CriticalNumber_C = NRCUmgClass:Extend("")

function UMG_Battle_CriticalNumber_C:SetNumber(value, isHealing, ignoreHealing)
  Log.Trace("UMG_Battle_CriticalNumber_C SetNumber:", value)
  if ignoreHealing then
    self.DMGNumber = value
  elseif isHealing then
    self.DMGNumber = "+" .. value
  else
    self.DMGNumber = "-" .. value
  end
end

return UMG_Battle_CriticalNumber_C
