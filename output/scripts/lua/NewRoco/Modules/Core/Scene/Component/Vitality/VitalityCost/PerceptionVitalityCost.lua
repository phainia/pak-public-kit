local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PerceptionVitalityCost = Base:Extend("PerceptionVitalityCost")

function PerceptionVitalityCost:SetID(inID)
  self._id = inID
  self.isRide = self.vitalityComp.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
  if self:ShouldCost() then
    self:CostByID(VitalityUtil.VitalityCostType.Once)
  end
end

function PerceptionVitalityCost:CostByID(costType, deltaTime)
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
    local normalCostRatio = self.vitalityComp:GetVitalityCostRatio()
    local perceptionTalentCostRatio = self:GetVitalityCostRatio()
    minCost = minCost * normalCostRatio * perceptionTalentCostRatio
    if curVitality < minCost then
      return false
    end
    local costValue = movementConf.vitality_cost.start_cost * perceptionTalentCostRatio
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
    local perceptionTalentCostRatio = self:GetVitalityCostRatio()
    costValue = costValue * perceptionTalentCostRatio
    return self.vitalityComp:CostVitality(costValue, true, costType, self.className)
  end
  return false
end

function PerceptionVitalityCost:GetVitalityCostRatio()
  local costRatio = 1
  if self.isRide then
    costRatio = self.vitalityComp.owner.statComponent:GetValue(StatType.VITALITY_RIDE_PERCEPTION_COST_RATIO_TALENT) or 1
  else
    costRatio = self.vitalityComp.owner.statComponent:GetValue(StatType.VITALITY_PERCEPTION_COST_RATIO_TALENT) or 1
  end
  return costRatio
end

return PerceptionVitalityCost
