local BagModuleHead = NRCModuleHeadBase:Extend("BagModuleHead")

function BagModuleHead:OnConstruct()
  _G.BagModuleCmd = reload("NewRoco.Modules.System.Bag.BagModuleCmd")
  self:BindCmd(_G.BagModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return BagModuleHead
