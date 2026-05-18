local UMG_MainPetHeadHp_C = _G.NRCViewBase:Extend("UMG_MainPetHeadHp_C")

function UMG_MainPetHeadHp_C:Construct()
  self._startModify = 0.02
  self._endModify = 0.98
end

function UMG_MainPetHeadHp_C:HideAll()
  self.hpProgress_yellow:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.hpProgress_green:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.hpProgress_red:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_MainPetHeadHp_C:SetHP(_hpPercent)
  local correctPercent = _hpPercent * (self._endModify - self._startModify) + self._startModify
  self:HideAll()
  if _hpPercent < 0.2 then
    self.hpProgress_red:SetVisibility(UE4.ESlateVisibility.Visible)
    self.hpProgress_red:GetDynamicMaterial():SetScalarParameterValue("Baifenbi", correctPercent)
  elseif _hpPercent < 0.5 then
    self.hpProgress_yellow:SetVisibility(UE4.ESlateVisibility.Visible)
    self.hpProgress_yellow:GetDynamicMaterial():SetScalarParameterValue("Baifenbi", correctPercent)
  else
    self.hpProgress_green:SetVisibility(UE4.ESlateVisibility.Visible)
    self.hpProgress_green:GetDynamicMaterial():SetScalarParameterValue("Baifenbi", correctPercent)
  end
end

function UMG_MainPetHeadHp_C:GetColor(_hpPercent)
  if _hpPercent < 0.2 then
    return UE4.FLinearColor(0.799103, 0.135633, 0.030713, 1)
  elseif _hpPercent < 0.5 then
    return UE4.FLinearColor(0.913099, 0.658375, 0.119538, 1)
  else
    return UE4.FLinearColor(0.208637, 0.577581, 0.045186, 1)
  end
end

return UMG_MainPetHeadHp_C
