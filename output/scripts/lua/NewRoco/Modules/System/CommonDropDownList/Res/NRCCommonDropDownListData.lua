local NRCCommonDropDownListData = NRCClass:Extend("NRCCommonDropDownListData")

function NRCCommonDropDownListData:Ctor()
  NRCClass.Ctor(self)
  self.DropDownListInfo = nil
  self.DropDownListText = nil
  self.DropDownListIcon = nil
  self.DropDownListIndex = nil
  self.Btn_LeftHandler = nil
  self.Btn_MidHandler = nil
  self.Btn_RightHandler = nil
  self.ComType = nil
  self.Call = nil
  self.IsComboBox = false
end

return NRCCommonDropDownListData
