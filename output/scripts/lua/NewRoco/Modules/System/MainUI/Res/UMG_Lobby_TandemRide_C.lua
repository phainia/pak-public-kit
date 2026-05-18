local UMG_Lobby_TandemRide_C = _G.NRCPanelBase:Extend("UMG_Lobby_TandemRide_C")
local LogicStatusToPlayerCondition = {
  [ProtoEnum.SpaceActorLogicStatus.SALS_TEST] = ProtoEnum.PlayerConditionType.PCT_TEST,
  [ProtoEnum.SpaceActorLogicStatus.SALS_DUNGEON] = ProtoEnum.PlayerConditionType.PCT_DUNGEON,
  [ProtoEnum.SpaceActorLogicStatus.SALS_OPEN_UI_NOT_FULL_SCENE] = ProtoEnum.PlayerConditionType.PCT_UI,
  [ProtoEnum.SpaceActorLogicStatus.SALS_OPEN_UI_FULL_SCENE] = ProtoEnum.PlayerConditionType.PCT_FULLSCREEN_UI,
  [ProtoEnum.SpaceActorLogicStatus.SALS_PLAY_CG] = ProtoEnum.PlayerConditionType.PCT_CG,
  [ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING] = ProtoEnum.PlayerConditionType.PCT_BATTLE,
  [ProtoEnum.SpaceActorLogicStatus.SALS_INTERACTING] = ProtoEnum.PlayerConditionType.PCT_OPTION,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TELEPORT] = ProtoEnum.PlayerConditionType.PCT_TELEPORT,
  [ProtoEnum.SpaceActorLogicStatus.SALE_REVIVE] = ProtoEnum.PlayerConditionType.PCT_REVIVE,
  [ProtoEnum.SpaceActorLogicStatus.SALS_MATCHING] = ProtoEnum.PlayerConditionType.PCT_MATCHING,
  [ProtoEnum.SpaceActorLogicStatus.SALS_MINI_GAME] = ProtoEnum.PlayerConditionType.PCT_MINI_GAME,
  [ProtoEnum.SpaceActorLogicStatus.SALS_UNINTERRUPTIBLE_INTERACTING] = ProtoEnum.PlayerConditionType.PCT_UNINTERRUPTIBLE_INTERACTING,
  [ProtoEnum.SpaceActorLogicStatus.SALS_VISITING] = ProtoEnum.PlayerConditionType.PCT_VISITING,
  [ProtoEnum.SpaceActorLogicStatus.SALS_WORLD_COMBAT] = ProtoEnum.PlayerConditionType.PCT_WORLD_COMBATING,
  [ProtoEnum.SpaceActorLogicStatus.SALS_CHANGE_EGG] = ProtoEnum.PlayerConditionType.PCT_CHANGE_EGG,
  [ProtoEnum.SpaceActorLogicStatus.SALS_PK_PREPARE] = ProtoEnum.PlayerConditionType.PCT_PK_PREPARE,
  [ProtoEnum.SpaceActorLogicStatus.SALS_INVITE] = ProtoEnum.PlayerConditionType.PCT_INVITE,
  [ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_INTERACT_INVITE] = ProtoEnum.PlayerConditionType.PCT_PLAYER_INTERACT_INVITE,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TRANSFORM] = ProtoEnum.PlayerConditionType.PCT_TRANSFORMED,
  [ProtoEnum.SpaceActorLogicStatus.SALS_DOUBLE_RIDE_GUEST] = ProtoEnum.PlayerConditionType.PCT_DOUBLE_RIDE_GUEST,
  [ProtoEnum.SpaceActorLogicStatus.SALS_STATIC_SCENE_NOPK] = ProtoEnum.PlayerConditionType.PCT_STATIC_SCENE_NOPK,
  [ProtoEnum.SpaceActorLogicStatus.SALS_STATIC_SCENE_TYPEA] = ProtoEnum.PlayerConditionType.PCT_STATIC_SCENE_TYPEA,
  [ProtoEnum.SpaceActorLogicStatus.SALS_STATIC_SCENE_TYPEB] = ProtoEnum.PlayerConditionType.PCT_STATIC_SCENE_TYPEB,
  [ProtoEnum.SpaceActorLogicStatus.SALS_STATIC_SCENE_TYPEC] = ProtoEnum.PlayerConditionType.PCT_STATIC_SCENE_TYPEC,
  [ProtoEnum.SpaceActorLogicStatus.SALS_STATIC_SCENE_TYPED] = ProtoEnum.PlayerConditionType.PCT_STATIC_SCENE_TYPED,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TAKE_PHOTO_HANDHELD] = ProtoEnum.PlayerConditionType.PCT_TAKE_PHOTO_HANDHELD,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TAKE_PHOTO_TRIPOD_CAMERA] = ProtoEnum.PlayerConditionType.PCT_TAKE_PHOTO_TRIPOD_CAMERA,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TAKE_PHOTO_TRIPOD_WORLD] = ProtoEnum.PlayerConditionType.PCT_TAKE_PHOTO_TRIPOD_WORLD,
  [ProtoEnum.SpaceActorLogicStatus.SALS_TAKE_PHOTO_MYSELF] = ProtoEnum.PlayerConditionType.PCT_TAKE_PHOTO_MYSELF
}

function UMG_Lobby_TandemRide_C:OnActive()
end

function UMG_Lobby_TandemRide_C:OnDeactive()
end

function UMG_Lobby_TandemRide_C:OnAddEventListener()
  if self.module then
    self.module:RegisterEvent(self, MainUIModuleEvent.TandemRidingStart, self.TandemRidingStart)
    self.module:RegisterEvent(self, MainUIModuleEvent.TandemRidingEnd, self.TandemRidingEnd)
  end
end

function UMG_Lobby_TandemRide_C:OnTick()
  if not self.needTick then
    return
  end
  if not self.rideSkillBuff then
    self:TandemRidingEnd()
    return
  end
  local newLockPlayer = self.rideSkillBuff.LockedPlayer
  if newLockPlayer and newLockPlayer.viewObj then
    if not self.lastLockPlayer then
      self:StopAllAnimations()
      self:SetVisibility(UE4.ESlateVisibility.Visible)
      self:PlayAnimation(self.Lock_in)
    end
    local UpVector = UE.FVector(0, 0, 60)
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local Ctrl = localPlayer:GetUEController()
    local ScreenPos = UE.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(Ctrl, newLockPlayer.viewObj:K2_GetActorLocation() + UpVector, nil, false)
    if UE4Helper.IsPCMode() then
      ScreenPos.X = ScreenPos.X * 1.1364 + 36
      ScreenPos.Y = ScreenPos.Y * 1.1364
    end
    if self.MainSlot then
      self.MainSlot:SetPosition(ScreenPos)
    end
    local statusInfo = newLockPlayer.LogicStatusComponent.StatusInfo
    local Enable = true
    for _, item in pairs(statusInfo) do
      local Condition = LogicStatusToPlayerCondition[item.status]
      if Condition then
        local cfg = DataConfigManager:GetFunctionBanConf(Condition, true)
        if cfg and cfg.function_ban_list[ProtoEnum.PlayerFunctionBanType.PFBT_DOUBLE_RIDE_INVITE + 1].function_ban_switch then
          Enable = false
        end
      end
    end
    if Enable ~= self.LastEnable then
      self.LastEnable = Enable
      if Enable then
        self.lu:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#e7dac0ff"))
        self.ru:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#e7dac0ff"))
        self.rd:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#e7dac0ff"))
        self.ld:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#e7dac0ff"))
      else
        self.lu:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#921111ff"))
        self.ru:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#921111ff"))
        self.rd:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#921111ff"))
        self.ld:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#921111ff"))
      end
    end
  elseif self.lastLockPlayer then
    self:StopAllAnimations()
    self:PlayAnimation(self.Lock_out)
  end
  self.lastLockPlayer = newLockPlayer
end

function UMG_Lobby_TandemRide_C:OnConstruct()
  self:OnAddEventListener()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.needTick = false
  self.LastEnable = nil
end

function UMG_Lobby_TandemRide_C:OnDestruct()
  if self.module then
    self.module:UnRegisterEvent(self, MainUIModuleEvent.TandemRidingStart)
    self.module:UnRegisterEvent(self, MainUIModuleEvent.TandemRidingEnd)
  end
end

function UMG_Lobby_TandemRide_C:TandemRidingStart(RideSkillBuff)
  self.MainSlot = self.module:GetPanel("LobbyMain").UMG_Lobby_TandemRide.Slot
  self.needTick = true
  self.rideSkillBuff = RideSkillBuff
  self.lastLockPlayer = nil
  self:StopAllAnimations()
end

function UMG_Lobby_TandemRide_C:TandemRidingEnd()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.needTick = false
  self.rideSkillBuff = nil
  self.lastLockPlayer = nil
  self:StopAllAnimations()
end

function UMG_Lobby_TandemRide_C:OnAnimationFinished(Anim)
  if Anim == self.Lock_in and self.lastLockPlayer then
    self:PlayAnimation(self.Lock_loop)
  end
  if Anim == self.Lock_out and not self.lastLockPlayer then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Lobby_TandemRide_C
