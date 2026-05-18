local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local StunComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.StunComponent")
local SceneAIUtils = require("NewRoco.AI.SceneAIUtils")
local LuaActionStun = Base:Extend("LuaActionStun")
local DefaultBas

function LuaActionStun:OnStart(AIController, ...)
  if nil == DefaultBas then
    DefaultBas = _G.DataConfigManager:GetBattleGlobalConfig("nonmagic_battle_ai_status", true).num or Enum.BattleAIStatus.BAS_MAGIC_STUN_2
  end
  local owner = AIController
  local npc = owner.Npc
  local overrideDuration = self.OverrideDuration and self.OverrideDuration:GetValue(owner) or false
  local duration
  local lastHitBy = npc.AIComponent.lastHitBy
  local battleStatus = 0
  if 1 == lastHitBy then
    local resistance = 0
    local petbase = npc:GetConfPetData()
    if npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_NIGHTMARE_ELITE) then
      resistance = 3
    elseif petbase then
      resistance = petbase.stun_resistance
    end
    local charge_level = npc.module.SceneAIManager._cachedLastThrowStarChargeLevel
    if overrideDuration then
      duration = self.Duration:GetValue(owner)
      if 0 == duration then
        duration = 3
      end
      battleStatus = DefaultBas
    else
      local charge_percent = npc.module.SceneAIManager._cachedLastThrowStarChargePercent
      duration = SceneAIUtils.DetermineStunDuration(charge_level, charge_percent, resistance) / 1000.0
      battleStatus = SceneAIUtils.DetermineStunBattleStatus(charge_level, resistance)
    end
  elseif 2 == lastHitBy then
    duration = self.Duration:GetValue(owner)
    if 0 == duration then
      duration = 3
    end
    npc:HitAway(npc.AIComponent.hitSource, 400)
    battleStatus = DefaultBas
  else
    duration = self.Duration:GetValue(owner)
    if 0 == duration then
      duration = 3
    end
    battleStatus = DefaultBas
  end
  if duration > 0 and battleStatus > 0 then
    npc.AIComponent:SetBattleState(battleStatus)
  end
  if duration <= 0 then
    return self:Finish(true)
  end
  local StunComp = npc:EnsureComponent(StunComponent)
  StunComp:Stun(duration, self, self.OnStunFinish)
end

function LuaActionStun:OnInterrupt(AIController, Finalize)
  local owner = AIController
  local npc = owner.Npc
  local StunComp = npc:GetComponent(StunComponent)
  if StunComp then
    StunComp:GetDelegate():Remove(self, self.OnStunFinish)
    StunComp:StopStun()
  end
  SceneAIUtils.ClearStunBattleStatus(npc.AIComponent)
end

function LuaActionStun:OnStunFinish(stunComp)
  local AiComp = stunComp.owner.AIComponent
  SceneAIUtils.ClearStunBattleStatus(AiComp)
  self:Finish(true)
end

return LuaActionStun
