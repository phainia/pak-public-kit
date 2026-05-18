local MissileModuleHead = NRCModuleHeadBase:Extend("MissileModuleHead")

function MissileModuleHead:OnConstruct()
  _G.MissileModuleCmd = reload("NewRoco.Modules.Core.Missile.MissileModuleCmd")
  self:BindCmd(_G.MissileModuleCmd.LaunchMissileByData, "LaunchMissileByData")
end

return MissileModuleHead
