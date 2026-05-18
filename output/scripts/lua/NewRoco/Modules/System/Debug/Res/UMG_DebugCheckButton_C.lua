local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DebugCheckButton_C = Base:Extend("UMG_DebugCheckButton_C")

function UMG_DebugCheckButton_C:OnConstruct()
  self.checkBox1.OnCheckStateChanged:Add(self, self.OnCheckStateChanged)
end

function UMG_DebugCheckButton_C:OnCheckStateChanged()
  local checked = self.checkBox1:GetCheckedState() == UE4.ECheckBoxState.Checked
  if self.onCheckStateChangedCallback then
    self.onCheckStateChangedCallback(self.callbackOwner, checked, self.data, self.datalist, self.index, self)
  end
end

function UMG_DebugCheckButton_C:OnDestruct()
end

function UMG_DebugCheckButton_C:OnItemSelected(_bSelected)
end

function UMG_DebugCheckButton_C:OnDeactive()
end

function UMG_DebugCheckButton_C:OnItemUpdate(data, datalist, index)
  self.index = index
  self.datalist = datalist
  self.name = data[1]
  self.data = data[2]
  self.onCheckStateChangedCallback = data[4]
  self.callbackOwner = data[3]
  self:SetisChecked(self.data.show)
  self:SetText(self.data.showName)
end

function UMG_DebugCheckButton_C:SetisChecked(isChecked)
  self.checkBox1:SetisChecked(isChecked)
end

function UMG_DebugCheckButton_C:SetText(text)
  self.text:SetText(text)
end

function UMG_DebugCheckButton_C:GetCheckedState()
  return self.checkBox1:GetCheckedState()
end

return UMG_DebugCheckButton_C
