local LoadingUIModuleHead = NRCModuleHeadBase:Extend("LoadingUIModuleHead")

function LoadingUIModuleHead:OnConstruct()
  _G.LoadingUIModuleCmd = reload("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleCmd")
  self:BindCmd(_G.LoadingUIModuleCmd.OpenLoadingUI, "OpenLoadingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.CloseLoadingUI, "CloseLoadingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.OpenWaitingUI, "OnOpenWaitingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.CloseWaitingUI, "OnCloseWaitingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.UpdateWaitingUIText, "OnUpdateWaitingUIText")
  self:BindCmd(_G.LoadingUIModuleCmd.IsWaitingUIOpening, "IsWaitingUIOpening")
  self:BindCmd(_G.LoadingUIModuleCmd.IsWaitingUIEnabled, "IsWaitingUIEnabled")
  self:BindCmd(_G.LoadingUIModuleCmd.HasAnyLoadingUI, "HasAnyLoadingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.OpenCreatePlayerLoadingUI, "OpenCreatePlayerLoadingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.CloseCreatePlayerLoadingUI, "CloseCreatePlayerLoadingUI")
  self:BindCmd(_G.LoadingUIModuleCmd.FindLoadingUIUMGWidgetClass, "FindLoadingUIUMGWidgetClass")
  self:BindCmd(_G.LoadingUIModuleCmd.SetFastLoadingUIHeadLineText, "SetFastLoadingUIHeadLineText")
end

return LoadingUIModuleHead
