local CollisionModuleHead = NRCModuleHeadBase:Extend("CollisionModuleHead")

function CollisionModuleHead:OnConstruct()
  _G.CollisionModuleCmd = reload("NewRoco.Modules.Core.Collision.CollisionModuleCmd")
  self:BindCmd(CollisionModuleCmd.GetCollisionComp, "GetCollisionComp")
end

return CollisionModuleHead
