local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDropDownListItemTest_C = Base:Extend("UMG_PetDropDownListItemTest_C")

function UMG_PetDropDownListItemTest_C:OnConstruct()
end

function UMG_PetDropDownListItemTest_C:OnDestruct()
end

function UMG_PetDropDownListItemTest_C:OnActive()
end

function UMG_PetDropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  Log.Debug("UMG_PetDropDownListItemTest_C:OnItemUpdate")
  self.index = index
  self:SetData(_data)
end

function UMG_PetDropDownListItemTest_C:SetData(data)
  Log.Trace(data, 2, "UMG_PetDropDownListItemTest_C:SetData")
  local sortId = data
  local sortInfo = _G.DataConfigManager:GetPetBagSequence(sortId)
  self.TText:SetText(sortInfo.sequence_desc)
end

function UMG_PetDropDownListItemTest_C:OnDeactive()
end

return UMG_PetDropDownListItemTest_C
