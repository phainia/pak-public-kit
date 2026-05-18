local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local RideAllSkillVitalityCost = Base:Extend("RideAllSkillVitalityCost")

function RideAllSkillVitalityCost:SetID(inID)
  self._id = inID
  return self:CostByID(VitalityUtil.VitalityCostType.Once)
end

function RideAllSkillVitalityCost:Pause(bPause)
  Base.Pause(self, bPause)
  if not self:IsRunning() then
    self._id = 0
  end
end

return RideAllSkillVitalityCost
