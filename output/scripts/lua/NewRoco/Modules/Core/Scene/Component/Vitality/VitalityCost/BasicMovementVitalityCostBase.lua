local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.VitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local BasicMovementVitalityCostBase = Base:Extend("BasicMovementVitalityCostBase")

function BasicMovementVitalityCostBase:SetID(inID)
  self._id = inID
  if self:ShouldCost() then
    self:CostByID(VitalityUtil.VitalityCostType.Once)
  end
end

function BasicMovementVitalityCostBase:CostByID(costType, deltaTime)
  local movementConf = DataConfigManager:GetRideBasicMovement(self._id)
  if not movementConf then
    Log.ErrorFormat("Vitality:CostMovementVitality error, movementConf is nil")
    return false
  end
  costType = costType or VitalityUtil.VitalityCostType.Once
  local curVitality = self.vitalityComp:GetCurVitality()
  local maxVitality = self.vitalityComp:GetMaxVitality()
  local baseMaxVitality = self.vitalityComp:GetBaseMaxVitality() or 800
  if costType == VitalityUtil.VitalityCostType.Once then
    local minCost = movementConf.vitality_cost.min_start or 0
    minCost = minCost * self.vitalityComp:GetVitalityCostRatio()
    if curVitality < minCost then
      return false
    end
    local costValue = movementConf.vitality_cost.start_cost
    self.vitalityComp:CostVitality(costValue, true, costType, self.className)
    return true
  elseif costType == VitalityUtil.VitalityCostType.Duration then
    deltaTime = deltaTime or UE4.UGameplayStatics.GetWorldDeltaSeconds(UE4Helper.GetCurrentWorld())
    local costValue = movementConf.vitality_cost.cost_per_seconds * deltaTime
    costValue = costValue + movementConf.vitality_cost.cost_percentage_per_seconds / 100 * maxVitality * deltaTime
    local decayThresholdPercent = movementConf.vitality_cost.decay_threshold_percent
    if decayThresholdPercent then
      local thresholdValue = decayThresholdPercent * baseMaxVitality / 100
      if curVitality < thresholdValue then
        costValue = costValue * math.clamp(1 - (movementConf.vitality_cost.decay_percent or 0) / 100, 0, 1)
      end
      self.vitalityComp._decayThreshold = thresholdValue
    end
    return self.vitalityComp:CostVitality(costValue, true, costType, self.className)
  end
  return false
end

function BasicMovementVitalityCostBase:ShouldCost()
  if not self._id or 0 == self._id then
    return false
  end
  return true
end

function BasicMovementVitalityCostBase:OnUpdate(deltaTime)
  if self:ShouldCost() then
    self:CostByID(VitalityUtil.VitalityCostType.Duration, deltaTime)
  end
end

return BasicMovementVitalityCostBase
