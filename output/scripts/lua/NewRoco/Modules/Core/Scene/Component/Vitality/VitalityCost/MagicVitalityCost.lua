local Base = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.VitalityCostBase")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local MagicVitalityCost = Base:Extend("MagicVitalityCost")

function MagicVitalityCost:Ctor(vitalityComp)
  Base.Ctor(self, vitalityComp)
  self.vitalityComp.owner:AddEventListener(self, PlayerModuleEvent.ON_INIT_MAGIC_COST, self.InitCostInfo)
end

function MagicVitalityCost:Destroy()
  self.vitalityComp.owner:RemoveEventListener(self, PlayerModuleEvent.ON_INIT_MAGIC_COST, self.InitCostInfo)
end

function MagicVitalityCost:InitCostInfo(MagicBuff)
  if nil == MagicBuff then
    self.buff = nil
    self.magicBaseConfig = nil
    self.helper = nil
    self._id = 0
    return
  end
  self.MagicBuff = MagicBuff
  self.magicBaseConfig = self.MagicBuff.magicInfo.magicBaseConfig
  self.helper = self.MagicBuff.magicInfo.abilityHelper
  self._id = self.magicBaseConfig.id
end

function MagicVitalityCost:SetID(chargedTime)
  self:MinCost(chargedTime)
end

function MagicVitalityCost:ShouldCost()
  return not self.MagicBuff.ChargedEnd
end

function MagicVitalityCost:OnUpdate(deltaTime)
  if self.MagicBuff then
    if not self:ShouldCost() then
      self.MagicBuff.ChargedSuccess = false
    else
      self.MagicBuff.ChargedSuccess = self:ChangedCost(deltaTime)
    end
  end
end

function MagicVitalityCost:ChangedCost(deltaTime)
  if self.magicBaseConfig then
    if self.magicBaseConfig.vitality_cost_perscond then
      local BeforeCost = self.vitalityComp:GetCurVitality()
      local Cost = self.magicBaseConfig.vitality_cost_perscond * deltaTime
      local CostSuccess = self.vitalityComp:CostVitality(Cost, nil, false, VitalityUtil.VitalityCostType.Duration)
      if CostSuccess then
        local AfterCost = self.vitalityComp:GetCurVitality()
        self.vitalityComp.owner:SendEvent(PlayerModuleEvent.ON_CHARGE_VITALITY_COST, BeforeCost - AfterCost)
      end
      return CostSuccess
    end
    return true
  end
  Log.Error("false")
  return false
end

function MagicVitalityCost:MinCost(chargedTime)
  if self.magicBaseConfig then
    if self.magicBaseConfig.vitality_cost_minimum and self.magicBaseConfig.vitality_cost_perscond then
      local Cost = self.magicBaseConfig.vitality_cost_minimum - self.magicBaseConfig.vitality_cost_perscond * chargedTime / 1000
      return self.vitalityComp:CostVitality(Cost, nil, true)
    end
    return true
  end
  return false
end

return MagicVitalityCost
