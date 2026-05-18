local ConeVelocityModule = Class()

function ConeVelocityModule:Ctor(axis, angle)
  self.axis = axis
  self.angle = angle
end

function ConeVelocityModule:Get()
  return UE4.UKismetMathLibrary.RandomUnitVectorInConeInDegrees(self.axis, self.angle)
end

return ConeVelocityModule
