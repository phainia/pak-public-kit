local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RoleHPSyncComponent = Base:Extend("RoleHPSyncComponent")

function RoleHPSyncComponent:Ctor()
  self._DeathReason = 0
  self.DeadAnimName = "NormalDead"
end

function RoleHPSyncComponent:Attach(owner)
  Base.Attach(self, owner)
  self.delayFunction = nil
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
end

function RoleHPSyncComponent:DeAttach()
  Base.DeAttach(self)
  if self.delayFunction then
    DelayManager:CancelDelay(self.delayFunction)
  end
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnStatusChanged)
  self.owner = nil
end

function RoleHPSyncComponent:ReduceAllRoleHP(reason)
end

function RoleHPSyncComponent:ReduceRoleHP(ReduceValue, reason)
end

function RoleHPSyncComponent:OnDataChange(AttrTag)
end

function RoleHPSyncComponent:OnHPMaxChange(bTemperal)
end

function RoleHPSyncComponent:OnStatusChanged(status, value, opCode)
  if not self.delayFunction and self.owner and UE.UObject.IsValid(self.owner.viewObj) then
    local isDead = self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
    self.owner.viewObj:SetActorHiddenInGame(isDead)
  end
end

function RoleHPSyncComponent:DeathPerform(DeathAct)
  local DeathReason = DeathAct.die_reason
  Log.Debug("RoleHPSyncComponent:DeathPerform", DeathReason)
  if self.delayFunction then
    Log.Debug("RoleHPSyncComponent:HavePreDeathPerform")
    return
  end
  
  function self.delayFunction()
    self:EndPlayDeath()
  end
  
  if DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_TEMPERATURE and not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) and self.owner.viewObj and self.owner.viewObj.CharacterMovement.MovementMode == UE.EMovementMode.MOVE_Walking then
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    local Montage = self.owner.viewObj:GetAnimComponent():GetAnimSequenceByName(self.DeadAnimName)
    AnimInstance:PlaySlotAnimation(Montage, "DefaultSlot", 0.1, 0.1)
    DelayManager:DelaySeconds(2, self.delayFunction)
  elseif DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_WORLD_COMBAT_ATTACKING then
    local HitDir = UE.FVector(DeathAct.dir.x, DeathAct.dir.y, DeathAct.dir.z)
    self.owner:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, HitDir, true, true)
    DelayManager:DelaySeconds(1.5, self.delayFunction)
  elseif DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_FALLING then
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    local Montage = self.owner.viewObj:GetAnimComponent():GetAnimSequenceByName("LandDead")
    AnimInstance:PlaySlotAnimation(Montage, "DefaultSlot", 0.1, 0.1)
    DelayManager:DelaySeconds(2, self.delayFunction)
  elseif DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_SWIMMING then
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    local Montage = self.owner.viewObj:GetAnimComponent():GetAnimSequenceByName("SwimDead")
    AnimInstance:Montage_Play(Montage)
    DelayManager:DelaySeconds(1, self.delayFunction)
  else
    self:EndPlayDeath(true)
  end
end

function RoleHPSyncComponent:EndPlayDeath(forceHidden)
  self.delayFunction = nil
  local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
  if AnimInstance then
    AnimInstance:StopSlotAnimation(0, "DefaultSlot")
    AnimInstance:Montage_Stop(0)
  end
  if self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) or forceHidden then
    self.owner.viewObj:SetActorHiddenInGame(true)
  end
end

return RoleHPSyncComponent
