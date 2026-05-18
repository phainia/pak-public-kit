local NPCShopUIModuleHead = NRCModuleHeadBase:Extend("NPCShopUIModuleHead")

function NPCShopUIModuleHead:OnConstruct()
  _G.NPCShopUIModuleCmd = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleCmd")
  self:BindCmd(_G.NPCShopUIModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return NPCShopUIModuleHead
