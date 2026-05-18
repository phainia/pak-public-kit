local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagDropDownListItemTest_C = Base:Extend("UMG_BagDropDownListItemTest_C")

function UMG_BagDropDownListItemTest_C:OnConstruct()
end

function UMG_BagDropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self:SetData(_data)
end

function UMG_BagDropDownListItemTest_C:SetData(data)
  local sortId = data + 1
  local sortInfo = _G.DataConfigManager:GetBagItemSequence(sortId)
  self.TText:SetText(sortInfo.sequence_desc)
end

function UMG_BagDropDownListItemTest_C:OnClick()
end

function UMG_BagDropDownListItemTest_C:UnClick()
end

return UMG_BagDropDownListItemTest_C
