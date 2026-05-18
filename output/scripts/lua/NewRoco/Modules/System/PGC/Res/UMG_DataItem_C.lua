local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DataItem_C = Base:Extend("UMG_DataItem_C")

function UMG_DataItem_C:OnConstruct()
  self.index = -1
  self.data = nil
  self:AddButtonListener(self.SelectButton, self.OnClickSelectButton)
end

function UMG_DataItem_C:OnDestruct()
  self:RemoveButtonListener(self.SelectButton, self.OnClickSelectButton)
end

function UMG_DataItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.Name:SetText(_data.name)
end

function UMG_DataItem_C:OnItemSelected(_bSelected)
end

function UMG_DataItem_C:OnDeactive()
end

function UMG_DataItem_C:OnClickSelectButton()
  NRCModuleManager:DoCmd(PGCModuleCmd.ShowDataDetail, self.data)
end

return UMG_DataItem_C
