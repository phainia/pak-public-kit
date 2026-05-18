local UMG_Battle_DamageNumber_C = NRCUmgClass:Extend("")

function UMG_Battle_DamageNumber_C:SetNumber(value, isHealing, ignoreHealing)
  Log.Trace("UMG_Battle_DamageNumber_C SetNumber:", value)
  if ignoreHealing then
    self.DMGNumber:SetText(value)
  elseif isHealing then
    self.DMGNumber:SetText("+" .. value)
  else
    self.DMGNumber:SetText("-" .. value)
  end
end

function UMG_Battle_DamageNumber_C:SetIsDamage()
  self.DMGNumber:SetColorAndOpacity(UE4.FLinearColor(1, 0.66, 0.66, 1))
end

function UMG_Battle_DamageNumber_C:SetIsHealing()
end

return UMG_Battle_DamageNumber_C
