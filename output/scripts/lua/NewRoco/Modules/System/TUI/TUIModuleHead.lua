local TUIModuleHead = NRCModuleHeadBase:Extend("TUIModuleHead")

function TUIModuleHead:OnConstruct()
  _G.TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
  self:BindCmd(_G.TUIModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return TUIModuleHead
