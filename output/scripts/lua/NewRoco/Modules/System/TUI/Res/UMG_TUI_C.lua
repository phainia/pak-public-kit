local UMG_TUI_C = _G.NRCPanelBase:Extend("UMG_TUI_C")
local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")

function UMG_TUI_C:OnConstruct()
  self:SetChildViews(self.UMG_Tab1Template)
end

function UMG_TUI_C:OnDestruct()
end

function UMG_TUI_C:OnActive()
  self:OnAddEventListener()
end

function UMG_TUI_C:OnDeactive()
end

function UMG_TUI_C:OnAddEventListener()
  self:AddButtonListener(self.Close, self.OnClose)
  self:RegisterEvent(self, TUIModuleEvent.OnItemSelected, self.SetNRCDropDown)
end

function UMG_TUI_C:SetNRCDropDown(index)
  self.BP_NRCTabTest:SetDropDownListItemNum(index)
end

function UMG_TUI_C:OnClose()
  self:DoClose()
end

return UMG_TUI_C
