local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TakePhotosModule = NRCModuleBase:Extend("TakePhotosModule")
local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")
local TakePhotosModeMgr = require("NewRoco/Modules/System/TakePhotos/Mode/TakePhotosModeMgr")
local MainUIModuleEnum = require("NewRoco/Modules/System/MainUI/MainUIModuleEnum")
local PhotoServer = require("NewRoco/Modules/System/TakePhotos/Helper/PhotoServer")
local TakePhotoControl = require("NewRoco/Modules/System/TakePhotos/Controller/TakePhotoControl")
local PhotoFileDefine = require("NewRoco.Modules.System.TakePhotos.Helper.PhotoFileDefine")

function TakePhotosModule:OnConstruct()
  _G.TakePhotosModuleCmd = reload("NewRoco.Modules.System.TakePhotos.TakePhotosModuleCmd")
  _G.TakePhotosEnum = reload("NewRoco.Modules.System.TakePhotos.TakePhotosEnum")
  self.data = self:SetData("TakePhotosModuleData", "NewRoco.Modules.System.TakePhotos.TakePhotosModuleData")
  self:RegPanel("TakePhotosMainUI", "UMG_TakePhotos_New", Enum.UILayerType.UI_LAYER_MAIN, "In", "Out")
  self:RegPanel("PopupPhotoMomentUI", "UMG_TakePhotos_Moment", Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("PhotoHistoryUI", "UMG_TakePhotos_Film", Enum.UILayerType.UI_LAYER_POPUP, "In", "Out")
  self:RegPanel("PhotoFileViewUI", "UMG_PhotoFileView", Enum.UILayerType.UI_LAYER_POPUP, "In", "Out")
  self:RegPanel("UMG_PhotoFrame", "UMG_PhotoFrame", Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("UMG_PhotoFrame_Open", "UMG_PhotoFrame_Open", Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("UMG_DeletePrompt", "UMG_DeletePrompt", Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("UMG_TakePhotos_Share", "UMG_TakePhotos_Share", Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("UMG_PhotoCropping", "UMG_PhotoCropping", Enum.UILayerType.UI_LAYER_POPUP, nil, nil, true, 2, true)
  if _G.RocoEnv.IS_EDITOR then
    local path = "/Game/NewRoco/Modules/System/TakePhotos/Editor/UMG_TakePhotosRiderEditor"
    self:RegPanel("UMG_TakePhotosRiderEditor", "UMG_TakePhotosRiderEditor", Enum.UILayerType.UI_LAYER_POPUP, nil, nil, nil, nil, nil, path)
  end
  self.ScreenShotService = UE4.UMoreFunPlatformKits.CreateScreenShotService()
  self.ScreenShotServiceRef = UnLua.Ref(self.ScreenShotService)
  self.ModeMgr = TakePhotosModeMgr()
  self.bMakingPhoto = false
  self.PhotoServer = PhotoServer(self)
  self.Controller = TakePhotoControl(self)
  self.data:InitSaveData()
end

function TakePhotosModule:RegPanel(name, path, layer, openAnimName, closeAnimName, customDisableRendering, touchCount, isSingleTouchPanel, customPath)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = customPath or string.format("/Game/NewRoco/Modules/System/TakePhotos/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customDisableRendering or false
  registerData.touchCount = touchCount
  registerData.isSingleTouchPanel = isSingleTouchPanel
  registerData.openAnimName = openAnimName
  registerData.closeAnimName = closeAnimName
  registerData.enablePcEsc = false
  self:RegisterPanel(registerData)
  return registerData
end

function TakePhotosModule:OnActive()
  self.PhotoServer:ConditionReleaseCachedCardPhotos()
  self:RegisterEvent(self, TakePhotosModuleEvent.OnExitTakePhotos, self.OnExitTakePhotos)
  self:RegisterEvent(self, TakePhotosModuleEvent.OnEnterTakePhotos, self.OnEnterTakePhotos)
  self:RegisterEvent(self, TakePhotosModuleEvent.OnRemotePhotoFullEstablished, self.OnRemotePhotoFullEstablished)
  self:RegisterEvent(self, TakePhotosModuleEvent.OnBeginTakingPhotos, self.ExecCmdWithBeforeCapture)
  self:RegisterEvent(self, TakePhotosModuleEvent.OnFinishTakingPhotos, self.ExecCmdWithFinishCapture)
  _G.NRCEventCenter:RegisterEvent("TakePhotosModule", self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
  _G.NRCEventCenter:RegisterEvent("TakePhotosModule", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  _G.NRCEventCenter:RegisterEvent("TakePhotosModule", self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  if not _G.ZoneServer:IsUpstreamLocked() then
    self:OnEnterSceneFinishNtyAck()
  end
end

function TakePhotosModule:OnRelogin()
end

function TakePhotosModule:OnDeactive()
  self:UnRegisterEvent(self, TakePhotosModuleEvent.OnExitTakePhotos)
  self:UnRegisterEvent(self, TakePhotosModuleEvent.OnEnterTakePhotos)
  self:UnRegisterEvent(self, TakePhotosModuleEvent.OnRemotePhotoFullEstablished)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.OpenPanel, self.OnOpenPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  self.Controller:OnDestroy()
end

function TakePhotosModule:OnEnterSceneFinishNtyAck()
  self.PhotoServer:OnEnterSceneFinish()
  self.ModeMgr.TakePhotosModeTripod:OnEnterSceneFinish()
  self.Controller:OnEnterSceneFinish()
  self:ExitTakePhotos()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.statComponent then
    player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO)
    player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF)
    player.statusComponent:ClearStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_TRIPOD)
  end
end

function TakePhotosModule:OnDestruct()
end

function TakePhotosModule:OpenRideEditor()
  if _G.RocoEnv.IS_EDITOR and not self.ModeMgr:IsNoneMode() then
    self:OpenPanel("UMG_TakePhotosRiderEditor")
  end
end

function TakePhotosModule:OpenDebugPanel()
  self:OpenPanel("TakePhotosDebugUI")
end

function TakePhotosModule:CloseDebugPanel()
  self:ClosePanel("TakePhotosDebugUI")
  self.data:Clear()
end

function TakePhotosModule:TryOpenMainPanel()
  if not self.data:IsSaveGameDataReady() then
    return false
  end
  if self:IsDisplayingPhotoFile() then
    return
  end
  return self:InternalEnterTakePhoto()
end

function TakePhotosModule:OnOpenPanel(PanelData)
  local Name = PanelData.panelName
  if "TakePhotosMainUI" == Name or "PhotoHistoryUI" == Name then
    self.data:AddRef()
  end
end

function TakePhotosModule:OnClosePanel(PanelData)
  local Name = PanelData.panelName
  if "TakePhotosMainUI" == Name or "PhotoHistoryUI" == Name then
    self.data:RemoveRef()
    self:ClosePanel("UMG_PhotoFrame_Open")
  end
end

function TakePhotosModule:InternalOpenPhotoFrame(Command, OnFinish, LockConditionDelegate)
  local PanelName = "UMG_PhotoFrame"
  if "Enter" == Command then
    PanelName = "UMG_PhotoFrame_Open"
  end
  if self:HasPanel(PanelName) then
    local panel = self:GetPanel(PanelName)
    if panel then
      panel:OnActive(Command, OnFinish, LockConditionDelegate)
    end
  end
  self:ClosePanel(PanelName)
  self:OpenPanel(PanelName, Command, OnFinish, LockConditionDelegate)
end

function TakePhotosModule:InternalEnterTakePhoto()
  return self.Controller:Enter()
end

function TakePhotosModule:InternalSwitchTakePhoto(OnFinish)
  self:InternalOpenPhotoFrame("Switch", OnFinish)
end

function TakePhotosModule:InternalWorldPreviewTakePhoto(OnFinish)
  self:InternalOpenPhotoFrame("World", OnFinish)
end

function TakePhotosModule:SetForbidRelation(bForbid)
  if bForbid ~= self.bForbidRelationSetting then
    self.bForbidRelationSetting = bForbid
    self:Log("[TakePhoto] SetForbidRelation", bForbid)
    if bForbid then
      NRCModuleManager:DoCmd(MainUIModuleCmd.SetGlobalPetHUDEnabled, false)
      local MainUIModule = NRCModuleManager:GetModule("MainUIModule")
      if MainUIModule then
        MainUIModule:SetGlobalPlayerHudEnabled(false, _G.MainUIModuleEnum.DisableHudOpSource.GlobalForbid)
        MainUIModule:OnCmdIsShowPropTips(false, "TakePhoto")
        MainUIModule:OnCmdIsShowDownTips(false, "TakePhoto")
        MainUIModule:SetRewardTipsEnabled(false, MainUIModuleEnum.RewardTipsDisableReason.TakePhoto)
      end
      self:OpenWithCmd()
      self.ModeMgr:SetTipsEnabled(false)
    else
      NRCModuleManager:DoCmd(MainUIModuleCmd.SetGlobalPetHUDEnabled, true)
      local MainUIModule = NRCModuleManager:GetModule("MainUIModule")
      if MainUIModule then
        MainUIModule:SetGlobalPlayerHudEnabled(true, _G.MainUIModuleEnum.DisableHudOpSource.GlobalForbid)
        MainUIModule:OnCmdIsShowPropTips(true, "TakePhoto")
        MainUIModule:OnCmdIsShowDownTips(true, "TakePhoto")
        MainUIModule:SetRewardTipsEnabled(true, MainUIModuleEnum.RewardTipsDisableReason.TakePhoto)
      end
      self:CloseWithCmd()
      self.ModeMgr:SetTipsEnabled(true)
    end
  end
end

function TakePhotosModule:CloseWithCmd()
end

function TakePhotosModule:OpenWithCmd()
end

function TakePhotosModule:ExecCmdWithBeforeCapture()
  Log.Debug("ExecCmdWithBeforeCapture")
  UE4.UNRCStatics.ExecConsoleCommand("g.GCloseInstanceByEnterQueue 1")
  if self.DelayFinishCaptureCmd then
    _G.DelayManager:CancelDelayById(self.DelayFinishCaptureCmd)
    self.DelayFinishCaptureCmd = nil
  end
end

function TakePhotosModule:ExecCmdWithFinishCapture()
  Log.Debug("ExecCmdWithFinishCapture")
  if self.DelayFinishCaptureCmd then
    _G.DelayManager:CancelDelayById(self.DelayFinishCaptureCmd)
    self.DelayFinishCaptureCmd = nil
  end
  self.DelayFinishCaptureCmd = _G.DelayManager:DelayFrames(1, function()
    Log.Debug("ExecCmdWithFinishCapture Ready")
    self.DelayFinishCaptureCmd = nil
    UE4.UNRCStatics.ExecConsoleCommand("g.GCloseInstanceByEnterQueue 0")
  end)
end

function TakePhotosModule:OnEnterTakePhotos()
  self:Log("[TakePhoto] OnEnterTakePhotos")
end

function TakePhotosModule:OnExitTakePhotos()
  self:Log("[TakePhoto] OnExitTakePhotos")
  self.ModeMgr:CleanupTakePhotos()
  self:ClosePanel("UMG_PhotoFrame_Open")
  if self.DelayTakingPhotoHandle then
    DelayManager:CancelDelayById(self.DelayTakingPhotoHandle)
    self.DelayTakingPhotoHandle = nil
  end
end

function TakePhotosModule:OnRemotePhotoFullEstablished()
  self.Controller.PhotoManager:UpdateRemoteBriefList(self.PhotoServer.AlbumFileList)
end

function TakePhotosModule:IfInTakePhotoState(bExcludeWorldPreview)
  if not bExcludeWorldPreview then
    return self.ModeMgr.CurrMode ~= nil or nil ~= self.ModeMgr.pendingMode
  else
    return self.ModeMgr:IsTripodMode() or self.ModeMgr:Is1PMode()
  end
  return false
end

function TakePhotosModule:IfInTakePhotoHandledMode()
  return self.ModeMgr:Is1PMode()
end

function TakePhotosModule:IfInTakePhotoTripodMode()
  return self.ModeMgr:IsTripodMode()
end

function TakePhotosModule:IfInTakePhotoWorldPreviewMode()
  return self.ModeMgr:IsWorldMode()
end

function TakePhotosModule:TransitTo1P()
  return self.Controller:TransitTo(self.ModeMgr.TakePhotosMode1P)
end

function TakePhotosModule:TransitSelfie()
  return self.Controller:TransitTo(self.ModeMgr.TakePhotosModeSelfie)
end

function TakePhotosModule:TransitToTripod()
  return self.Controller:TransitTo(self.ModeMgr.TakePhotosModeTripod)
end

function TakePhotosModule:TransitToWorld()
  return self.Controller:TransitTo(self.ModeMgr.TakePhotosModeWorld)
end

function TakePhotosModule:UpdatePhotoBigTexture(PhotoPath)
  local Texture = self.data.ThePhotoBigTexture
  if Texture and UE.UObject.IsValid(Texture) and UE.UPlatformImageLibrary.UpdateTexture2DByFile and UE.UPlatformImageLibrary.UpdateTexture2DByFile(Texture, PhotoPath) then
    Log.Debug("[TakePhoto] UpdatePhotoBigTexture", PhotoPath)
    return Texture
  end
  Log.Debug("[TakePhoto] ImportFileAsTexture2D", PhotoPath)
  self.data.ThePhotoBigTexture = UE.UKismetRenderingLibrary.ImportFileAsTexture2D(UE4Helper.GetCurrentWorld(), PhotoPath)
  if self.data.ThePhotoBigTextureRef and UE.UObject.IsValid(self.data.ThePhotoBigTextureRef) then
    UnLua.Unref(self.data.ThePhotoBigTextureRef)
  end
  self.data.ThePhotoBigTextureRef = self.data.ThePhotoBigTexture and UnLua.Ref(self.data.ThePhotoBigTexture)
  return self.data.ThePhotoBigTexture
end

function TakePhotosModule:SharePhoto(Way)
  self:DispatchEvent(TakePhotosModuleEvent.OnReqSharePhoto, Way)
end

function TakePhotosModule:OpenPhotosHistoryPanel(bFromOther)
  if not self.data:IsSaveGameDataReady() then
    return
  end
  self.bInRemoteHistory = bFromOther
  if bFromOther then
    self:ClosePanel("PhotoHistoryUI")
  end
  self:OpenPanel("PhotoHistoryUI", not self.bInRemoteHistory)
end

function TakePhotosModule:OpenPhotosRemoteHistoryPanel()
  self:OpenPhotosHistoryPanel(true)
end

function TakePhotosModule:PopupCustomPhotoFileView(CustomFilePath, DoUpload, ExtraInfo)
  local PhotoData = self.Controller.PhotoManager:AddPhotoByCustomUpload(CustomFilePath, DoUpload)
  self:PopupPhotoFileView(PhotoData, ExtraInfo)
end

function TakePhotosModule:PopupPhotoFileView(PhotoData, ExtraInfo)
  if self:HasPanel("PhotoFileViewUI") then
    local panel = self:GetPanel("PhotoFileViewUI")
    if panel then
      if ExtraInfo then
        panel.ExtraInfo = ExtraInfo
      end
      panel:RefreshByPhotoData(PhotoData)
    end
  else
    if ExtraInfo then
      PhotoData.ExtraInfo = ExtraInfo
    end
    self:OpenPanel("PhotoFileViewUI", PhotoData)
  end
end

function TakePhotosModule:TryExitTakePhotoByTripodDestroyed()
  if self.ModeMgr:IsTripodAvailableMode() and self.ModeMgr.TakePhotosModeTripod:IfThinkNpcDestroyedEffect() then
    self:Log("[TakePhoto] npc destroyed passively, exit take photos...")
    self:ClosePanel("TakePhotosMainUI")
  else
  end
end

function TakePhotosModule:ExitTakePhotos()
  self:LogWarning("[TakePhoto] ExitTakePhotos manually")
  self:ClosePanel("TakePhotosMainUI")
end

function TakePhotosModule:DispatchEvent(eventName, ...)
  self.eventDispatcher:SendEvent(eventName, ...)
  NRCEventCenter:DispatchEvent(eventName, ...)
end

function TakePhotosModule:DisplayDeletePrompt(Data)
  if self:HasPanel("UMG_DeletePrompt") then
    return
  end
  self:OpenPanel("UMG_DeletePrompt", Data)
end

function TakePhotosModule:OpenSharePhotoPanel(PhotoData)
  if not PhotoData then
    Log.Error("cannot found invalid photo data")
    return
  end
  local shareBaseId = _G.Enum.ShareButtonType.SBT_PHOTO
  local sharePartId = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetSharePartIdByShareBaseId, shareBaseId)
  local shareData = {
    shareBaseId = shareBaseId,
    sharePartId = sharePartId,
    photoData = PhotoData
  }
  _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, shareData)
end

function TakePhotosModule:ReportTLog(RealBurstNum, bQuickShot)
  local key = "PhotographLog"
  local roleDataStr = _G.GEMPostManager:GetRoleDataForTLog()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local playerLocationStr = string.format("%d|%d|%d", math.floor(playerLocation.X), math.floor(playerLocation.Y), math.floor(playerLocation.Z))
  RealBurstNum = RealBurstNum or 1
  self.data.CurPhotoMode = 0
  if bQuickShot then
    self.data.CurPhotoMode = 5
  elseif not self.ModeMgr:IsNoneMode() then
    if self.ModeMgr:Is1PMode() then
      self.data.CurPhotoMode = 1
    elseif self.ModeMgr:IsSelfieMode() then
      self.data.CurPhotoMode = 2
    else
      self.data.CurPhotoMode = 4
    end
  end
  local Type = self.data.CurPhotoMode
  local Settings = self.Controller.TakePhotoSettings
  local LastSeconds = Settings and Settings:GetTakePhotoCountDownSeconds() or 0
  local PlayerWatchCamera = Settings and Settings.PlayerLookCamera:IsEnabled() and 1 or 0
  local PetWatchCamera = Settings and Settings.PetLookCamera:IsEnabled() and 1 or 0
  local WithPartner = (player:IsLogicStatus(_G.Enum.SpaceActorLogicStatus.SALS_HOLD_HANDS_LEADER) or player:IsLogicStatus(_G.Enum.SpaceActorLogicStatus.SALS_HOLD_HANDS_GUEST)) and 1 or 0
  local WithPet = player.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_RIDEALL) and 1 or 0
  local PhotoManager = self.Controller.PhotoManager
  local Pose = Settings and Settings:GetSelectedPoseId() or 0
  local Emoji = Settings and Settings:GetSelectedEmojiId() or 0
  local Filter = Settings and Settings:GetSelectedFilterId() or 0
  local PhotoCount = PhotoManager and PhotoManager:GetLocalPhotoNum()
  local CloudPhotoCount = PhotoManager and PhotoManager:GetRemotePhotoNum()
  local value = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", key, roleDataStr, playerLocationStr, Type, RealBurstNum, LastSeconds, PlayerWatchCamera, PetWatchCamera, WithPartner, WithPet, Pose, Emoji, Filter, PhotoCount, CloudPhotoCount)
  _G.GEMPostManager:SendNRCTLog(key, value)
end

function TakePhotosModule:OpenPhotoCroppingPanel(Texture, ConfirmCallback, bUploadToCard, ClipPhoto)
  self:OpenPanel("UMG_PhotoCropping", Texture, ConfirmCallback, bUploadToCard, ClipPhoto)
end

function TakePhotosModule:DownloadCard(Url, bUsingCache, Callback)
  if bUsingCache then
    local LocalPhotoFilePath = self.PhotoServer:GetLocalCachedPhotoFileByUrl(Url)
    if LocalPhotoFilePath then
      Callback(true, LocalPhotoFilePath)
    end
  end
  self.PhotoServer:ReqDownloadCard(Url, Callback)
end

function TakePhotosModule:UploadCard(FilePath, Callback)
  local function OnUploadFinish(bSuccess, ...)
    if bSuccess then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.rolecard_photo_upload_succeed)
    else
      local args = {
        ...
      }
      if #args > 1 and args[2] then
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.rolecard_photo_upload_failed)
      end
    end
    Callback(bSuccess, ...)
  end
  
  self.PhotoServer:ReqUploadTempPhoto(FilePath, ProtoEnum.PlayerPhotoAlbumType.PLAYER_PHOTO_ALBUM_TYPE_CARD, OnUploadFinish)
end

function TakePhotosModule:GetPetLookLensTarget()
  return self.Controller:GetPetLookLensTarget()
end

function TakePhotosModule:IsPetLookLensTargetEnabled()
  return self.Controller:IsPetLookLensTargetEnabled()
end

function TakePhotosModule:GetIdentifyLookViewInfo()
  return self.Controller:GetIdentifyLookViewInfo()
end

function TakePhotosModule:IsDisplayingPhotoFile()
  if self.DelayShotCut then
    return true
  end
  local bLoading = NRCPanelManager:IsLoadingPanel("TakePhotosModule", "PhotoFileViewUI")
  if bLoading then
    return true
  end
  local bHasPanel = self:HasPanel("PhotoFileViewUI")
  if bHasPanel then
    return true
  end
  bLoading = NRCPanelManager:IsLoadingPanel("TakePhotosModule", "PopupPhotoMomentUI")
  if bLoading then
    return true
  end
  bHasPanel = self:HasPanel("PopupPhotoMomentUI")
  if bHasPanel then
    return true
  end
  return false
end

function TakePhotosModule:QuickShotCut()
  if not self.data:IsSaveGameDataReady() then
    Log.Debug("UMG_LobbyMain_C:Photo NotDataReady")
    return false
  end
  if self:IsDisplayingPhotoFile() then
    Log.Debug("UMG_LobbyMain_C:Photo IsDisplayingPhotoFile")
    return
  end
  local bBan = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_TAKE_PHOTO, true, true)
  if bBan then
    return false
  end
  if self.Controller.PhotoManager:IsLocalPhotosFull() then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_storage_max_tips)
    return false
  end
  _G.NRCAudioManager:PlaySound2DAuto(40009004, "QuickShotCut")
  local Data = self.data
  local Size = Data:GetScreenSize()
  local RT, RtRef = self.data:CreateRT(Size)
  local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local cameraManager = player:GetUEController().playerCameraManager
  self:SetForbidRelation(true)
  self:ExecCmdWithBeforeCapture()
  cameraManager:StartCaptureImmediately(RT)
  self:ExecCmdWithFinishCapture()
  self:SetForbidRelation(false)
  self.DelayShotCut = _G.DelayManager:DelayFrames(1, function()
    self.DelayShotCut = nil
    assert(RT)
    assert(RtRef)
    assert(UE.UObject.IsValid(RT))
    local PhotoData = self.Controller.PhotoManager:AddPhotoByTakingPhoto(RT)
    if not PhotoData then
      RtRef = nil
      UnLua.Unref(RT)
      Log.Error("UMG_LobbyMain_C:Photo NoPhotoData")
      return
    end
    PhotoData:AttachSection({})
    PhotoData.OnRenderTextureSerialized:Add(self, function(_)
      RtRef = nil
      UnLua.Unref(RT)
    end)
    self:OpenPanel("PopupPhotoMomentUI", function()
      self:PopupPhotoFileView(PhotoData)
    end)
    self:ReportTLog(1, true)
  end)
  return true
end

function TakePhotosModule:OnCmdGetCurPhotoMode()
  return self.data.CurPhotoMode
end

function TakePhotosModule:ZoneAddPetRecordAndShareReq(PetBaseId)
  local Req = _G.ProtoMessage:newZoneAddPetRecordAndShareReq()
  Req.base_id = PetBaseId
  Log.Debug("ZoneAddPetRecordAndShareReq", PetBaseId)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ADD_PET_RECORD_AND_SHARE_REQ, Req, self, self.OnZoneAddPetRecordAndShareRsp)
end

function TakePhotosModule:OnZoneAddPetRecordAndShareRsp(Rsp)
  Log.Debug("OnZoneAddPetRecordAndShareRsp", Rsp.ret_info and Rsp.ret_info.ret_code)
end

function TakePhotosModule:IsPetInHandbook(PetBaseId)
  return self.data:IsPetInHandbook(PetBaseId)
end

function TakePhotosModule:OnCmdSyncPhotoToken(Notify)
  if Notify then
    self:DispatchEvent(TakePhotosModuleEvent.OnSyncPhotoToken, Notify.actor_id, Notify.camera_npc_id)
  end
end

function TakePhotosModule:SetSelfiePlayerLookAtOffset(bClear)
  if bClear then
    self.SelfiePlayerLookAtOffset = nil
  else
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local leftHandCamera = player.viewObj.LeftHandCamera
    local poseConf = DataConfigManager:GetTakePhotoPoseConf(self.Controller.TakePhotoSettings:GetSelectedPoseId(), true)
    if poseConf and poseConf.look_at then
      local look_at = poseConf.look_at
      local Offset
      if leftHandCamera then
        Offset = UE.FVector(look_at[1], -look_at[2], look_at[3])
      else
        Offset = UE.FVector(look_at[1], look_at[2], look_at[3])
      end
      self.SelfiePlayerLookAtOffset = Offset
    else
      self.SelfiePlayerLookAtOffset = nil
    end
  end
end

function TakePhotosModule:GetSelfiePlayerLookAtOffset()
  return self.SelfiePlayerLookAtOffset
end

function TakePhotosModule:OnCmdCheckPhotoFileViewUI()
  return self:HasPanel("PhotoFileViewUI")
end

return TakePhotosModule
