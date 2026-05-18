local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local VitalityNew = NRCClass()
local clamp = math.clamp

function VitalityNew:Ctor(config)
  if not config then
    Log.Error("VitalityComponent: vitality config is nil")
    return
  end
  self._config = config
  self.id = config.id or 0
  self._maxVitality = config.max_vitality or 0
  self._curVitality = config.max_vitality or 0
  self._curVitalityRecoverDelay = (config.vitality_recover_delay or 0) / 1000
  local PowerMaxConf = DataConfigManager:GetPowerMaxConf(1, true)
  self._originBaseVitality = PowerMaxConf.lower_limit or 800
  self._state = VitalityUtil.VitalityState.Normal
  self._costingCheckInterval = 2
end

function VitalityNew:SyncVitality(curVitality)
  self._curVitality = curVitality or self._curVitality or 0
end

function VitalityNew:SyncMaxVitality(maxVitality)
  self._maxVitality = maxVitality or self._maxVitality or 0
end

function VitalityNew:GetVitality()
  return self._curVitality
end

function VitalityNew:GetMaxVitality()
  return self._maxVitality
end

function VitalityNew:_CostVitality(costValue, stillCostWhenNotEnough, notRefreshDelay)
  local actualCostValue = costValue
  if actualCostValue > self._curVitality then
    if stillCostWhenNotEnough then
      local success = self._curVitality > 0
      self._curVitality = 0
      if not notRefreshDelay then
        self._curVitalityRecoverDelay = self._config.vitality_recover_delay / 1000
        self._state = VitalityUtil.VitalityState.Costing
        self._costingCheckInterval = 2
      end
      return success
    end
    return false
  end
  self._curVitality = self._curVitality - actualCostValue
  if not notRefreshDelay then
    self._curVitalityRecoverDelay = self._config.vitality_recover_delay / 1000
    self._state = VitalityUtil.VitalityState.Costing
    self._costingCheckInterval = 2
  end
  return true
end

function VitalityNew:RecoverVitality(deltaTime, isIdle)
  if self._startRecover then
    local config = self._config
    if config then
      if self._curVitalityRecoverDelay <= 0 then
        if self._curVitality < self._maxVitality then
          local recover = config.vitality_recover * deltaTime
          local percentRecover = (config.vitality_recover_percent or 0) / 100 * self._maxVitality * deltaTime
          local totalRecover = recover + percentRecover
          if isIdle then
            local extraRecover = (config.vitality_recover_idle or 0) * deltaTime
            local extraPercentRecover = (config.vitality_recover_percent_idle or 0) / 100 * self._maxVitality * deltaTime
            totalRecover = totalRecover + extraRecover + extraPercentRecover
          end
          local newVitality = clamp(self._curVitality + totalRecover, 0, self._maxVitality)
          self._curVitality = newVitality
          self._state = VitalityUtil.VitalityState.Recovering
        else
          self._state = VitalityUtil.VitalityState.Normal
        end
      else
        self._curVitalityRecoverDelay = self._curVitalityRecoverDelay - deltaTime
      end
    end
  end
end

function VitalityNew:_RecoverVitalityToMax()
  local config = self._config
  if config then
    self._curVitality = self._maxVitality
  end
end

function VitalityNew:_RecoverVitalityByValue(value)
  if value and value > 0 then
    self._curVitality = math.min(self._curVitality + value, self._maxVitality)
  end
end

function VitalityNew:StartRecover()
  if not self._startRecover then
    self._startRecover = true
    self._curVitalityRecoverDelay = self._config.vitality_recover_delay / 1000
  end
end

function VitalityNew:StopRecover()
  self._startRecover = false
  if self._state == VitalityUtil.VitalityState.Recovering then
    self._state = VitalityUtil.VitalityState.Normal
  end
end

function VitalityNew:UpdateState(deltaTime)
  if self._costingCheckInterval > 0 then
    self._costingCheckInterval = self._costingCheckInterval - deltaTime
  else
    self._state = VitalityUtil.VitalityState.Normal
  end
end

function VitalityNew:GetState()
  if GlobalConfig.FreeVitality then
    self._state = VitalityUtil.VitalityState.Forbidden
  end
  return self._state
end

return VitalityNew
