local CommonDropDownListModuleHead = NRCModuleHeadBase:Extend("CommonDropDownListModuleHead")

function CommonDropDownListModuleHead:OnConstruct()
  _G.CommonDropDownListModuleCmd = reload("NewRoco.Modules.System.CommonDropDownList.CommonDropDownListModuleCmd")
  self:BindCmd(_G.CommonDropDownListModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return CommonDropDownListModuleHead
