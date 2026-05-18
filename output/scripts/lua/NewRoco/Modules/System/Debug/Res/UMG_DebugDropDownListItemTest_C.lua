local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local UMG_DebugDropDownListItemTest_C = Base:Extend("UMG_DebugDropDownListItemTest_C")

function UMG_DebugDropDownListItemTest_C:OnConstruct()
end

function UMG_DebugDropDownListItemTest_C:OnDestruct()
end

function UMG_DebugDropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_DebugDropDownListItemTest_C:SetInfo()
  local data = self.data
  self.TText:SetText(data.name)
  self:UpdatePanel()
end

function UMG_DebugDropDownListItemTest_C:UpdatePanel()
  _G.NRCModuleManager:GetModule("DebugModule"):DispatchEvent(DebugModuleEvent.SelectSearchInstruction, self.data)
end

function UMG_DebugDropDownListItemTest_C:OnItemSelected(_bSelected)
end

function UMG_DebugDropDownListItemTest_C:OnDeactive()
end

return UMG_DebugDropDownListItemTest_C
