require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local ENUM_TELEPORT_LOCK_TYPE = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BP_PassiveSwimmingAbility_C = Base:Extend("BP_PassiveSwimmingAbility_C")

function BP_PassiveSwimmingAbility_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  self.caster:SendEvent(PlayerModuleEvent.ON_UPDATE_VITALITY_COST, ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING, 3)
  self.caster:AddEventListener(self, PlayerModuleEvent.ON_VITALITY_OVER, self.OnVitalityOver)
end

function BP_PassiveSwimmingAbility_C:ReturnToPool()
  self.caster:RemoveEventListener(self, PlayerModuleEvent.ON_VITALITY_OVER, self.OnVitalityOver)
  Base.ReturnToPool(self)
end

function BP_PassiveSwimmingAbility_C:Start(OnFinished, ...)
  Log.Debug("BP_PassiveSwimmingAbility_C:Start")
  local player = self.caster
  if player and player.isLocal then
    self:EnterState(ABEnum.AbilityState.Casting)
    Base.Start(self, OnFinished)
  end
end

function BP_PassiveSwimmingAbility_C:OnVitalityOver()
  if self:IsCasting() and not self.caster:IsDead() then
    local player = self.caster
    if not self.caster.viewObj then
      Log.Error("\232\167\146\232\137\178\229\156\168\230\184\184\230\179\179\230\151\182\232\162\171\233\148\128\230\175\129\228\186\134\239\188\129\239\188\129\239\188\129\239\188\129\232\175\183\230\136\170\229\155\190\230\143\144\229\141\149")
      return
    end
    NRCModuleManager:DoCmd(MainUIModuleCmd.UI_OnSetVitalityShow, false)
    player.inputComponent:SetInputEnable(self, false, "DeathPerform")
    self.caster.viewObj.CharacterMovement:ConsumeInputVector()
    self.caster.viewObj.CharacterMovement:ConsumeInputVector()
    self.caster.viewObj.CharacterMovement:MantleEnd()
    local Caster = self.caster.viewObj
    local AnimInstance = Caster.Mesh:GetAnimInstance()
    local Montage = player.viewObj:GetAnimComponent():GetAnimSequenceByName(self.SwimDead)
    Caster:PlayAnimMontage(Montage)
    player.roleHPComponent:SetCustomDeathPerformTime(0.7)
    player.roleHPComponent:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_SWIMMING)
  end
end

function BP_PassiveSwimmingAbility_C:Interrupt()
  self:Finish()
end

function BP_PassiveSwimmingAbility_C:Recover()
  Log.Debug("BP_PassiveSwimmingAbility_C:Recover")
  if not self:IsCasting() then
    self:Start()
  end
end

function BP_PassiveSwimmingAbility_C:Finish()
  Log.Debug("BP_PassiveSwimmingAbility_C:Finish")
  Base.Finish(self)
end

return BP_PassiveSwimmingAbility_C
