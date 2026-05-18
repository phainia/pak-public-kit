local CommonModule = _G.NRCModuleBase:Extend("CommonModule")
_G.CommonModuleCmd = require("NewRoco.Modules.System.Common.CommonModuleCmd")
_G.CommonModuleEvent = require("NewRoco.Modules.System.Common.CommonModuleEvent")

function CommonModule:OnActive()
  self:RegPanel("SkipPanel", "UMG_Common_Skip", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegisterCmd(CommonModuleCmd.OpenSkipPanel, self.OpenSkipPanel)
  self:RegisterCmd(CommonModuleCmd.CloseSkipPanel, self.CloseSkipPanel)
end

function CommonModule:RegPanel(name, path, layer, openAnim, closeAnim, isSingleTouchPanel, disablePcEsc, customDisableRendering)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = "/Game/NewRoco/Modules/System/Common/Res/" .. path
  registerData.panelLayer = layer
  registerData.openAnimName = openAnim
  registerData.closeAnimName = closeAnim
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.enablePcEsc = not disablePcEsc
  registerData.customDisableRendering = customDisableRendering or false
  self:RegisterPanel(registerData)
end

function CommonModule:OnDeactive()
end

function CommonModule:OpenSkipPanel()
  if self:HasPanel("SkipPanel") then
    Log.Warning("\228\184\186\228\187\128\228\185\136\228\188\154\233\135\141\229\164\141\230\137\147\229\188\128")
  else
    self:OpenPanel("SkipPanel")
  end
end

function CommonModule:CloseSkipPanel()
  self:ClosePanel("SkipPanel")
end

return CommonModule
