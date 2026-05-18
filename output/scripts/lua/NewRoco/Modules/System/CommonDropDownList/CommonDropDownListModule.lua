local CommonDropDownListModule = NRCModuleBase:Extend("CommonDropDownListModule")

function CommonDropDownListModule:OnConstruct()
  _G.CommonDropDownListModuleCmd = reload("NewRoco.Modules.System.CommonDropDownList.CommonDropDownListModuleCmd")
  self.data = self:SetData("CommonDropDownListModuleData", "NewRoco.Modules.System.CommonDropDownList.CommonDropDownListModuleData")
end

function CommonDropDownListModule:OnActive()
end

function CommonDropDownListModule:OnRelogin()
end

function CommonDropDownListModule:OnDeactive()
end

function CommonDropDownListModule:OnDestruct()
end

function CommonDropDownListModule:RegPanel(name, path, layer, openAnimName, closeAnimName, bCustomDisableRendering, enablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/CommonDropDownList/Res/%s", path)
  registerData.panelLayer = layer
  if openAnimName then
    registerData.openAnimName = openAnimName
  end
  if closeAnimName then
    registerData.closeAnimName = closeAnimName
  end
  registerData.enablePcEsc = enablePcEsc
  registerData.customDisableRendering = bCustomDisableRendering or false
  self:RegisterPanel(registerData)
end

return CommonDropDownListModule
