require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local AbilityErrorCode = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityErrorCode")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local ThrowBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerThrowBuff")
local ThrowSyncBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerThrowSyncBuff")
local BP_ThrowBallBase_C = Base:Extend("BP_ThrowBallBase_C")

function BP_ThrowBallBase_C:Start(OnFinished, throwStat, ThrowInfo, ...)
  if not self.caster then
    self:Interrupt()
    return
  end
  local animComponent = self.caster:GetAnimComponent()
  if not animComponent or not animComponent:GetAnimInstance() then
    Log.Error("anim instance\228\184\141\229\173\152\229\156\168\239\188\140\229\188\186\232\161\140\231\187\136\230\173\162")
    self:Interrupt()
    return
  end
  Base.Start(self, OnFinished)
  local buffComp = self.caster.buffComponent
  if buffComp:HasBuff("ThrowBuff") then
    Base.Finish(self)
    return
  end
  if not self.caster.isLocal then
    self:RefreshThrowAbility()
    local SkillInfo = {
      G6Skill = self.g6SkillClass,
      ThrowBallAnim = self.ThrowBallHeavy
    }
    buffComp:AddBuff("ThrowBuff", ThrowSyncBuff, self.caster, SkillInfo)
    return
  end
  if nil == ThrowInfo then
    Base.Finish(self)
    return
  end
  self.Caster = self.caster.viewObj
  local ItemType = ThrowInfo.ThrowItemType
  local ItemInfo = ThrowInfo.ThrowItemInfo
  self.LockedTarget = ThrowInfo.AutoAimNPC
  self.throwStat = throwStat
  self.throwConfig = DataConfigManager:GetSceneAbilityThrowConf(self.throwStat)
  NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, true)
  self:EnterState(ABEnum.AbilityState.Casting)
  if -1 == ItemType then
    local SkillInfo = ThrowBuff:newThrowSkillBuffInfo()
    SkillInfo.ThrowInfo = {ThrowItemType = -1}
    SkillInfo.maxSpeedCurve = self.maxSpeedCurve
    SkillInfo.typedConfig = self.throwConfig
    SkillInfo.ThrowBallHeavy = self.ThrowBallHeavy
    SkillInfo.ThrowBallLight = self.ThrowBallLight
    SkillInfo.ThrowG6SkillClass = self.ThrowG6SkillClass
    SkillInfo.FastThrowAngleOffset = self.FastThrowAngleOffset
    SkillInfo.AimThrowSpeedOffset = self.AimThrowSpeedOffset
    SkillInfo.HeavyThrowAngle = self.HeavyThrowAngle
    SkillInfo.ThrowStat = self.throwStat
    buffComp:AddBuff("ThrowBuff", ThrowBuff, self.caster, SkillInfo)
    self.caster:GetAnimComponent():GetAnimInstance():SetRootMotionMode(UE.ERootMotionMode.RootMotionFromMontagesOnly)
    self:Finish()
    return
  end
  if nil == ItemType then
    ItemType = 1
  end
  local BallID
  if 1 == ItemType then
    self.BallLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowPetBall, ItemInfo, self.caster:GetServerId())
    BallID = 100002
  else
    self.BallLua = _G.NRCModuleManager:DoCmd(NPCModuleCmd.CreateThrowBagItem, ItemInfo, nil, self.caster:GetServerId())
    BallID = ItemInfo.id
  end
  local BallInfo = DataConfigManager:GetBallAct(BallID)
  if nil == self.BallLua then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, false)
    self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING)
    return
  end
  self.ballNPC = self.BallLua.viewObj
  if not UE4.UObject.IsValidLowLevel(self.ballNPC) then
    Log.Error("\229\146\149\229\153\156\231\144\131\228\184\141\229\143\175\231\148\168")
    NRCModuleManager:DoCmd(MainUIModuleCmd.ShowFrontSight, false)
    self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING)
    return
  end
  local ProjectileMovement = self.ballNPC:GetComponentByClass(UE4.UProjectileMovementComponent)
  ProjectileMovement:SetActive(false)
  self.ballNPC:K2_AttachToComponent(self.Caster:GetComponentByClass(UE4.USkeletalMeshComponent), "locator_right_hand", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, false)
  local SkillInfo = ThrowBuff:newThrowSkillBuffInfo()
  SkillInfo.ThrowInfo = ThrowInfo
  SkillInfo.BallLua = self.BallLua
  SkillInfo.BallInfo = BallInfo
  SkillInfo.maxSpeedCurve = self.maxSpeedCurve
  SkillInfo.typedConfig = self.throwConfig
  SkillInfo.ThrowBallHeavy = self.ThrowBallHeavy
  SkillInfo.ThrowBallLight = self.ThrowBallLight
  SkillInfo.ThrowG6SkillClass = self.ThrowG6SkillClass
  SkillInfo.FastThrowAngleOffset = self.FastThrowAngleOffset
  SkillInfo.AimThrowSpeedOffset = self.AimThrowSpeedOffset
  SkillInfo.HeavyThrowAngle = self.HeavyThrowAngle
  SkillInfo.ThrowStat = self.throwStat
  buffComp:AddBuff("ThrowBuff", ThrowBuff, self.caster, SkillInfo)
  self.caster:GetAnimComponent():GetAnimInstance():SetRootMotionMode(UE.ERootMotionMode.RootMotionFromMontagesOnly)
  self.caster:GetAnimComponent():StopAllMontage(0.1)
  self:Finish()
end

function BP_ThrowBallBase_C:CanCastAbility()
  local canApply, overrideValues, opCode = self.caster.statusComponent:PreApplyStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING)
  if not canApply then
    return AbilityErrorCode.HIGHER_PRIORITY_ABILITY_IS_CASTING
  end
  local buffComp = self.caster.buffComponent
  if buffComp:HasBuff("ThrowBuff") then
    return AbilityErrorCode.ABILITY_IS_CASTING
  end
  return AbilityErrorCode.NO_ERROR
end

function BP_ThrowBallBase_C:RefreshThrowAbility()
  self.throwStat = ProtoEnum.SceneThrowAbilityType.STAT_NORMAL
  if self.caster.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_RIDEALL) then
    self.throwStat = ProtoEnum.SceneThrowAbilityType.STAT_RIDE_WOLF
  end
  self.throwConfig = DataConfigManager:GetSceneAbilityThrowConf(self.throwStat)
end

function BP_ThrowBallBase_C:Interrupt()
  self.caster.statusComponent:RemoveStatus(Enum.WorldPlayerStatusType.WPST_AIMTHROWING)
  self:Finish()
end

function BP_ThrowBallBase_C:Recover(owner, CustomParams)
  Log.Debug("BP_ThrowBallBase_C:Recover")
  if not self.caster.isLocal then
    self:Start()
    if CustomParams and CustomParams.throw_aim_param then
      self.caster:SendEvent(PlayerModuleEvent.ON_STATUS_REFRESH, ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, CustomParams)
    end
  else
    self:Interrupt()
  end
end

function BP_ThrowBallBase_C:Finish(...)
  if self.Caster == nil then
    return
  end
  Base.Finish(self)
  self.isFast = false
  self.Caster = nil
  self.BallLua = nil
  self.ballNPC = nil
  self.LockedTarget = nil
end

function BP_ThrowBallBase_C:Tick()
  if GlobalConfig.ShowPreThrowTrajectory and self.BallLua then
    self:UpdateDirection()
    self:DrawDebugTrajectory()
  end
end

function BP_ThrowBallBase_C:PredictThrow(DrawDebugType, DrawDebugTime)
  local buffComp = self.caster.buffComponent
  if buffComp then
    local buff = buffComp:GetBuff("ThrowBuff")
    if buff then
      buff:UpdateDirection()
      return buff:DrawDebugTrajectory(DrawDebugType, DrawDebugTime)
    end
  end
  return {bHit = false}
end

return BP_ThrowBallBase_C
