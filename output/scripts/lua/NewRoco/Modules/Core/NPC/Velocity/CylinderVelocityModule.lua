local CylinderVelocityModule = Class()

function CylinderVelocityModule:Ctor(min, max)
  self.min = min
  self.max = max
end

function CylinderVelocityModule:Get()
  local vec = UE4.FVector(1, 0, 0) * math.rand(self.min, self.max)
  local angle = math.random(0, 360)
  return UE4.UKismetMathLibrary.RotateAngleAxis(vec, angle, UE4.FVector(0, 0, 1))
end

return CylinderVelocityModule
