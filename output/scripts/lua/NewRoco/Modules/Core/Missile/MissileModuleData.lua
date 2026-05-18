local MissileModuleData = NRCData:Extend("MissileModuleData")

function MissileModuleData:Ctor()
  NRCData.Ctor(self)
  self:ResetData()
end

function MissileModuleData:ResetData()
  self.unLaunchMissiles = {}
  self.launchedMissiles = {}
end

return MissileModuleData
