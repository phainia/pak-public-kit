local ZVelocityModule = Class()

function ZVelocityModule:Ctor(min, max)
  self.min = min
  self.max = max
end

function ZVelocityModule:Get()
  local vec = UE4.FVector(0, 0, 1)
  return vec * math.rand(self.min, self.max)
end

return ZVelocityModule
