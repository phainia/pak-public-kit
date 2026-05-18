local CollisionModuleData = NRCData:Extend("CollisionModuleData")

function CollisionModuleData:Ctor()
  NRCData.Ctor(self)
  self.collisionComps = {}
end

return CollisionModuleData
