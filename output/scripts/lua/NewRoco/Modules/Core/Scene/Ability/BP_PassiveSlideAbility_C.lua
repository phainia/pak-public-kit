require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local BP_PassiveSlideAbility_C = Base:Extend("BP_PassiveSlideAbility_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")

function BP_PassiveSlideAbility_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  self._minSpeed = DataConfigManager:GetRoleGlobalConfig("reduceHP_landslide_speed_limit").num
  self._reduceTime = DataConfigManager:GetRoleGlobalConfig("reduceHP_landslide_speed_ptime").num / 1000
  self._currentTime = 0
  self._sceneSkillInterrupt = false
  self._outOfCtrlTime = 1
end

function BP_PassiveSlideAbility_C:Start(OnFinished, ...)
  Log.Debug("BP_PassiveSlideAbility_C:Start")
  local player = self.caster
  if player and player.isLocal then
    player:AddEventListener(self, PlayerModuleEvent.ON_PENDING_STATUS, self.SetSceneSkillInterrupt)
    player:AddEventListener(self, PlayerModuleEvent.ON_STOP_PASSIVE_FALLING, self.OnStop)
    player:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.OnStop)
    self._currentTime = 0
    self._sceneSkillInterrupt = false
    local player = self.caster
    if player then
      Log.Debug("BP_PassiveSlideAbility_C:OutOfControl")
      player:SendEvent(PlayerModuleEvent.ON_PLAYER_WILL_OUT_OFF_CONTROL)
    end
    self:EnterState(ABEnum.AbilityState.Casting)
    Base.Start(self, OnFinished)
    local Caster = self.caster.viewObj
    local AnimInstance = Caster.Mesh:GetAnimInstance()
    if AnimInstance and AnimInstance:IsPlayingSlotAnimation(self._montage, "DefaultSlot") then
      AnimInstance:StopSlotAnimation(0.1, "DefaultSlot")
    end
  end
end

function BP_PassiveSlideAbility_C:OnStop()
  if self:IsCasting() then
    self:Finish()
  end
end

function BP_PassiveSlideAbility_C:Tick(DeltaSeconds)
end

function BP_PassiveSlideAbility_C:SetSceneSkillInterrupt(status, ClearedStatus)
  if ClearedStatus ~= ProtoEnum.WorldPlayerStatusType.WPST_SLIDING then
    return
  end
  self._sceneSkillInterrupt = true
end

function BP_PassiveSlideAbility_C:Interrupt()
  Log.Debug("BP_PassiveSlideAbility_C:Interrupt")
  if self._sceneSkillInterrupt then
    self:Finish()
    return
  end
  local speed = self.caster.viewObj:GetVelocity():Size()
  Log.Debug("\231\187\147\230\157\159\230\187\145\232\161\140\230\151\182\231\154\132\233\128\159\229\186\166\228\184\186\239\188\154", speed)
  self:ReduceRoleHP(false, speed / self._minSpeed)
  self:Finish()
end

function BP_PassiveSlideAbility_C:ReduceRoleHP(subAll, subValue)
  local safe = NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.IsSafeZone)
  if safe then
    return
  end
  local player = self.caster
  if subAll then
    player.roleHPComponent:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_SLIDING)
    self._bDead = true
    local Caster = self.caster.viewObj
    if self.caster.inputComponent then
      self.caster.inputComponent:SetInputEnable(self, false, "DeathPerform")
    end
  else
    player.roleHPComponent:ReduceRoleHP(subValue, ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_SLIDING)
  end
end

function BP_PassiveSlideAbility_C:Finish()
  Log.Debug("BP_PassiveSlideAbility_C:Finish")
  if not self:IsCasting() then
    return
  end
  local player = self.caster
  if player then
    Log.Debug("BP_PassiveFallingAbility_C:ReturnToControl")
    player:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
  end
  if GlobalConfig.ShowShowFallingTime then
    local Cost = self._currentTime / self._reduceTime
    UE4.UKismetSystemLibrary:PrintString("\233\171\152\233\128\159\230\187\145\232\161\140\230\151\182\233\151\180\239\188\154" .. self._currentTime .. "   \229\190\133\230\137\163\233\153\164\229\185\178\229\138\178\239\188\154" .. Cost, true, false, UE4.FLinearColor(1, 0, 1, 1), 5)
  end
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PENDING_STATUS, self.SetSceneSkillInterrupt)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_STOP_PASSIVE_FALLING, self.OnStop)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.OnStop)
  Base.Finish(self)
end

return BP_PassiveSlideAbility_C
