local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local ClimbVitalityCost = Base:Extend("ClimbVitalityCost")

function ClimbVitalityCost:Ctor(vitalityComp)
  Base.Ctor(self, vitalityComp)
  self._id = 5
end

function ClimbVitalityCost:ShouldCost()
  local playerMovement = self.vitalityComp.owner.viewObj.CharacterMovement
  if playerMovement.Velocity:Size() <= 0 or playerMovement:IsClimbDashing() then
    return false
  end
  return true
end

function ClimbVitalityCost:OnUpdate(deltaTime)
  if self:ShouldCost() then
    self:CostByID(VitalityUtil.VitalityCostType.Duration, deltaTime)
  end
end

return ClimbVitalityCost
