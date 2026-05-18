local UMG_PetEvolutionProp2Temple_C = _G.NRCViewBase:Extend("UMG_PetEvolutionProp2Temple_C")

function UMG_PetEvolutionProp2Temple_C:OnConstruct()
end

function UMG_PetEvolutionProp2Temple_C:OnDestruct()
  Log.Debug("UMG_PetEvolutionProp2Temple_C OnDestruct")
  self.uiData = nil
end

function UMG_PetEvolutionProp2Temple_C:SetTitle(_title)
  self.textTitle:SetText(_title or "")
end

function UMG_PetEvolutionProp2Temple_C:SetProp(_value1, _value2)
  self.textValue1:SetText(_value1 or "0")
  if _value1 and _value2 then
    local value = _value2
    if _value1 > value then
      value = _value1
    end
    self.textValue2:SetText(string.format("<evo>%d</>", value))
    self:setActive(self.textValue2, _value1 < value)
    self:setActive(self.iconUp, _value1 < value)
    self:setActive(self.iconDown, _value1 > value)
  else
    self:setActive(self.textValue2, false)
    self:setActive(self.iconUp, false)
    self:setActive(self.iconDown, false)
  end
end

function UMG_PetEvolutionProp2Temple_C:setActive(_uiItem, _isShow)
  if _uiItem then
    if _isShow then
      _uiItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      _uiItem:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

return UMG_PetEvolutionProp2Temple_C
