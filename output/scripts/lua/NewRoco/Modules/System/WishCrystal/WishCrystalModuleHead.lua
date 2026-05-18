local WishCrystalModuleHead = NRCModuleHeadBase:Extend("WishCrystalModuleHead")

function WishCrystalModuleHead:OnConstruct()
  _G.WishCrystalModuleCmd = reload("NewRoco.Modules.System.WishCrystal.WishCrystalModuleCmd")
end

return WishCrystalModuleHead
