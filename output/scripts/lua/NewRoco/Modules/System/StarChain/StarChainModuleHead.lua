local StarChainModuleHead = NRCModuleHeadBase:Extend("StarChainModuleHead")

function StarChainModuleHead:OnConstruct()
  _G.StarChainModuleCmd = reload("NewRoco.Modules.System.StarChain.StarChainModuleCmd")
  self:BindCmd(_G.StarChainModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return StarChainModuleHead
