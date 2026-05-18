require("UnLuaEx")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BP_RidePetRoleHpComponent_C = Class()

function BP_RidePetRoleHpComponent_C:ReceiveBeginPlay()
  self.lastMovementMode = UE4.EMovementMode.MOVE_None
  self.startFallingHeight = nil
  self.finishInit = false
  self._reduceLowZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[1]
  self._reduceHeavyZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[2]
  self._reduceDeathZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[3]
  self._reduceLow = DataConfigManager:GetRoleGlobalConfig("reduce_fixed_HP").num
  self._reduceHeavyConst = DataConfigManager:GetRoleGlobalConfig("reduce_changed_HP_para").numList[2] / 10000
  self._reduceHeavyVar = DataConfigManager:GetRoleGlobalConfig("reduce_changed_HP_para").numList[1] / 10000
  self._deathTime = DataConfigManager:GetRoleGlobalConfig("fall_death_max_time").num / 1000
  self._fallingTime = 0
  self.isFalling = false
  UpdateManager:Register(self)
end

function BP_RidePetRoleHpComponent_C:OnTick(DeltaSeconds)
  if not self.finishInit and self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter then
    if not self:GetOwner().Rider.sceneCharacter.isLocal then
      UpdateManager:UnRegister(self)
      return
    end
    self.startFallingHeight = self:GetOwner().Rider.startFallingHeight
    self.finishInit = true
    self.lastMovementMode = self:GetOwner().CharacterMovement.MovementMode
    if not self.UseFallingDamage then
      self:GetOwner().Rider.startFallingHeight = nil
    else
      if self.lastMovementMode == UE4.EMovementMode.MOVE_Falling then
        self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_WILL_OUT_OFF_CONTROL)
      end
      if self.lastMovementMode == UE4.EMovementMode.MOVE_Custom and self:GetOwner().CharacterMovement.CustomMovementMode == UE.ERocoCustomMovementMode.MOVE_Gliding then
        self:StopFalling()
      end
    end
  end
  if self.finishInit and self.UseFallingDamage then
    if self.startFallingHeight then
      local Ban, _ = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_FALLING_DAMAGE, false, false)
      if Ban then
        Log.Debug("BP_RidePetRoleHpComponent_C is Ban")
        self.startFallingHeight = nil
        self:StopFalling()
      end
    end
    local curMovementMode = self:GetOwner().CharacterMovement.MovementMode
    if nil ~= curMovementMode and curMovementMode ~= self.lastMovementMode then
      self:OnChangeMovementMode(curMovementMode)
    end
  end
  if self.isFalling and self.finishInit and self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter then
    local oldVelocity = self:GetOwner().CharacterMovement.Velocity
    if oldVelocity.Z < 0 then
      self._fallingTime = self._fallingTime + DeltaSeconds
      if self._fallingTime > self._deathTime and self:GetOwner().Rider.sceneCharacter and self:GetOwner().Rider.sceneCharacter.roleHPComponent then
        self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
        self:GetOwner().Rider.startFallingHeight = nil
        self:ReduceRoleHP(true)
        self._fallingTime = 0
        self.isFalling = false
        self.ignoreFallingDamage = nil
      end
    else
      self._fallingTime = 0
    end
  end
end

function BP_RidePetRoleHpComponent_C:ReceiveEndPlay(EndPlayReason)
  if self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter and self:GetOwner().Rider.CharacterMovement.MovementMode ~= UE4.EMovementMode.MOVE_Falling then
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
  end
  UpdateManager:UnRegister(self)
end

function BP_RidePetRoleHpComponent_C:IgnoreFallingDamage()
  self.ignoreFallingDamage = true
end

function BP_RidePetRoleHpComponent_C:IsIgnoreDamageBuff(isIgnoreDamageBuff)
  self.isIgnoreDamageBuff = isIgnoreDamageBuff
end

function BP_RidePetRoleHpComponent_C:OnChangeMovementMode(MovementMode)
  if not self:GetOwner() or not self:GetOwner().CharacterMovement then
    return
  end
  if MovementMode == UE.EMovementMode.MOVE_Custom and self:GetOwner().CharacterMovement.CustomMovementMode == UE.ERocoCustomMovementMode.MOVE_Gliding or MovementMode == UE.EMovementMode.MOVE_Swimming then
    self:StopFalling()
    self.lastMovementMode = MovementMode
    return
  end
  if MovementMode == UE4.EMovementMode.MOVE_Falling then
    self:ResetFalling()
    self.lastMovementMode = MovementMode
    return
  end
  if self.lastMovementMode == UE4.EMovementMode.MOVE_Falling then
    self:EndFalling()
    self.lastMovementMode = MovementMode
    return
  end
  if MovementMode then
    self.lastMovementMode = MovementMode
  end
end

function BP_RidePetRoleHpComponent_C:ResetStartFallingHeight()
  if self.isFalling then
    self.startFallingHeight = self:GetOwner():Abs_K2_GetActorLocation().Z
    if self:GetOwner().Rider then
      self:GetOwner().Rider.startFallingHeight = self.startFallingHeight
    end
  end
end

function BP_RidePetRoleHpComponent_C:ResetFalling()
  if self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter then
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_WILL_OUT_OFF_CONTROL)
  end
  self.startFallingHeight = self:GetOwner():Abs_K2_GetActorLocation().Z
  if self:GetOwner().Rider then
    self:GetOwner().Rider.startFallingHeight = self.startFallingHeight
  end
  self._fallingTime = 0
  self.isFalling = true
  if self.isIgnoreDamageBuff then
    self.ignoreFallingDamage = true
  else
    self.ignoreFallingDamage = nil
  end
end

function BP_RidePetRoleHpComponent_C:StopFalling()
  if self:GetOwner().Rider then
    self:GetOwner().Rider.startFallingHeight = nil
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_STOP_PASSIVE_FALLING)
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
  end
  self._fallingTime = 0
  self.isFalling = false
  self.ignoreFallingDamage = nil
end

function BP_RidePetRoleHpComponent_C:EndFalling()
  self._fallingTime = 0
  self.isFalling = false
  if self.startFallingHeight == nil and self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter then
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
  end
  if self.startFallingHeight ~= nil and self:GetOwner().Rider and self:GetOwner().Rider.sceneCharacter and self:GetOwner().Rider.sceneCharacter.roleHPComponent then
    self:GetOwner().Rider.sceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
    self:GetOwner().Rider.startFallingHeight = nil
    local waterDepth = self:GetOwner().Rider:GetMovementComponent():GetWaterDepth()
    if waterDepth and waterDepth >= self:GetOwner().Rider:GetMovementComponent().StartSwimWaterDepth then
      return
    end
    local FallZ = self.startFallingHeight - self:GetOwner().Rider:Abs_K2_GetActorLocation().Z
    if self.ignoreFallingDamage then
      Log.Debug("RoleHPSystem: ignoreFallingDamage")
    elseif FallZ < self._reduceLowZ then
      Log.Debug("RoleHPSystem: Pet Landed without reduce")
    elseif FallZ < self._reduceHeavyZ then
      Log.Debug("RoleHPSystem: Pet Landed [X1,X2) reduce:" .. self._reduceLow)
      self._montage = self:GetOwner().Rider:GetAnimComponent():GetAnimSequenceByName(self.LandHeavy)
      self:ReduceRoleHP(false, self._reduceLow)
    elseif FallZ < self._reduceDeathZ then
      local cost = FallZ * self._reduceHeavyVar + self._reduceHeavyConst
      Log.Debug("RoleHPSystem: Pet Landed [X2,X3) reduce:" .. cost)
      self._montage = self:GetOwner().Rider:GetAnimComponent():GetAnimSequenceByName(self.LandDead)
      self:ReduceRoleHP(false, cost)
    else
      Log.Debug("RoleHPSystem: Pet Landed...ooooooh, dead")
      self._montage = self:GetOwner().Rider:GetAnimComponent():GetAnimSequenceByName(self.LandDead)
      self:ReduceRoleHP(true)
    end
  end
  self.ignoreFallingDamage = nil
end

function BP_RidePetRoleHpComponent_C:PlayerMontage()
  Log.Debug("BP_RidePetRoleHpComponent_C:PlayerMontage")
  local AnimInstance = self:GetOwner().Rider.Mesh:GetAnimInstance()
  if AnimInstance then
    AnimInstance:PlaySlotAnimation(self._montage, "DefaultSlot", 0.1, 0.1)
  end
  if self:GetOwner().Rider.sceneCharacter.inputComponent then
    self:GetOwner().Rider.sceneCharacter.inputComponent:SetInputEnable(self, false, "DeathPerform")
  end
end

function BP_RidePetRoleHpComponent_C:ReduceRoleHP(subAll, subValue)
  if NRCEnv:IsLocalMode() then
    return
  end
  local safe = NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.IsSafeZone)
  if safe then
    return
  end
  local player = self:GetOwner().Rider.sceneCharacter
  if subAll or player and player.roleHPComponent and subValue >= player.roleHPComponent:GetLocalRoleHP() then
    self._bDead = true
    self:PlayerMontage()
    player:StopRide()
    player.roleHPComponent:SetCustomDeathPerformTime(0.7)
    player.roleHPComponent:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
  else
    player.roleHPComponent:ReduceRoleHP(subValue, ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
  end
end

function BP_RidePetRoleHpComponent_C:CheckFalling()
  if not (self:GetOwner() and UE.UObject.IsValid(self:GetOwner()) and self:GetOwner().Rider and UE.UObject.IsValid(self:GetOwner().Rider) and self:GetOwner().Rider.sceneCharacter) or not self:GetOwner().Rider.sceneCharacter.roleHPComponent then
    return
  end
  if self.startFallingHeight ~= nil then
    local curMovementMode = self:GetOwner().CharacterMovement.MovementMode
    if nil ~= curMovementMode and curMovementMode ~= self.lastMovementMode then
      self:OnChangeMovementMode(curMovementMode)
    end
  else
    self:GetOwner().Rider.startFallingHeight = nil
  end
end

return BP_RidePetRoleHpComponent_C
