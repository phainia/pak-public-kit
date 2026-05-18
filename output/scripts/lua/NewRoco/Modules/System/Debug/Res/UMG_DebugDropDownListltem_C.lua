local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local UMG_DebugDropDownListltem_C = Base:Extend("UMG_DebugDropDownListltem_C")

function UMG_DebugDropDownListltem_C:OnConstruct()
end

function UMG_DebugDropDownListltem_C:OnDestruct()
end

function UMG_DebugDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetInfo()
end

function UMG_DebugDropDownListltem_C:SetInfo()
  local uiData = self.uiData
  self.TText:SetText(uiData.name)
end

function UMG_DebugDropDownListltem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCModuleManager:GetModule("DebugModule"):DispatchEvent(DebugModuleEvent.SelectSearchContent, self.uiData)
  end
end

function UMG_DebugDropDownListltem_C:OnDeactive()
end

return UMG_DebugDropDownListltem_C
