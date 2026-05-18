local PhysicsAnimConfig = {}
PhysicsAnimConfig.Box = {
  Force = 5000,
  ZVelocityMin = 1,
  ZVelocityMax = 1.3,
  CylinderMin = 0.1,
  CylinderMax = 0.1
}
PhysicsAnimConfig.Chest = {
  Force = 4000,
  ZVelocityMin = 1,
  ZVelocityMax = 1.3,
  CylinderMin = 0.3,
  CylinderMax = 0.3
}
PhysicsAnimConfig.ForceTester = {
  Force = 4000,
  ZVelocityMin = 1,
  ZVelocityMax = 1.3,
  CylinderMin = 0.2,
  CylinderMax = 0.2
}
return PhysicsAnimConfig
