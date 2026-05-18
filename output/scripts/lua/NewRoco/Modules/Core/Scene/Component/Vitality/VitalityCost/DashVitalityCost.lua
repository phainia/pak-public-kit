local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.BasicMovementVitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local DashVitalityCost = Base:Extend("DashVitalityCost")

function DashVitalityCost:Ctor(vitalityComp)
  Base.Ctor(self, vitalityComp)
  self._idName = "PlayerDash"
end

function DashVitalityCost:ShouldCost()
  if not self._id or 0 == self._id then
    return false
  end
  local statusComponent = self.vitalityComp.owner.statusComponent
  if not statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_EXPOSED) and statusComponent:HasAnyStatus(ProtoEnum.WorldPlayerStatusType.WPST_LANDED, ProtoEnum.WorldPlayerStatusType.WPST_FALLING, ProtoEnum.WorldPlayerStatusType.WPST_MANTLE) then
    return false
  end
  return true
end

function DashVitalityCost:OnUpdate(deltaTime)
  if self:ShouldCost() then
    local costSuccess = self:CostByID(VitalityUtil.VitalityCostType.Duration, deltaTime)
    if not costSuccess then
      self.vitalityComp.owner:SendEvent(PlayerModuleEvent.ON_DASH_VITALITY_OVER)
    end
  end
end

return DashVitalityCost
