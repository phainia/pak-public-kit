local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local ScenePlayerThrowSyncBuff = Base:Extend("ScenePlayerThrowSyncBuff")

function ScenePlayerThrowSyncBuff:Ctor(owner, ...)
  Base.Ctor(self, owner)
end

function ScenePlayerThrowSyncBuff:OnBegin(owner, SkillInfo)
  self._waittingSyncAction = true
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
  self.owner.viewObj:SetAimMode(true, 0)
  self.Success = false
  self.G6Skill = SkillInfo.G6Skill
  self.ThrowBallAnim = SkillInfo.ThrowBallAnim
end

function ScenePlayerThrowSyncBuff:OnStatusRefresh(status, subStatus, opCode, params)
  if status ~= ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING then
    return
  end
  local ActionType = params.throw_aim_param.aim_type
  if ActionType == ProtoEnum.AimSyncType.AST_INIT_AIM then
    if self.SkillInfo == nil then
      self.SkillInfo = {}
      self:OnSyncBegin(params.throw_aim_param)
    else
      Log.Error("\229\144\140\230\173\165\229\141\143\232\174\174\229\188\130\229\184\184\239\188\154\233\135\141\229\164\141\229\136\157\229\167\139\229\140\150\230\138\149\230\142\183buff")
    end
  end
  if ActionType == ProtoEnum.AimSyncType.AST_END_THROW then
    if self.SkillInfo == nil then
      Log.Error("\229\144\140\230\173\165\229\141\143\232\174\174\229\188\130\229\184\184\239\188\154\230\151\160\230\138\149\230\142\183\228\191\161\230\129\175")
    else
      self:EndThrow(params.throw_aim_param.is_throw_success, params.throw_aim_param.throw_velocity)
    end
  end
  if ActionType == ProtoEnum.AimSyncType.AST_BALL_CHANGE then
    if self.SkillInfo == nil then
      Log.Error("\229\144\140\230\173\165\229\141\143\232\174\174\229\188\130\229\184\184\239\188\154\230\151\160\230\138\149\230\142\183\228\191\161\230\129\175")
    else
      self:OnBallChange(params.throw_aim_param.throw_item_type, params.throw_aim_param.throw_ball_id, params.throw_aim_param.throw_session_id)
    end
  end
  if ActionType == ProtoEnum.AimSyncType.AST_AIM_ROTATION then
    self.owner.viewObj.AimRotation = UE.FRotator(params.throw_aim_param.aim_rotation.x, params.throw_aim_param.aim_rotation.y, params.throw_aim_param.aim_rotation.z)
  end
end

function ScenePlayerThrowSyncBuff:OnUpdate(deltaTime)
  local ctrlRotation = self.owner.movementComponent.ctrlRot
  ctrlRotation = ctrlRotation or self.owner.viewObj:K2_GetActorRotation()
  self.owner.viewObj.AimRotation = ctrlRotation
  if self.SkillInfo and self.owner and self.owner.viewObj and self.owner.viewObj.Mesh and self.owner.viewObj.Mesh:GetAnimInstance() then
    local Player = self.owner.viewObj
    local AnimInstance = Player.Mesh:GetAnimInstance()
    local RotationAmount = AnimInstance:GetCurveValue("RotationAmount")
    local RidePet = Player.RidePet
    if RidePet then
      RidePet.ViewYawMin = 0
      RidePet.ViewYawMax = 359.99
      local RideAllAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("RideAll")
      if RideAllAnimInstance and RideAllAnimInstance.IsAiming then
        if RidePet.CharacterMovement.Velocity:Size() > 0 then
          RideAllAnimInstance.Angle = 0.0
          self._keepStill = false
        else
          local CameraYaw = ctrlRotation.Yaw
          local PlayerYaw = Player:K2_GetActorRotation().Yaw
          local YawDiff = (CameraYaw - PlayerYaw + 180.0) % 360 - 180.0
          if YawDiff > 90.0 or YawDiff < -90.0 then
            local TargetYaw = CameraYaw
            YawDiff = UE4.UKismetMathLibrary.FClamp(YawDiff, -90.0, 90.0)
            if self._keepStill then
              TargetYaw = CameraYaw - YawDiff
            end
          end
          if self._keepStill then
            RideAllAnimInstance.Angle = YawDiff / 90.0
          else
            RideAllAnimInstance.Angle = 0
          end
          self._keepStill = true
        end
      end
    end
    if UE.UKismetMathLibrary.Vector_IsZero(Player.CharacterMovement.Acceleration) and math.abs(RotationAmount) > 0.001 then
      local comp = self.owner.viewObj.CharacterMovement.UpdatedComponent
      comp:K2_AddWorldRotation(UE.FRotator(0, RotationAmount * deltaTime * 30, 0), false, nil, false)
    end
  end
end

function ScenePlayerThrowSyncBuff:OnSyncBegin(ActionInfo)
  self._waittingSyncAction = false
  self.ThrowItemType = ActionInfo.throw_item_type
  self.BallID = ActionInfo.throw_ball_id
  local BallInfo = DataConfigManager:GetBallAct(100002)
  self.SkillInfo.BallInfo = BallInfo
  self.Strength = self.SkillInfo.BallInfo.Strength
  self.Gravity = self.SkillInfo.BallInfo.Gravity / 1000
  self.isFast = false
  self.hasMode = false
  self.inThrow = false
  self._keepStill = true
  local throwHelper = AbilityHelperManager.GetHelper(AbilityID.AIM_THROW)
  self.SkillInfo.ThrowStat = throwHelper:GetThrowStat(self.owner)
  local ItemInfo = {
    id = ActionInfo.throw_ball_id
  }
  self.SkillInfo.BallLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowBagItem, ItemInfo, ActionInfo.throw_session_id, self.owner.serverData.base.actor_id, ActionInfo.throw_item_type == Enum.BagItemType.BI_PET_BALL)
  if self.SkillInfo.BallLua == nil then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  local ballNPC = self.SkillInfo.BallLua.viewObj
  if not UE4.UObject.IsValidLowLevel(ballNPC) then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  local ProjectileMovement = ballNPC:GetComponentByClass(UE4.UProjectileMovementComponent)
  if not UE4.UObject.IsValidLowLevel(ProjectileMovement) then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  ProjectileMovement:SetActive(false)
  ballNPC:K2_AttachToComponent(self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent), "locator_right_hand", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  if self.SkillInfo and self.SkillInfo.ThrowStat and self.SkillInfo.ThrowStat ~= Enum.SceneThrowAbilityType.STAT_NORMAL and self.owner and self.owner.viewObj and self.owner.viewObj.Mesh then
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    local RideAllAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("RideAll")
    if nil == RideAllAnimInstance then
      AnimInstance.PlayThrow = true
    else
      RideAllAnimInstance.IsInterrupt = false
      RideAllAnimInstance.IsAiming = true
    end
  end
end

function ScenePlayerThrowSyncBuff:OnBallChange(ThrowItemType, ThrowItemID, ThrowSessionID)
  if not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING) then
    return
  end
  if self.BallID and ThrowItemID ~= self.BallID then
    self:ChangeBall(ThrowItemType, ThrowItemID, ThrowSessionID)
  else
    self.SkillInfo.BallLua.ThrowSession:SetSeqID(ThrowItemID)
  end
end

function ScenePlayerThrowSyncBuff:EndThrow(Success, Velocity)
  if self.inThrow then
    return
  end
  self.inThrow = true
  self.Success = Success
  self.ThrowVelocity = UE.FVector(Velocity.x, Velocity.y, Velocity.z)
end

function ScenePlayerThrowSyncBuff:ChangeBall(ThrowItemType, ThrowItemID, ThrowSessionID)
  self.BallID = ThrowItemID
  if self.SkillInfo.BallLua then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowPetBall, self.SkillInfo.BallLua.viewObj)
  end
  self.SkillInfo.BallInfo = DataConfigManager:GetBallAct(ThrowItemID)
  local ItemInfo = {id = ThrowItemID}
  self.SkillInfo.BallLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowBagItem, ItemInfo, ThrowSessionID, self.owner.serverData.base.actor_id, ThrowItemType == Enum.BagItemType.BI_PET_BALL)
  if self.SkillInfo.BallLua == nil then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  local ballNPC = self.SkillInfo.BallLua.viewObj
  if not UE4.UObject.IsValidLowLevel(ballNPC) then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  local ProjectileMovement = ballNPC:GetComponentByClass(UE4.UProjectileMovementComponent)
  if not UE4.UObject.IsValidLowLevel(ProjectileMovement) then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    self.Success = false
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, false)
    return
  end
  ProjectileMovement:SetActive(false)
  ballNPC:K2_AttachToComponent(self.owner.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent), "locator_right_hand", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
end

function ScenePlayerThrowSyncBuff:GetStartPos()
  local handLocation = self.owner.viewObj.Mesh:Abs_GetSocketLocation("locator_right_hand")
  local forward = self.owner.viewObj:GetActorForwardVector()
  return handLocation + forward * UE.FVector(30, 0, 0)
end

function ScenePlayerThrowSyncBuff:OnFinish(param)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_REFRESH, self.OnStatusRefresh)
  self.owner.viewObj:SetAimMode(false, 0)
end

return ScenePlayerThrowSyncBuff
