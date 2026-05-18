local ScreenClickModuleHead = NRCModuleHeadBase:Extend("ScreenClickModuleHead")

function ScreenClickModuleHead:OnConstruct()
  _G.ScreenClickModuleCmd = reload("NewRoco.Modules.System.ScreenClick.ScreenClickModuleCmd")
  self:BindCmd(_G.ScreenClickModuleCmd.OpenMainPanel, "OpenMainPanel")
  self:BindCmd(_G.ScreenClickModuleCmd.Init, "Init")
  self:BindCmd(_G.ScreenClickModuleCmd.HandleScreenClick, "HandleScreenClick")
end

return ScreenClickModuleHead
