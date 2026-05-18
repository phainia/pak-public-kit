local BlackScreenModuleHead = NRCModuleHeadBase:Extend("BlackScreenModuleHead")

function BlackScreenModuleHead:OnConstruct()
  _G.BlackScreenModuleCmd = reload("NewRoco.Modules.System.BlackScreen.BlackScreenModuleCmd")
  self:BindCmd(_G.BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, "OnCmdOpenGlobalBlackScreenIfNeed")
  self:BindCmd(_G.BlackScreenModuleCmd.TryCloseGlobalBlackScreenIfAny, "OnCmdTryCloseGlobalBlackScreenIfAny")
  self:BindCmd(_G.BlackScreenModuleCmd.IsGlobalBlackScreenOn, "OnCmdIsGlobalBlackScreenOn")
end

return BlackScreenModuleHead
