local TakePhotosUtils = {}

function TakePhotosUtils.ToggleCameraFromWorldToTripod(TripodActor)
  Log.Info("[TakePhoto] ToggleCameraFromWorldToTripod:", TripodActor)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local controller = player:GetUEController()
  controller:ChangeToCustomCamera(TripodActor)
  TakePhotosUtils.ResetTripodCameraView(TripodActor)
end

function TakePhotosUtils.ToggleTripodStatus(bClear)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if bClear then
    player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD)
  else
    player.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD)
  end
end

function TakePhotosUtils.OnAvatarReadyIn1PMode()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SetVisible(false, true, true, true)
  if UE.UObject.IsValid(player.viewObj) then
    player.viewObj.CharacterMovement.bUseControllerDesiredRotation = true
  end
end

local TakePhotoHiddenPlayerDelayId

function TakePhotosUtils.ToggleCameraFromWorldTo1P()
  Log.Info("[TakePhoto] ToggleCameraFromWorldTo1P")
  if TakePhotoHiddenPlayerDelayId then
    DelayManager:CancelDelayById(TakePhotoHiddenPlayerDelayId)
    TakePhotoHiddenPlayerDelayId = nil
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraMgr = player:GetUEController().playerCameraManager
  if not cameraMgr then
    return
  end
  if UE.UObject.IsValid(player.viewObj) then
    player.viewObj:SetHiddenMask(true, UE.EPlayerForceHiddenType.TakePhoto)
    if player.viewObj.BP_RideComponent then
      local ridePet = player.viewObj.BP_RideComponent.RidePet
      if ridePet then
        ridePet:SetHiddenMask(false, UE.EPlayerForceHiddenType.TakePhoto)
      end
    end
    player.viewObj.CharacterMovement.bUseControllerDesiredRotation = true
    player.viewObj:SetEightDirectionMoveEnable(true)
  end
  cameraMgr.FirstPersonView = true
  TakePhotosUtils.Reset1PCameraView()
  player.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO)
  TakePhotosUtils.HideOverlapPlayers()
  if _G.RocoEnv.IS_EDITOR and _G.TakePhotoEditorTools then
    _G.TakePhotoEditorTools.Get():Apply1PCameraOffset()
  end
  player:GetUEController():SetFadeEnable(false)
end

function TakePhotosUtils.HideOverlapPlayers()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player.viewObj and player.viewObj.ActionArea then
    local statusId = ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL
    local customParams = player.statusComponent:GetCustomParams(statusId)
    local TempArray = UE.TArray(UE.AActor)
    player.viewObj.ActionArea:GetOverlappingActors(TempArray, UE.ARocoPlayerBase)
    for _, v in tpairs(TempArray) do
      if v and v.sceneCharacter then
        local scenePlayer = v.sceneCharacter
        if not scenePlayer.isLocal then
          local otherCharacter = scenePlayer
          if customParams and customParams.ride_param and 0 ~= (customParams.ride_param.double_ride_1p_id or 0) and customParams.ride_param.double_ride_1p_id == otherCharacter.serverData.base.actor_id then
            local dist = (otherCharacter.viewObj.Mesh:Abs_K2_GetComponentLocation() - player.viewObj.Mesh:Abs_K2_GetComponentLocation()):Size()
            if dist > 35 then
          end
          elseif customParams and customParams.ride_param and 0 ~= (customParams.ride_param.double_ride_2p_id or 0) and customParams.ride_param.double_ride_2p_id == otherCharacter.serverData.base.actor_id then
          elseif otherCharacter:IsTogetherMove2P() and otherCharacter:GetAnotherTogetherMovePlayer() == player then
          else
            local bPlayerOnly = false
            local otherCustomParams = otherCharacter.statusComponent:GetCustomParams(statusId)
            if otherCustomParams and otherCustomParams.ride_param and (0 ~= (otherCustomParams.ride_param.double_ride_1p_id or 0) or 0 ~= (otherCustomParams.ride_param.double_ride_2p_id or 0)) then
              bPlayerOnly = true
            end
            scenePlayer:SetVisible(false, true, bPlayerOnly, true)
          end
        end
      end
    end
  end
end

function TakePhotosUtils.ToggleCameraFromWorldToSelfie(CameraActor)
  Log.Info("[TakePhoto] ToggleCameraFromWorldToSelfie:", CameraActor)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local controller = player:GetUEController()
  controller:ChangeToCustomCamera(CameraActor)
  TakePhotosUtils.ResetSelfieCameraView(CameraActor)
  player.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF)
end

function TakePhotosUtils.ResetSelfieCameraView(CameraActor, InitTransform)
  Log.Info("[TakePhoto] ResetSelfieCameraView")
  if InitTransform and UE.UObject.IsValid(CameraActor) then
    CameraActor:Abs_K2_SetActorTransform_WithoutHit(InitTransform)
  end
  local fov = TakePhotosEnum.TPGlobalNum("takephoto_myself_FOV_initial", 90)
  TakePhotosUtils.ChaneFOV(fov)
end

function TakePhotosUtils.ExistCameraFromSelfieToWorld()
  Log.Info("[TakePhoto] ExistCameraFromSelfieToWorld")
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local controller = player:GetUEController()
  if not controller or not UE.UObject.IsValid(controller) then
    return
  end
  controller:ReleaseRocoCamera(0, 0, 0, true)
  player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF)
end

function TakePhotosUtils.ExistCameraFrom1PToWorld(bExitTakePhoto)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraMgr = player:GetUEController().playerCameraManager
  if not cameraMgr then
    Log.Error("[TakePhoto] cannot found player manager")
    return
  end
  if bExitTakePhoto then
    TakePhotoHiddenPlayerDelayId = DelayManager:DelayFrames(2, function()
      TakePhotoHiddenPlayerDelayId = nil
      if UE.UObject.IsValid(player.viewObj) then
        player.viewObj:SetHiddenMask(false, UE.EPlayerForceHiddenType.TakePhoto)
      end
    end)
  else
    player.viewObj:SetHiddenMask(false, UE.EPlayerForceHiddenType.TakePhoto)
  end
  player.viewObj.CharacterMovement.bUseControllerDesiredRotation = false
  player.viewObj:SetEightDirectionMoveEnable(false)
  cameraMgr.FirstPersonView = false
  player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO)
  TakePhotosUtils.ShowOverlapPlayers()
  if bExitTakePhoto then
  end
  player:GetUEController():SetFadeEnable(true)
end

function TakePhotosUtils.ShowOverlapPlayers()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player.viewObj and player.viewObj.ActionArea then
    local TempArray = UE.TArray(UE.AActor)
    player.viewObj.ActionArea:GetOverlappingActors(TempArray, UE.ARocoPlayerBase)
    for _, v in tpairs(TempArray) do
      if v and v.sceneCharacter then
        local scenePlayer = v.sceneCharacter
        if not scenePlayer.isLocal then
          scenePlayer:SetVisible(true, true, true, true)
        end
      end
    end
  end
end

function TakePhotosUtils.ExistCameraFromTripodToWorld()
  Log.Info("[TakePhoto] ExistCameraFromTripodToWorld")
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local controller = player:GetUEController()
  controller:ReleaseRocoCamera(0, 0, 0, true)
end

function TakePhotosUtils.Reset1PCameraView()
  local fov = TakePhotosEnum.TPGlobalNum("takephoto_hand_camera_fov", 90)
  TakePhotosUtils.ChaneFOV(fov)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local rotation = player.viewObj:K2_GetActorRotation()
    local controlRotation = player.ueController:GetControlRotation()
    rotation.Pitch = 0
    rotation.Roll = 0
    player.ueController:SetControlRotation(rotation)
  end
end

function TakePhotosUtils.ResetTripodCameraView(TripodActor, InitTransform)
  Log.Info("[TakePhoto] ResetTripodCameraView")
  if InitTransform and UE.UObject.IsValid(TripodActor) then
    TripodActor:Abs_K2_SetActorTransform_WithoutHit(InitTransform)
  end
  local fov = TakePhotosEnum.TPGlobalNum("takephoto_mount_camera_fov", 90)
  TakePhotosUtils.ChaneFOV(fov)
end

function TakePhotosUtils.ChaneFOV(InFOV)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraMgr = player:GetUEController().playerCameraManager
  if not cameraMgr then
    return
  end
  cameraMgr.FOV = InFOV
end

function TakePhotosUtils.ChangeRoll(InRoll)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local controller = player:GetUEController()
  if not controller or not UE.UObject.IsValid(controller) then
    return
  end
  local cameraMgr = player:GetUEController().playerCameraManager
  if not cameraMgr then
    return
  end
  cameraMgr.TakePhotoModifier.Roll = -InRoll
end

function TakePhotosUtils.DisableTakePhotoFilter(CurrentFilterConf)
  Log.Debug("[TakePhoto] DisableTakePhotoFilter", CurrentFilterConf.name)
end

function TakePhotosUtils.EnableTakePhotoFilter(DesiredFilterConf)
  Log.Debug("[TakePhoto] EnableTakePhotoFilter", DesiredFilterConf.name)
end

function TakePhotosUtils.EnablePlayerEmoji(Player, EmojiConf, DesiredAnimResource)
  Log.Debug("[TakePhoto] EnablePlayerEmoji", EmojiConf.name, DesiredAnimResource)
  local Success = TakePhotosUtils.PlayAnim(Player, DesiredAnimResource, true)
  return Success
end

function TakePhotosUtils.DisablePlayerEmoji(Player, EmojiConf, CurrentAnimResource)
  Log.Debug("[TakePhoto] DisablePlayerEmoji", EmojiConf.name)
  TakePhotosUtils.StopAnim(Player, CurrentAnimResource, true)
end

function TakePhotosUtils.PlayAnim(Player, Anim, bAdditive)
  if not Anim or not UE.UObject.IsValid(Anim) then
    Log.Error("[TakePhoto] invalid animation")
    return
  end
  local ViewObj = Player.viewObj
  if not ViewObj or not UE.UObject.IsValid(ViewObj) then
    Log.Error("[TakePhoto] invalid player")
    return
  end
  local AnimComponent = ViewObj:GetAnimComponent()
  if not AnimComponent then
    Log.Error("[TakePhoto] invalid anim component")
    return
  end
  local Len = 0
  if bAdditive then
    Len = AnimComponent:PlayAdditiveAnim(Anim, 1, 0, -1)
  else
    Len = AnimComponent:PlayAnim(Anim, 1, 0, -1, 0, 1, 0, nil)
  end
  Log.Debug("[TakePhoto] start play", Anim, Len)
  return Len > 0
end

function TakePhotosUtils.PlaySelfPhotoAnim(Player, Anim)
  if not Anim or not UE.UObject.IsValid(Anim) then
    Log.Error("[TakePhoto] invalid animation")
    return
  end
  local ViewObj = Player.viewObj
  if not ViewObj or not UE.UObject.IsValid(ViewObj) then
    Log.Error("[TakePhoto] invalid player")
    return
  end
  local AnimInstance = ViewObj.Mesh:GetAnimInstance()
  if not UE.UObject.IsValid(AnimInstance) then
    Log.Error("[TakePhoto] invalid AnimInstance")
    return
  end
  local QSAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("PlayerQS")
  QSAnimInstance:PlaySlotAnimation(Anim, "UpperBody", 0.15, 0.15, 1, 10000000)
  ViewObj.HasCustomSelfPhotoPose = true
end

function TakePhotosUtils.StopSelfPhotoAnim(Player, Anim)
  if not Anim or not UE.UObject.IsValid(Anim) then
    Log.Error("[TakePhoto] invalid animation")
    return
  end
  local ViewObj = Player.viewObj
  if not ViewObj or not UE.UObject.IsValid(ViewObj) then
    Log.Error("[TakePhoto] invalid player")
    return
  end
  local AnimInstance = ViewObj.Mesh:GetAnimInstance()
  if not UE.UObject.IsValid(AnimInstance) then
    Log.Error("[TakePhoto] invalid AnimInstance")
    return
  end
  local QSAnimInstance = AnimInstance:GetLinkedAnimGraphInstanceByTag("PlayerQS")
  QSAnimInstance:StopSlotAnimation(0, "UpperBody")
  ViewObj.HasCustomSelfPhotoPose = false
end

function TakePhotosUtils.StopAnim(Player, Anim, bAdditive)
  if not Anim or not UE.UObject.IsValid(Anim) then
    Log.Error("[TakePhoto] invalid animation")
    return
  end
  local ViewObj = Player.viewObj
  if not ViewObj or not UE.UObject.IsValid(ViewObj) then
    Log.Error("[TakePhoto] invalid player")
    return
  end
  local AnimComponent = ViewObj:GetAnimComponent()
  if not AnimComponent then
    Log.Error("[TakePhoto] invalid anim component")
    return
  end
  Log.Debug("[TakePhoto] stop play", Anim)
  if bAdditive then
    AnimComponent:StopAdditiveAnim(Anim, 0)
  else
    AnimComponent:StopAnim(Anim, 0, nil)
  end
end

function TakePhotosUtils.EnablePlayerPoseAction(Player, PoseConf, DesiredAnimResource)
  Log.Debug("[TakePhoto] EnablePlayerPoseAction", PoseConf.name, DesiredAnimResource)
  local Success = TakePhotosUtils.PlaySelfPhotoAnim(Player, DesiredAnimResource)
  return Success
end

function TakePhotosUtils.DisablePlayerPoseAction(Player, PoseConf, CurrentAnimResource)
  Log.Debug("[TakePhoto] DisablePlayerPoseAction", PoseConf.name, CurrentAnimResource)
  TakePhotosUtils.StopSelfPhotoAnim(Player, CurrentAnimResource)
end

function TakePhotosUtils.ChangeFashionWardrobe(Index, Mode)
  Log.Warning("[TakePhoto] Use fashion wardrobe index", Index)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnWardrobeIndexChanged, Index, true)
end

function TakePhotosUtils.SetRideFirstPersonViewOffset(offsetX, offsetY, offsetZ)
  if not TakePhotosUtils.TempFVector then
    TakePhotosUtils.TempFVector = UE.FVector()
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if UE.UObject.IsValid(player.viewObj) and player.viewObj.BP_RideComponent then
    local ridePet = player:GetRidePetBP()
    if ridePet then
      TakePhotosUtils.TempFVector.X = offsetX
      TakePhotosUtils.TempFVector.Y = offsetY
      TakePhotosUtils.TempFVector.Z = offsetZ
      ridePet.EyesViewPointOffset = TakePhotosUtils.TempFVector
    end
  end
end

function TakePhotosUtils.GetEnvActor()
  local Instance = UE.UNRCPlatformGameInstance.GetInstance()
  local EnvSys = Instance and Instance:GetWorldSubSystem()
  if EnvSys then
    local CurEnvActor = EnvSys:GetEnvActor()
    return CurEnvActor
  end
end

function TakePhotosUtils.ChangePostProgressFocalScale(Value)
  local EnvActor = TakePhotosUtils.GetEnvActor()
  if EnvActor then
    local Scale = EnvActor.PostProcess.Settings.DepthOfFieldScale
    local bEnable = Value > 0.001 or Scale > 0.001
    EnvActor.PostProcess.Settings.bOverride_MobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bOverride_StableMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bStableMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bOverride_DepthOfFieldScale = bEnable
    EnvActor.PostProcess.Settings.DepthOfFieldScale = Value
  end
end

function TakePhotosUtils.ChangePostProgressFocalRegion(Value)
  local EnvActor = TakePhotosUtils.GetEnvActor()
  if EnvActor then
    local Region = EnvActor.PostProcess.Settings.DepthOfFieldFocalRegion
    local bEnable = Value > 0.001 or Region > 0.001
    EnvActor.PostProcess.Settings.bOverride_MobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bOverride_StableMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bStableMobileHQGaussian = bEnable
    EnvActor.PostProcess.Settings.bOverride_DepthOfFieldFocalRegion = bEnable
    EnvActor.PostProcess.Settings.DepthOfFieldFocalRegion = Value
  end
end

function TakePhotosUtils.ResetPostProgressFocalRegion()
  local EnvActor = TakePhotosUtils.GetEnvActor()
  if EnvActor then
    EnvActor.PostProcess.Settings.bOverride_MobileHQGaussian = false
    EnvActor.PostProcess.Settings.bMobileHQGaussian = false
    EnvActor.PostProcess.Settings.bOverride_StableMobileHQGaussian = false
    EnvActor.PostProcess.Settings.bStableMobileHQGaussian = false
    EnvActor.PostProcess.Settings.bOverride_DepthOfFieldFocalRegion = false
    EnvActor.PostProcess.Settings.DepthOfFieldFocalRegion = 0
    EnvActor.PostProcess.Settings.bOverride_DepthOfFieldScale = false
    EnvActor.PostProcess.Settings.DepthOfFieldScale = 0
  end
end

return TakePhotosUtils
