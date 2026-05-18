local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local HelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local ScenePlayerDashBuff = Base:Extend("ScenePlayerDashBuff")
local CHECK_INTERVAL = 0.2

function ScenePlayerDashBuff:OnBegin(owner, lifetime, typedConfig, vitality, removeStatus, abilityID)
  self._typedConfig = typedConfig
  self._removeStatus = removeStatus
  self._abilityID = abilityID
  self._curCheckInterval = 0.0
  self._pendingFinish = false
  self._isAccelerating = false
  self._isDecelerating = false
  self._curDuration = 0
  self._leftDuration = lifetime > 0 and lifetime or 9999.0
  self._firstAbility = true
  local characterMovement = self.owner.viewObj.CharacterMovement
  self.statCurveID = self.owner.statComponent:ApplyStat(StatType.MAX_WALK_SPEED_CURVE, nil, nil, characterMovement)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_DASH_VITALITY_OVER, self.OnVitalityOver)
end

function ScenePlayerDashBuff:OnUpdate(deltaTime)
  self._curCheckInterval = self._curCheckInterval - deltaTime
  if self._curCheckInterval <= 0 then
    self._curCheckInterval = self._curCheckInterval + CHECK_INTERVAL
    local hasAbility = self:RefreshAbility()
    if not hasAbility then
      self:Finish()
      return
    end
  end
  if self._curAbility == nil then
    self:Finish()
    return
  end
  if not self:HasMovementInput() then
    self:Finish()
    return
  end
  if self._isAccelerating then
    if self._firstAbility then
      self:AddSpeed(deltaTime)
    else
      self:InterpSpeed(deltaTime)
    end
  elseif self._isDecelerating then
    self:SubSpeed(deltaTime)
  else
    self._curDuration = self._curDuration + deltaTime
    self._leftDuration = self._leftDuration - deltaTime
    if self._leftDuration <= 0.0 then
      self:SubSpeed(deltaTime)
      return
    end
    if not self._curAbility.helper:CanContinue(self.owner) then
      local hasAbility = self:RefreshAbility()
      if not hasAbility then
        self:Finish()
        return
      end
    end
    if self._pendingFinish then
      if self._curDuration >= self._curAbility.helper.typedConfig.dash_duration then
        self:SubSpeed(deltaTime)
      end
    else
      self:SetSpeed()
    end
  end
end

function ScenePlayerDashBuff:OnVitalityOver()
  self:Finish()
end

function ScenePlayerDashBuff:OnFinish(param)
  if self._curAbility then
    self._curAbility:OnStop()
    local abilityComponent = self.owner.abilityComponent
    abilityComponent:ReturnAbilityToPool(self._curAbility)
    self._curAbility = nil
  end
  if self._isLooping then
    self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_END, self._abilityID)
    self._isLooping = false
  end
  local characterMovement = self.owner.viewObj.CharacterMovement
  self.owner.statComponent:RemoveStat(StatType.MAX_WALK_SPEED_CURVE, self.statCurveID, characterMovement)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_DASH_VITALITY_OVER, self.OnVitalityOver)
  self._typedConfig = nil
  self._removeStatus = nil
  self.owner = nil
end

function ScenePlayerDashBuff:OnRefresh(lifeTime)
  if not lifeTime then
    self._curDuration = 0
  else
    self._pendingFinish = false
    if self._isDecelerating then
      self._isDecelerating = false
      self._isAccelerating = true
    end
    self._leftDuration = lifeTime > 0 and lifeTime or 1000.0
  end
end

function ScenePlayerDashBuff:OnLoop()
  self._isLooping = true
  self:OnRefresh(-1.0)
  self.owner.abilityComponent:SendEvent(AbilityEvent.ON_BUFF_LOOP_BEGIN, self._abilityID)
end

function ScenePlayerDashBuff:OnPendingFinish()
  self._pendingFinish = true
end

function ScenePlayerDashBuff:Finish()
  if self.owner then
    local statusComponent = self.owner.statusComponent
    for _, v in pairs(self._removeStatus) do
      statusComponent:RemoveStatus(v)
    end
  end
end

function ScenePlayerDashBuff:RefreshAbility()
  if self._isDecelerating or self._pendingFinish then
    return true
  end
  local newAbilityID = self:GetActualAbilityID()
  if not newAbilityID then
    return false
  elseif self._curAbility then
    if newAbilityID ~= self._curAbility.helper.config.id then
      self._curAbility:OnFinish()
      local abilityComponent = self.owner.abilityComponent
      abilityComponent:ReturnAbilityToPool(self._curAbility)
      self._curAbility = self.owner.abilityComponent:GetAbilityFromPool(newAbilityID)
      self._firstAbility = false
      self._curAbility:OnStart()
      self._isAccelerating = true
    end
  else
    self._curAbility = self.owner.abilityComponent:GetAbilityFromPool(newAbilityID)
    self._curAbility:OnStart()
    self._isAccelerating = true
  end
  return true
end

function ScenePlayerDashBuff:HasEnoughVitality(deltaTime)
  if self._isDecelerating or self._isAccelerating then
    return true
  end
  if self.owner.vitalityComponent and self._curAbility.helper.basic_movement_conf then
    local cost = self._curAbility.helper.basic_movement_conf.vitality_cost.cost_per_seconds
    cost = cost and cost or 0
    local requiredVitality = cost * deltaTime
    local enough = self.owner.vitalityComponent:IsVitalityEnough(requiredVitality)
    return enough
  end
  return true
end

function ScenePlayerDashBuff:GetActualAbilityID()
  local player = self.owner
  local helper = HelperManager.GetHelper(AbilityID.MAIN)
  local actualHelper = helper:GetHelper(player)
  if actualHelper then
    return actualHelper.config.id
  end
  return nil
end

function ScenePlayerDashBuff:AddSpeed(deltaTime)
  self._isAccelerating, self._curVelocity = self._curAbility:AddSpeed(deltaTime)
  self:SetSpeed()
end

function ScenePlayerDashBuff:SubSpeed(deltaTime)
  self.owner.viewObj.IsDashing = false
  self.owner.viewObj.bIsDashing = false
  self._isDecelerating, self._curVelocity = self._curAbility:SubSpeed(deltaTime)
  self:SetSpeed()
  if not self._isDecelerating then
    self:Finish()
  end
end

function ScenePlayerDashBuff:InterpSpeed(deltaTime)
  self._isAccelerating, self._curVelocity = self._curAbility:InterpSpeed()
end

function ScenePlayerDashBuff:SetSpeed()
  if not self._curVelocity then
    return
  end
  local caster = self.owner.viewObj
  local fwd = caster.CharacterMovement.Velocity
  local oldVelocityZ = fwd.Z
  fwd.Z = 0
  fwd:Normalize()
  local newVelocity = fwd * self._curVelocity
  caster.CharacterMovement.Velocity.X = newVelocity.X
  caster.CharacterMovement.Velocity.Y = newVelocity.Y
  caster.CharacterMovement.Velocity.Z = oldVelocityZ
end

function ScenePlayerDashBuff:HasMovementInput()
  local player = self.owner.viewObj
  return player.CharacterMovement:GetLastInputVector():Size() > 0
end

return ScenePlayerDashBuff
