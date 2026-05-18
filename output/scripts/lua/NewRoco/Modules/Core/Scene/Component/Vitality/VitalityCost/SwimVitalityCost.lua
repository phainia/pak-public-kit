local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local SwimVitalityCost = Base:Extend("SwimVitalityCost")

function SwimVitalityCost:Ctor(vitalityComp)
  Base.Ctor(self, vitalityComp)
  self._id = 3
end

function SwimVitalityCost:ShouldCost()
  local player = self.vitalityComp.owner
  if not (player and player:HasMoveInput()) or player.viewObj.IsDashing then
    return false
  end
  return true
end

function SwimVitalityCost:OnUpdate(deltaTime)
  if self:ShouldCost() then
    self:CostByID(VitalityUtil.VitalityCostType.Duration, deltaTime)
  end
end

return SwimVitalityCost
