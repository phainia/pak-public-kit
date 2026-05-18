local TripodRecycle = Class("TripodRecycle")

function TripodRecycle:Ctor(Panel)
  self.Panel = Panel
  Panel.OnTickMultiDelegate:Add(self, self.OnTick)
  Panel.OnDestroyMultiDelegate:Add(self, self.OnDestroy)
  Panel.OnModeChangedDelegate:Add(self, self.OnModeChanged)
end

function TripodRecycle:OnDestroy()
end

function TripodRecycle:OnModeChanged()
  if self.Panel.CurrMode then
    local bFirstEnter = self.Panel.OldMode == nil
    local Mgr = self.Panel.CurrMode.Mgr
    if bFirstEnter then
      if Mgr:IsTripodAvailableMode() then
        self:InternalResetTripodTick()
      else
        self:InternalResetCameraTick()
      end
    else
      local bPrevTripod = Mgr:IsTripodAvailableMode(self.Panel.OldMode)
      local bCurrTripod = Mgr:IsTripodAvailableMode()
      if bPrevTripod ~= bCurrTripod then
        if bCurrTripod then
          self:InternalResetTripodTick()
        else
          self:InternalResetCameraTick()
        end
      end
    end
  end
end

function TripodRecycle:OnTick(Dt)
  if self.Panel.CurrMode and self.Panel.player then
    if self.Panel.CurrMode.Mgr:IsTripodAvailableMode() then
      self:TickRecycleTripod(Dt)
    end
    self:TickRecycleCamera(Dt)
  end
end

function TripodRecycle:InternalResetCameraTick()
  local Mgr = self.Panel.CurrMode.Mgr
  self.waterSurfaceNotifyTips = Mgr.waterSurfaceNotifyTips
  self.warnSeconds = Mgr.warnSeconds
end

function TripodRecycle:InternalResetTripodTick()
  local Mgr = self.Panel.CurrMode.Mgr
  self.ElapsedOutsideSeconds = 0
  self.DisableDistSeconds = Mgr.disableDisSeconds
  self.DisableDist = Mgr.disableDis
  self.bPendingDistOutside = false
  self.ElapsedOutsideWarnSeconds = 0
  self.DisableWarnSeconds = Mgr.warnSeconds
  self.ElapsedFallSeconds = 0
  self.DisableFallSeconds = Mgr.disableFallSeconds
  self.bPendingFallOutside = false
  self.ElapsedFallWarnSeconds = 0
  self.warnTips = Mgr.warnTips
  self.warnSeconds = Mgr.warnSeconds
end

function TripodRecycle:TickRecycleTripod(Dt)
  if self.bPendingDistOutside then
    self.ElapsedOutsideWarnSeconds = self.ElapsedOutsideWarnSeconds + Dt
  end
  if self.bPendingFallOutside then
    self.ElapsedFallWarnSeconds = self.ElapsedFallWarnSeconds + Dt
  end
  if self.ElapsedFallWarnSeconds > self.warnSeconds or self.ElapsedOutsideWarnSeconds > self.warnSeconds then
    self:InternalRecycleTripod()
    return
  end
  if not self.bPendingDistOutside and not self.bPendingFallOutside and self.bTipsShowing then
    self.bTipsShowing = false
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_HideTips)
  end
  local bNeedTips = false
  local Mgr = self.Panel.CurrMode.Mgr
  local Player = self.Panel.player
  local Tripod = Mgr.TakePhotosModeTripod.TripodNpc
  if Tripod and UE.UObject.IsValid(Tripod) then
    local Dist = (Player:GetActorLocation() - Tripod:Abs_K2_GetActorLocation()):Size()
    if Dist > self.DisableDist then
      if not self.bPendingDistOutside then
        self.ElapsedOutsideSeconds = self.ElapsedOutsideSeconds + Dt
        if self.ElapsedOutsideSeconds > self.DisableDistSeconds then
          self.bPendingDistOutside = true
          self.ElapsedOutsideWarnSeconds = 0
          self.ElapsedOutsideSeconds = 0
          bNeedTips = true
        end
      end
    else
      self.ElapsedOutsideSeconds = 0
      self.ElapsedOutsideWarnSeconds = 0
      self.bPendingDistOutside = false
    end
  end
  local bFalling = Player.statusComponent:HasStatus(_G.ProtoEnum.WorldPlayerStatusType.WPST_FALLING)
  if bFalling then
    if not self.bPendingFallOutside then
      self.ElapsedFallSeconds = self.ElapsedFallSeconds + Dt
      if self.ElapsedFallSeconds > self.DisableFallSeconds then
        self.bPendingFallOutside = true
        self.ElapsedFallWarnSeconds = 0
        self.ElapsedFallSeconds = 0
        bNeedTips = true
      end
    end
  else
    self.bPendingFallOutside = false
    self.ElapsedFallSeconds = 0
    self.ElapsedFallWarnSeconds = 0
  end
  if bNeedTips then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, self.warnTips, nil, nil, self.warnSeconds - 0.3)
    self.bTipsShowing = true
  end
end

function TripodRecycle:InternalRecycleTripod()
  self.Panel.OnTickMultiDelegate:Remove(self, self.OnTick)
  Log.Warning("[TakePhoto] InternalRecycleTripod", self.bPendingFallOutside, self.ElapsedFallWarnSeconds, self.bPendingDistOutside, self.ElapsedOutsideSeconds)
  self.Panel:NotifyWarningClose()
end

function TripodRecycle:TickRecycleCamera(Dt)
  local player = self.Panel.player
  local playerView = player.viewObj
  if not UE.UObject.IsValid(playerView) then
    return
  end
  local RayDistance = 100
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    RayDistance = 250
  end
  local HalfHeight = player:GetHalfHeight()
  local HalfHeightVec = UE.FVector(0, 0, HalfHeight)
  local DownOffsetVec = UE.FVector(0, 0, -HalfHeight * 2 - RayDistance)
  local Location = playerView:Abs_K2_GetActorLocation() + HalfHeightVec
  local HitResult, bInWaterSurface = UE.UKismetSystemLibrary.Abs_LineTraceSingleForObjects(UE4Helper.GetCurrentWorld(), Location, Location + DownOffsetVec, {
    UE.EObjectTypeQuery.WaterSurface
  }, false, {}, UE4.EDrawDebugTrace.None, nil, true, UE4.FLinearColor.Red, UE4.FLinearColor.Green, 2)
  local bChanged = self.bInWaterSurface ~= bInWaterSurface
  self.bInWaterSurface = bInWaterSurface
  if bChanged then
    self.bWaitForWarnWaterSurface = true
  end
  if bInWaterSurface and self:InStandRiding(player) and self.bWaitForWarnWaterSurface and not self:InTripodAvailableMode() then
    self.bWaitForWarnWaterSurface = false
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.waterSurfaceNotifyTips, nil, nil, self.warnSeconds)
  end
end

function TripodRecycle:InTripodAvailableMode()
  return self.Panel.CurrMode and self.Panel.CurrMode.Mgr:IsTripodAvailableMode()
end

function TripodRecycle:InStandRiding(player)
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
    local Rider = player:GetRidePetLua()
    if Rider then
      local RideComponent = Rider.owner.viewObj.BP_RideComponent
      local CurrentMovementType = RideComponent.RideMoveType
      local PetId = Rider.config.id
      if PetId ~= self.CachePetId or CurrentMovementType ~= self.CacheMovementType then
        self.CachePetId = PetId
        self.CachePetStandRiding = true
        self.CacheMovementType = CurrentMovementType
        local bInStand = CurrentMovementType == _G.ProtoEnum.SceneRideAllType.SRAT_GROUND or CurrentMovementType == _G.ProtoEnum.SceneRideAllType.SRAT_CLIMB
        if not bInStand then
          self.CachePetStandRiding = false
        else
          local PetConf = _G.DataConfigManager:GetAllRidePet(PetId)
          local MovementList = PetConf.basic_movement_list
          for i, Movement in ipairs(MovementList) do
            local MoveConf = _G.DataConfigManager:GetRideBasicMovement(Movement)
            local MoveType = MoveConf.move_type
            if MoveType == _G.ProtoEnum.SceneRideAllType.SRAT_SWIM then
              self.CachePetStandRiding = false
              break
            end
          end
        end
      end
      return self.CachePetStandRiding
    end
  end
  return true
end

return TripodRecycle
