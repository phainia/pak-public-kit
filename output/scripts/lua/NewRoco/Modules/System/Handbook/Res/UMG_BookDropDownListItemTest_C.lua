local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BookDropDownListItemTest_C = Base:Extend("UMG_BookDropDownListItemTest_C")

function UMG_BookDropDownListItemTest_C:OnConstruct()
end

function UMG_BookDropDownListItemTest_C:OnDestruct()
end

function UMG_BookDropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  Log.Debug("UMG_BookDropDownListItemTest_C:OnItemUpdate")
  self.index = index
  self:SetData(_data)
end

function UMG_BookDropDownListItemTest_C:SetData(data)
  local sortId = data
  local desId = sortId
  local sortInfo = _G.DataConfigManager:GetPetHandbookSequence(desId)
  self.TText:SetText(sortInfo.sequence_desc)
end

function UMG_BookDropDownListItemTest_C:OnItemSelected(_bSelected)
end

function UMG_BookDropDownListItemTest_C:OnDeactive()
end

return UMG_BookDropDownListItemTest_C
