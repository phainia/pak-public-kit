local UMG_PetHeadHp_C = _G.NRCViewBase:Extend("UMG_PetHeadHp_C")

function UMG_PetHeadHp_C:Construct()
  _G.NRCViewBase.Construct(self)
  self._startModify = 0.02
  self._endModify = 0.99
end

function UMG_PetHeadHp_C:SetHP(_hpPercent)
  local correctPercent = _hpPercent * (self._endModify - self._startModify) + self._startModify
  local dynamicMaterialGreen = self.hpProgressGreen:GetDynamicMaterial()
  local dynamicMaterialRed = self.hpProgressRed:GetDynamicMaterial()
  local dynamicMaterialYellow = self.hpProgressYellow:GetDynamicMaterial()
  if dynamicMaterialGreen then
    dynamicMaterialGreen:SetScalarParameterValue("Baifenbi", correctPercent)
  end
  if dynamicMaterialRed then
    dynamicMaterialRed:SetScalarParameterValue("Baifenbi", correctPercent)
  end
  if dynamicMaterialYellow then
    dynamicMaterialYellow:SetScalarParameterValue("Baifenbi", correctPercent)
  end
  self:setActive(self.hpProgressGreen, _hpPercent >= 0.5)
  self:setActive(self.hpProgressYellow, _hpPercent >= 0.2 and _hpPercent < 0.5)
  self:setActive(self.hpProgressRed, _hpPercent < 0.2)
end

function UMG_PetHeadHp_C:GetColor(_hpPercent)
  if _hpPercent < 0.2 then
    return UE4.FLinearColor(1, 0.066626, 0.066626, 1)
  elseif _hpPercent < 0.5 then
    return UE4.FLinearColor(1, 0.617207, 0.016807, 1)
  else
    return UE4.FLinearColor(0.043735, 0.514918, 0.040915, 1)
  end
end

function UMG_PetHeadHp_C:setActive(_uiItem, _isShow)
  if _uiItem then
    if _isShow then
      _uiItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      _uiItem:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

return UMG_PetHeadHp_C
