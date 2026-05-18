local NRCCommonAddSubtractData = NRCClass:Extend("NRCCommonAddSubtractData")

function NRCCommonAddSubtractData:Ctor()
  NRCClass.Ctor(self)
  self.AddBtnHandler = nil
  self.AddBtnPressedHandler = nil
  self.AddBtnReleasedHandler = nil
  self.SubtractBtnHandler = nil
  self.SubtractBtnPressedHandler = nil
  self.SubtractBtnReleasedHandler = nil
  self.MaxBtnHandler = nil
  self.MaxBtnOnReleasedHandler = nil
  self.MultipleAddBtnHandler = nil
  self.MultipleSubtractBtnHandler = nil
  self.MultipleAddBtnText = nil
  self.MultipleSubtractBtnText = nil
  self.SliderHandler = nil
  self.SliderInfo = nil
  self.ProgressBarInfo = nil
  self.SelectNum = nil
  self.Call = nil
end

return NRCCommonAddSubtractData
