local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local EnvSystemModuleEvent = reload("NewRoco.Modules.System.EnvSystem.EnvSystemModuleEvent")
local AIReactionStateEnum = {
  None = 0,
  Angry = 1,
  Lookup = 2,
  AutoLookAt = 4
}
local AIReactionStateBase = _G.Class("AIReactionStateBase")

function AIReactionStateBase.Perform(npc)
  return 0
end

function AIReactionStateBase.Reset(npc, time)
  return
end

local AIRStateAngry = AIReactionStateBase:Extend("AIReactionAngry")

function AIRStateAngry.Perform(npc, comp)
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local time = npc:PlayAnim("Anger1", 1, 0, 0.2, 0, 1)
  if time > 0 and Player then
    npc:SetHeadLookAtActor(Player.viewObj, false, false)
  end
  return math.max(0.2, time)
end

function AIRStateAngry.Reset(npc, time)
  if time > 0 then
    npc:SetHeadLookAtActor(nil, false, false)
  end
end

local AIRStateLookup = AIReactionStateBase:Extend("AIRStateLookup")

function AIRStateLookup.Perform(npc, comp)
  npc:DoHeadMotion(_G.Enum.HeadMotion.Lookup)
  return 1.2
end

local AIRStateRegistry = {
  [AIReactionStateEnum.Angry] = AIRStateAngry,
  [AIReactionStateEnum.Lookup] = AIRStateLookup
}
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local AIReactionComponent = Base:Extend("AIReactionComponent")
AIReactionComponent.Abilities = AIReactionStateEnum

function AIReactionComponent:OnEnable()
  self.lockAi = false
  self.d_Performing = nil
  self.currentState = AIReactionStateEnum.None
  self.weatherListener = false
  self.lookingAtPlayer = false
  self.context = {lastOverlapMs = 0, overlapCount = 0}
  self.enabledAbility = 0
  Log.Debug("[AIReactionComponent] OnEnable for", self.owner.config.name, self.owner.config.id)
end

function AIReactionComponent:UpdateAbility(newAbilities)
  if self.enabledAbility == newAbilities then
    return
  end
  self.enabledAbility = newAbilities
  if self.enabled and self.enabledAbility & AIReactionStateEnum.Angry > 0 then
    self:SetOverlapListener(true)
  else
    self:SetOverlapListener(false)
  end
  if self.enabled and self.enabledAbility & AIReactionStateEnum.Lookup > 0 then
  else
    self:SetWeatherListener(false)
  end
  if self.enabled and self.enabledAbility & AIReactionStateEnum.AutoLookAt > 0 then
  elseif self.lookingAtPlayer then
    self:UpdateLookAt(math.maxinteger)
  end
end

function AIReactionComponent:OnDisable()
  if self.d_Performing then
    _G.DelayManager:CancelDelayById(self.d_Performing)
    self.d_Performing = nil
  end
  self:SetOverlapListener(false)
  self:SetWeatherListener(false)
end

function AIReactionComponent:DeAttach()
  self:SetEnable(false)
end

function AIReactionComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if self.enabledAbility & AIReactionStateEnum.Lookup > 0 then
    self:UpdateWeatherEventBinding(distance)
  end
  if self.enabledAbility & AIReactionStateEnum.AutoLookAt > 0 then
    self:UpdateLookAt(distance)
  end
end

function AIReactionComponent:EnterState(newState)
  if self.currentState ~= AIReactionStateEnum.None then
    return
  end
  if 0 == self.enabledAbility & newState then
    return
  end
  if not self:CanReact() then
    return
  end
  local refStateItem = AIRStateRegistry[newState]
  if not refStateItem then
    Log.Error("[AIReactionComponent] invalid reaction state id")
    return
  end
  self:LockAI(true)
  self.currentState = newState
  local seconds = refStateItem.Perform(self.owner)
  Log.DebugFormat("[AIReactionComponent] EnterState %d %s sec=%f", self.owner.config.id, self.owner.config.name, seconds)
  if 0 == seconds then
    self.d_Performing = _G.DelayManager:DelayFrames(1, self.OnStatePerformEnd, self, seconds)
  else
    self.d_Performing = _G.DelayManager:DelaySeconds(seconds, self.OnStatePerformEnd, self, seconds)
  end
end

function AIReactionComponent:OnStatePerformEnd(time)
  self.d_Performing = nil
  local refStateItem = AIRStateRegistry[self.currentState]
  refStateItem.Reset(self.owner, time)
  self.currentState = AIReactionStateEnum.None
  self:LockAI(false)
end

function AIReactionComponent:CanReact()
  local AIComp = self.owner.AIComponent
  if AIComp then
    return not AIComp:IsLocked()
  end
  return false
end

function AIReactionComponent:LockAI(lock)
  if self.lockAi ~= lock then
    local AIComp = self.owner.AIComponent
    if AIComp then
      AIComp:ForceLock(lock)
      self.lockAi = lock
    end
  end
end

local DEFAULT_LOOK_AT_DISTANCE_SQR, DEFAULT_LOOK_AT_THREASHOLD
local _PlayerPos = UE.FVector()
local _SelfPos = UE.FVector()
local _PlayerToSelf = UE.FVector()

function AIReactionComponent:UpdateLookAt(distSqr)
  if not self:CanReact() then
    return
  end
  if not DEFAULT_LOOK_AT_DISTANCE_SQR then
    local dist = _G.DataConfigManager:GetNpcGlobalConfig("default_npc_lookat_distance").num or 400
    DEFAULT_LOOK_AT_DISTANCE_SQR = dist * dist
    DEFAULT_LOOK_AT_THREASHOLD = (dist + 100) * (dist + 100)
  end
  if distSqr < DEFAULT_LOOK_AT_DISTANCE_SQR then
    local dot = -1
    local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player then
      local selfDir = self.owner:GetForwardVector()
      if player.viewObj and self.owner.viewObj then
        UE.UNRCStatics.K2_GetActorLocationInplace(player.viewObj, _PlayerPos)
        UE.UNRCStatics.K2_GetActorLocationInplace(self.owner.viewObj, _SelfPos)
        UE.FVector.SubInto(_PlayerPos, _SelfPos, _PlayerToSelf)
        _PlayerToSelf:Normalize()
        dot = selfDir:Dot(_PlayerToSelf)
      end
    end
    if not self.lookingAtPlayer then
      if dot > 0.1 then
        self.owner:SetHeadLookAtActor(player.viewObj, false, false)
        self.lookingAtPlayer = true
      end
    elseif dot < 0 then
      self.owner:SetHeadLookAtActor(nil, false, false)
      self.lookingAtPlayer = false
    end
  elseif distSqr > DEFAULT_LOOK_AT_THREASHOLD and self.lookingAtPlayer then
    self.owner:SetHeadLookAtActor(nil, false, false)
    self.lookingAtPlayer = false
  end
end

function AIReactionComponent:SetOverlapListener(enable)
  if self.overlapListener == enable then
    return
  end
  if enable then
    self.owner:AddEventListener(self, NPCModuleEvent.BE_PEO_OVERLAP, self.OnPeoOverlap)
  else
    self.owner:RemoveEventListener(self, NPCModuleEvent.BE_PEO_OVERLAP, self.OnPeoOverlap)
  end
end

function AIReactionComponent:UpdateWeatherEventBinding(distSqr)
  if distSqr < 2250000 then
    self:SetWeatherListener(true)
  elseif distSqr > 4000000 then
    self:SetWeatherListener(false)
  end
end

function AIReactionComponent:SetWeatherListener(enable)
  if self.weatherListener == enable then
    return
  end
  local envSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")
  if enable then
    envSystem:RegisterEvent(self, EnvSystemModuleEvent.WeatherChangeEvent, self.OnWeatherChange)
  else
    envSystem:UnRegisterEvent(self, EnvSystemModuleEvent.WeatherChangeEvent)
  end
  self.weatherListener = enable
end

local function IsRaining(weather)
  return weather == Enum.WeatherType.WT_LIGHTRAIN or weather == Enum.WeatherType.WT_HEAVYRAIN
end

function AIReactionComponent:OnWeatherChange(weather, prevWeather)
  if prevWeather == Enum.WeatherType.WT_NONE then
    return
  end
  if not (not self.owner.isDestroy and self.owner.viewObj) or UE.UObject.IsValid(self.owner.viewObj) then
    return
  end
  if IsRaining(weather) and not IsRaining(prevWeather) and math.random(1, 100) < 80 then
    self:EnterState(AIReactionStateEnum.Lookup)
  end
end

function AIReactionComponent:OnPeoOverlap()
  local curTimeMs = os.msTime()
  local context = self.context
  if curTimeMs - context.lastOverlapMs > 20000.0 then
    context.lastOverlapMs = curTimeMs
    context.overlapCount = 0
  end
  context.overlapCount = context.overlapCount + 1
  if context.overlapCount >= 3 then
    self:EnterState(AIReactionStateEnum.Angry)
    context.lastOverlapMs = curTimeMs
    context.overlapCount = 0
  end
end

return AIReactionComponent
