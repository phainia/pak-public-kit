local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MiracleDropDownListItemTest_C = Base:Extend("UMG_MiracleDropDownListItemTest_C")

function UMG_MiracleDropDownListItemTest_C:OnConstruct()
end

function UMG_MiracleDropDownListItemTest_C:OnDestruct()
end

function UMG_MiracleDropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  Log.Debug("UMG_PetDropDownListItemTest_C:OnItemUpdate")
  self.index = index
  self:SetData(_data)
end

function UMG_MiracleDropDownListItemTest_C:SetData(data)
  Log.Trace(data, 2, "UMG_PetDropDownListItemTest_C:SetData")
  local sortId = data
  local sortInfo = _G.DataConfigManager:GetPetBagSequence(sortId)
  self.TText:SetText(sortInfo.sequence_desc)
end

function UMG_MiracleDropDownListItemTest_C:OnDeactive()
end

return UMG_MiracleDropDownListItemTest_C
