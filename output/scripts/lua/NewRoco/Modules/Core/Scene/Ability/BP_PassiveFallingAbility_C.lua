require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local BP_PassiveFallingAbility_C = Base:Extend("BP_PassiveFallingAbility_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")

function BP_PassiveFallingAbility_C:AwakeFromPool(owner)
  Base.AwakeFromPool(self, owner)
  self._minFallHeight = DataConfigManager:GetRoleGlobalConfig("min_height_play_anim").num
  self._reduceLowZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[1]
  self._reduceHeavyZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[2]
  self._reduceDeathZ = DataConfigManager:GetRoleGlobalConfig("fall_height_divide").numList[3]
  self._reduceLow = DataConfigManager:GetRoleGlobalConfig("reduce_fixed_HP").num
  self._reduceHeavyConst = DataConfigManager:GetRoleGlobalConfig("reduce_changed_HP_para").numList[2] / 10000
  self._reduceHeavyVar = DataConfigManager:GetRoleGlobalConfig("reduce_changed_HP_para").numList[1] / 10000
  self._deathTime = DataConfigManager:GetRoleGlobalConfig("fall_death_max_time").num / 1000
  self._minFallAnimTime = DataConfigManager:GetRoleGlobalConfig("min_land_anim_time").num / 1000
  self._animEnd1 = DataConfigManager:GetRoleGlobalConfig("landing_speed").numList[2]
  self._animEnd2 = DataConfigManager:GetRoleGlobalConfig("landing_speed").numList[3]
  self._animEnd3 = DataConfigManager:GetRoleGlobalConfig("landing_speed").numList[4]
  self._fallingTime = 0
  self._startFallHeight = 0
  self._bDead = false
  self._sceneSkillInterrupt = false
  self._shouldPlayMontag = true
  self._isMontagePlaying = false
  self._montage = nil
  self._acceleTime = 0
  self._isInControl = true
  self._outOfCtrlTime = 1
end

function BP_PassiveFallingAbility_C:Start(OnFinished, ...)
  Log.Debug("BP_PassiveFallingAbility_C:Start")
  UE4.FCycleCounter.Create("BP_PassiveFallingAbility_C:Interrupt")
  if self:IsCasting() then
    Log.Debug("BP_PassiveFallingAbility_C:IsCasting")
    return
  end
  if self._isMontagePlaying then
    self:Finish()
  end
  local player = self.caster
  if player and player.isLocal then
    player.viewObj.bFallHigh = false
    local isSceneLoading = false
    local SceneModule = NRCModuleManager:GetModule("SceneModule")
    if SceneModule then
      isSceneLoading = SceneModule._isLoading
    end
    if player.isTeleporting or isSceneLoading then
      self:Finish()
      return
    end
    player:AddEventListener(self, PlayerModuleEvent.ON_PENDING_STATUS, self.SetSceneSkillInterrupt)
    player:AddEventListener(self, PlayerModuleEvent.ON_STOP_PASSIVE_FALLING, self.OnStopPassiveFalling)
    player:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.OnStop)
    player:AddEventListener(self, PlayerModuleEvent.ON_HANDINHAND, self.UpdateHandInHandFalling)
    self._fallingTime = 0
    self._startFallHeight = player.viewObj:Abs_K2_GetActorLocation().Z
    if player.viewObj.startFallingHeight then
      self._startFallHeight = player.viewObj.startFallingHeight
    end
    player.viewObj.startFallingHeight = self._startFallHeight
    self._bDead = false
    self._sceneSkillInterrupt = false
    self._shouldPlayMontag = true
    self._waitRestart = false
    self._shouldIgnoreDamage = false
    if player and self._isInControl then
      Log.Debug("BP_PassiveFallingAbility_C:OutOfControl")
      self._isInControl = false
      player:SendEvent(PlayerModuleEvent.ON_PLAYER_WILL_OUT_OFF_CONTROL)
    end
    self:EnterState(ABEnum.AbilityState.Casting)
    self._blockHandFalling = false
    Base.Start(self, OnFinished)
  end
end

function BP_PassiveFallingAbility_C:OnStopPassiveFalling()
  if self:IsCasting() and not self._bDead then
    self._shouldIgnoreDamage = true
  end
end

function BP_PassiveFallingAbility_C:OnStop()
  if self:IsCasting() and not self._bDead then
    self:Finish()
  end
end

function BP_PassiveFallingAbility_C:Restart()
  local player = self.caster
  self._fallingTime = 0
  self._acceleTime = 0
  self._startFallHeight = player.viewObj:Abs_K2_GetActorLocation().Z
  if player.viewObj.startFallingHeight then
    self._startFallHeight = player.viewObj.startFallingHeight
  end
  player.viewObj.startFallingHeight = self._startFallHeight
  player.viewObj.bFallHigh = false
  self._bDead = false
  self._sceneSkillInterrupt = false
  self._shouldPlayMontag = true
  self._waitRestart = false
  self._shouldIgnoreDamage = false
end

function BP_PassiveFallingAbility_C:Tick(DeltaSeconds)
  if not self.caster or not self.caster.viewObj then
    return
  end
  local Ban, _ = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_FALLING_DAMAGE, false, false)
  if Ban then
    Log.Debug("BP_PassiveFallingAbility_C is Ban")
    self._shouldIgnoreDamage = true
    return
  end
  if self:IsCasting() and not self._bDead and not self._isMontagePlaying then
    if self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING) then
      self.caster.viewObj.startFallingHeight = nil
      self:Interrupt()
      return
    end
    if self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_BATTLE) or nil ~= self.caster.viewObj:GetRidePet() then
      self._waitRestart = true
      return
    elseif self._waitRestart then
      self:Restart()
    end
    self:UpdateHandInHandFalling()
    if not self._blockHandFalling then
      self._fallingTime = self._fallingTime + DeltaSeconds
      if self._fallingTime > self._deathTime and not self._bDead then
        local player = self.caster
        if player then
          Log.Debug("RoleHPSystem: i wanna to fly")
          self.caster.viewObj.startFallingHeight = nil
          self:ReduceRoleHP(true)
        end
      end
    end
  end
  if self._isMontagePlaying then
    local Caster = self.caster.viewObj
    local AnimInstance = Caster.Mesh:GetAnimInstance()
    local LocomotionAnimIns = AnimInstance:GetLinkedAnimGraphInstanceByTag("Locomotion")
    if not LocomotionAnimIns then
      return
    end
    self._montageTime = self._montageTime + DeltaSeconds
    if self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_FALLING) then
      LocomotionAnimIns:StopSlotAnimation(0.1, "DefaultSlot")
      self._isMontagePlaying = false
      self:Restart()
    else
      if not (not (self._montageTime >= self._minFallAnimTime and self.caster.movementComponent:HasMoveInput()) or self._bDead) or not LocomotionAnimIns:IsPlayingSlotAnimation(self._montage, "DefaultSlot") then
        self._isMontagePlaying = false
        self:Finish()
      end
      if self._lastMoveSpeed < Caster:GetVelocity():Size() then
        self._acceleTime = self._acceleTime + DeltaSeconds
        if self._acceleTime > 0.1 then
          LocomotionAnimIns:StopSlotAnimation(0.1, "DefaultSlot")
          self._isMontagePlaying = false
          self:Finish()
        end
      end
      self._lastMoveSpeed = Caster:GetVelocity():Size()
    end
  end
  if GlobalConfig.ShowShowFallingTime then
    if nil == self._player then
      local playerModule = NRCModuleManager:GetModule("PlayerModule")
      local localPlayer = playerModule.playerModuleData.localPlayer
      self._player = localPlayer
    end
    if self._player then
      local FallZ = self._startFallHeight - self._player.viewObj:Abs_K2_GetActorLocation().Z
      local Cost = 0
      if FallZ < self._reduceLowZ then
        Cost = 0
      elseif FallZ < self._reduceHeavyZ then
        Cost = self._reduceLow
      elseif FallZ < self._reduceDeathZ then
        Cost = FallZ * self._reduceHeavyVar + self._reduceHeavyConst
      else
        Cost = 9999
      end
      UE4.UKismetSystemLibrary:PrintString("\229\157\160\232\144\189\230\151\182\233\151\180\239\188\154" .. self._fallingTime .. "    \229\157\160\232\144\189\233\171\152\229\186\166\239\188\154" .. FallZ .. "   \229\190\133\230\137\163\233\153\164\229\185\178\229\138\178\239\188\154" .. Cost, true, false, UE4.FLinearColor(1, 0, 0, 1), DeltaSeconds)
    end
  end
end

function BP_PassiveFallingAbility_C:SetSceneSkillInterrupt(status, ClearedStatus)
  if ClearedStatus ~= ProtoEnum.WorldPlayerStatusType.WPST_FALLING then
    return
  end
  if status == ProtoEnum.WorldPlayerStatusType.WPST_LANDED then
    local waterDepth = self.caster.viewObj:GetMovementComponent():GetWaterDepth()
    if waterDepth and waterDepth >= self.caster.viewObj:GetMovementComponent().StartSwimWaterDepth then
      self._sceneSkillInterrupt = true
      self._shouldPlayMontag = false
      self.caster.viewObj.startFallingHeight = nil
    end
  elseif status == ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING then
    self._sceneSkillInterrupt = true
    self._shouldPlayMontag = false
    self.caster.viewObj.startFallingHeight = nil
  else
    self._sceneSkillInterrupt = true
  end
end

function BP_PassiveFallingAbility_C:Interrupt()
  UE4.FCycleCounter.Start("BP_PassiveFallingAbility_C:Interrupt")
  Log.Debug("BP_PassiveFallingAbility_C:Interrupt")
  local PlayeBP = self.caster.viewObj
  PlayeBP.EnvInfoComponent:ForceUpdateSurfaceImmediately()
  PlayeBP.CharacterMovement:UpdateWaterDepth()
  local waterDepth = PlayeBP:GetMovementComponent():GetWaterDepth()
  if waterDepth and waterDepth >= PlayeBP:GetMovementComponent().StartSwimWaterDepth or PlayeBP.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Swimming then
    self._sceneSkillInterrupt = true
    self._shouldPlayMontag = false
    self.caster.viewObj.startFallingHeight = nil
  end
  if self._sceneSkillInterrupt or self._isMontagePlaying or self._waitRestart or self._bDead then
    UE4.FCycleCounter.Stop()
    self:Finish()
    return
  end
  if not self._bDead then
    self.caster.viewObj.startFallingHeight = nil
    local player = self.caster
    local FallZ = self._startFallHeight - player.viewObj:Abs_K2_GetActorLocation().Z
    if FallZ < self._minFallHeight then
      Log.Debug("RoleHPSystem: Landed without reduce")
    elseif FallZ < self._reduceLowZ then
    elseif FallZ < self._reduceHeavyZ then
      Log.Debug("RoleHPSystem: Landed [X1,X2) reduce:" .. self._reduceLow)
      self:ReduceRoleHP(false, self._reduceLow)
    elseif FallZ < self._reduceDeathZ then
      local cost = FallZ * self._reduceHeavyVar + self._reduceHeavyConst
      Log.Debug("RoleHPSystem: Landed [X2,X3) reduce:" .. cost)
      self:ReduceRoleHP(false, cost)
    else
      Log.Debug("RoleHPSystem: Landed...ooooooh, dead")
      self:ReduceRoleHP(true)
    end
    self:PlayerMontage()
    if not self._isInControl then
      Log.Debug("BP_PassiveFallingAbility_C:ReturnToControl")
      self._isInControl = true
      player:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
    end
  end
  UE4.FCycleCounter.Stop()
end

function BP_PassiveFallingAbility_C:PlayerMontage()
  Log.Debug("BP_PassiveFallingAbility_C:PlayerMontage")
  if not self._shouldPlayMontag then
    self:Finish()
    return
  end
  local Caster = self.caster.viewObj
  if not (Caster and Caster.Mesh) or not Caster.Mesh:GetAnimInstance() then
    self:Finish()
    return
  end
  local AnimToPlay = 0
  local SpeedZ = -self.caster.viewObj.CharacterMovement.Velocity.Z
  local playerViewObj = self.caster.viewObj
  playerViewObj.bFallHigh = SpeedZ >= self._animEnd1
  if GlobalConfig.ShowShowFallingTime then
    local animText = ""
    if SpeedZ < self._animEnd1 then
      animText = "\228\189\142\231\169\186\239\188\140\231\138\182\230\128\129\230\156\186\230\146\173\230\148\190END1"
      if self.caster.movementComponent:HasMoveInput() then
        animText = "\228\189\142\231\169\186\239\188\140\231\138\182\230\128\129\230\156\186\229\143\160\229\138\160\231\167\187\229\138\168"
      end
    elseif SpeedZ < self._animEnd2 then
      animText = "\230\146\173\230\148\190END2"
    elseif SpeedZ < self._animEnd3 then
      animText = "\230\146\173\230\148\190END3"
    else
      animText = "\230\146\173\230\148\190DIE"
    end
    if self.caster.movementComponent:HasMoveInput() and SpeedZ > self._animEnd1 then
      animText = "\230\156\137\232\190\147\229\133\165\239\188\140\230\146\173\230\148\190\232\185\178\232\183\145"
    end
    Log.Error("\232\144\189\229\156\176\230\151\182\233\128\159\229\186\166\228\184\186: ", SpeedZ, self._bDead and " \229\183\178\230\173\187\228\186\161\239\188\140\230\146\173\230\148\190\230\173\187\228\186\161\229\138\168\228\189\156" or animText)
  end
  if not self._bDead and self.caster.movementComponent:HasMoveInput() and SpeedZ > self._animEnd1 then
    local AnimInstance = Caster.Mesh:GetAnimInstance():GetLinkedAnimGraphInstanceByTag("Locomotion"):GetLinkedAnimGraphInstanceByTag("RM_Locomotion")
    AnimInstance:OnPlayerFallingToMove()
    self:Finish()
    return
  end
  if not self._bDead and SpeedZ < self._animEnd1 then
    self:Finish()
    return
  elseif SpeedZ < self._animEnd2 then
    self._montage = Caster:GetAnimComponent():GetAnimSequenceByName(self._bDead and self.LandDead or self.LandLight)
  elseif SpeedZ < self._animEnd3 then
    self._montage = Caster:GetAnimComponent():GetAnimSequenceByName(self._bDead and self.LandDead or self.LandHeavy)
  else
    self._montage = Caster:GetAnimComponent():GetAnimSequenceByName(self.LandDead)
  end
  local AnimInstance = Caster.Mesh:GetAnimInstance():GetLinkedAnimGraphInstanceByTag("Locomotion")
  AnimInstance:PlaySlotAnimation(self._montage, "DefaultSlot", 0.1, 0.1)
  self._isMontagePlaying = true
  self._montageTime = 0
  self._lastMoveSpeed = Caster:GetVelocity():Size()
end

function BP_PassiveFallingAbility_C:ReduceRoleHP(subAll, subValue)
  if NRCEnv:IsLocalMode() or self._shouldIgnoreDamage then
    return
  end
  local safe = NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.IsSafeZone)
  if safe then
    return
  end
  if GlobalConfig.UseLocalRoleHp then
    return
  end
  local player = self.caster
  if subAll or subValue >= player.roleHPComponent:GetLocalRoleHP() then
    self._bDead = true
    if self.caster.inputComponent then
      self.caster.inputComponent:SetInputEnable(self, false, "LandMontage")
    end
    player.roleHPComponent:SetCustomDeathPerformTime(0.7)
    player.roleHPComponent:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
  else
    player.roleHPComponent:ReduceRoleHP(subValue, ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
  end
end

function BP_PassiveFallingAbility_C:UpdateHandInHandFalling()
  if self.caster then
    local LastBlockHandFalling = self._blockHandFalling
    if self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P) then
      if not self._handinHandPlayer1p then
        self._handinHandPlayer1p = self.caster:GetAnotherTogetherMovePlayer()
      end
      local is1pFalling = true
      if self._handinHandPlayer1p and UE.UObject.IsValid(self._handinHandPlayer1p.viewObj) and self._handinHandPlayer1p.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) then
        is1pFalling = self._handinHandPlayer1p.viewObj.CharacterMovement.MovementMode == UE4.EMovementMode.MOVE_Falling
      end
      self._blockHandFalling = not is1pFalling
    else
      self._blockHandFalling = false
      self._handinHandPlayer1p = nil
    end
    if LastBlockHandFalling ~= self._blockHandFalling then
      self._fallingTime = 0
      if not self._blockHandFalling then
        self.caster.viewObj.startFallingHeight = nil
        self:Restart()
      end
    end
  end
end

function BP_PassiveFallingAbility_C:Finish()
  if not self:IsCasting() then
    return
  end
  local player = self.caster
  if player and not self._isInControl then
    Log.Debug("BP_PassiveFallingAbility_C:ReturnToControl")
    self._isInControl = true
    player:SendEvent(PlayerModuleEvent.ON_PLAYER_RETURN_TO_CONTROL)
  end
  self._waitRestart = false
  self._isMontagePlaying = false
  local Caster = self.caster.viewObj
  if Caster then
    Caster.startFallingHeight = nil
  end
  if Caster and Caster.Mesh and Caster.Mesh:GetAnimInstance() then
    local AnimInstance = Caster.Mesh:GetAnimInstance():GetLinkedAnimGraphInstanceByTag("Locomotion")
    if AnimInstance and AnimInstance:IsPlayingSlotAnimation(self._montage, "DefaultSlot") and not self._bDead then
      AnimInstance:StopSlotAnimation(0.1, "DefaultSlot")
    end
  end
  if self.caster.inputComponent then
    self.caster.inputComponent:SetInputEnable(self, true, "LandMontage")
  end
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PENDING_STATUS, self.SetSceneSkillInterrupt)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_STOP_PASSIVE_FALLING, self.OnStopPassiveFalling)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.OnStop)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_HANDINHAND, self.UpdateHandInHandFalling)
  Base.Finish(self)
end

return BP_PassiveFallingAbility_C
