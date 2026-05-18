require("UnLuaEx")
local BP_NumericStepper_C = NRCClass()

function BP_NumericStepper_C:Construct()
  self._currValue = 0
  self._maxValue = 0
  self._minValue = 0
  self._caller = nil
  self._stepSize = 1
  self:_AddListeners()
  self.OnValueChanged = nil
end

function BP_NumericStepper_C:_AddListeners()
  self.BtnMinus.OnClicked:Add(self, self._OnBtnMinusClick)
  self.BtnPlus.OnClicked:Add(self, self._OnBtnPlusClick)
  self.TxtNumber.OnTextChanged:Add(self, self._OnTextChanged)
  self.TxtNumber.OnTextCommitted:Add(self, self._OnTextCommitted)
end

function BP_NumericStepper_C:SetCaller(caller)
  self._caller = caller
end

function BP_NumericStepper_C:_OnTextChanged(txtContent)
  if not tonumber(txtContent) or string.len(txtContent) <= 0 then
    self.TxtNumber:SetText(self._currValue)
  else
    self.TxtNumber:SetText(tonumber(txtContent))
  end
end

function BP_NumericStepper_C:_OnTextCommitted(txtContent, commitMethod)
  Log.Debug("commit", txtContent, commitMethod)
  local num = tonumber(txtContent)
  local finalNum = math.clamp(num, self._minValue, self._maxValue)
  self.TxtNumber:SetText(finalNum)
  local delta = finalNum - self._currValue
  self._currValue = finalNum
  if self.OnValueChanged then
    tcall(self._caller, self.OnValueChanged, delta)
  end
end

function BP_NumericStepper_C:_OnBtnMinusClick()
  _G.NRCAudioManager:PlaySound2DAuto(self.AudioId, "BP_NumericStepper_C:_OnBtnMinusClick")
  self._currValue = self._currValue - self._stepSize
  self._currValue = math.clamp(self._currValue, self._minValue, self._maxValue)
  self:_RefreshView()
  if self.OnValueChanged then
    tcall(self._caller, self.OnValueChanged, -self._stepSize)
  end
end

function BP_NumericStepper_C:_OnBtnPlusClick()
  _G.NRCAudioManager:PlaySound2DAuto(self.AudioId, "BP_NumericStepper_C:_OnBtnMinusClick")
  self._currValue = self._currValue + self._stepSize
  self._currValue = math.clamp(self._currValue, self._minValue, self._maxValue)
  self:_RefreshView()
  if self.OnValueChanged then
    tcall(self._caller, self.OnValueChanged, self._stepSize)
  end
end

function BP_NumericStepper_C:_RemoveListeners()
  self.BtnMinus.OnClicked:Remove(self, self._OnBtnMinusClick)
  self.BtnPlus.OnClicked:Remove(self, self._OnBtnPlusClick)
  self.TxtNumber.OnTextChanged:Remove(self, self._OnTextChanged)
  self.TxtNumber.OnTextCommitted:Remove(self, self._OnTextCommitted)
end

function BP_NumericStepper_C:SetCurrentValue(value, needNotify)
  self._currValue = math.clamp(value, self._minValue, self._maxValue)
  if needNotify and self.OnValueChanged then
    tcall(self._caller, self.OnValueChanged, self._stepSize)
  end
  self:_RefreshView()
end

function BP_NumericStepper_C:GetCurrentValue()
  return self._currValue
end

function BP_NumericStepper_C:SetMaxValue(maxValue)
  self._maxValue = maxValue
  self._currValue = math.clamp(self._currValue, self._minValue, self._maxValue)
  self:_RefreshView()
end

function BP_NumericStepper_C:SetMinValue(minValue)
  self._minValue = minValue
  self._currValue = math.clamp(self._currValue, self._minValue, self._maxValue)
  self:_RefreshView()
end

function BP_NumericStepper_C:SetStepSize(stepSize)
  if stepSize <= 0 then
    return
  end
  self._stepSize = stepSize
end

function BP_NumericStepper_C:_RefreshView()
  if self._minValue >= self._maxValue then
    self.BtnPlus:SetIsEnabled(false)
    self.BtnMinus:SetIsEnabled(false)
  else
    if self._currValue >= self._maxValue then
      self.BtnPlus:SetIsEnabled(false)
    else
      self.BtnPlus:SetIsEnabled(true)
    end
    if self._currValue <= self._minValue then
      self.BtnMinus:SetIsEnabled(false)
    else
      self.BtnMinus:SetIsEnabled(true)
    end
  end
  Log.Debug("set current value", self._currValue)
  self.TxtNumber:SetText(self._currValue)
end

function BP_NumericStepper_C:Destruct()
  self:_RemoveListeners()
end

return BP_NumericStepper_C
