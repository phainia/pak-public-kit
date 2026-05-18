local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local UMG_NRCMedia_C = _G.NRCViewBase:Extend("UMG_NRCMedia_C")
local VIDEO_STATE = {
  NOT_SET = 0,
  SET_NOT_PLAYED = 1,
  PLAYED = 2
}
local MediaPlayer_Event = {
  OnEndReached = "OnEndReached",
  OnMediaOpenFailed = "OnMediaOpenFailed",
  OnMediaOpened = "OnMediaOpened",
  OnMediaClosed = "OnMediaClosed",
  OnSeekCompleted = "OnSeekCompleted",
  OnPlaybackSuspended = "OnPlaybackSuspended",
  OnPlaybackResumed = "OnPlaybackResumed"
}

local function GetSecondFromSrtTime(srtTime)
  local hours, minutes, seconds, milliseconds = srtTime:match("(%d+):(%d+):(%d+),(%d+)")
  local h = tonumber(hours) or 0
  local m = tonumber(minutes) or 0
  local s = tonumber(seconds) or 0
  return h * 3600 + m * 60 + s
end

local function GetMilliSecondFromSrtTime(srtTime)
  local hours, minutes, seconds, milliseconds = srtTime:match("(%d+):(%d+):(%d+),(%d+)")
  local h = tonumber(hours) or 0
  local m = tonumber(minutes) or 0
  local s = tonumber(seconds) or 0
  local ms = tonumber(milliseconds) or 0
  return h * 3600000 + m * 60000 + s * 1000 + ms
end

function UMG_NRCMedia_C:AddOnEndReached(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnEndReached, handler)
end

function UMG_NRCMedia_C:RemoveOnEndReached(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnEndReached, handler)
  end
end

function UMG_NRCMedia_C:AddOnMediaOpened(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnMediaOpened, handler)
end

function UMG_NRCMedia_C:RemoveOnMediaOpened(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnMediaOpened, handler)
  end
end

function UMG_NRCMedia_C:AddOnMediaClosed(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnMediaClosed, handler)
end

function UMG_NRCMedia_C:RemoveOnMediaClosed(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnMediaClosed, handler)
  end
end

function UMG_NRCMedia_C:AddOnMediaOpenFailed(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnMediaOpenFailed, handler)
end

function UMG_NRCMedia_C:RemoveOnMediaOpenFailed(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnMediaOpenFailed, handler)
  end
end

function UMG_NRCMedia_C:AddOnPlaybackSuspended(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnPlaybackSuspended, handler)
end

function UMG_NRCMedia_C:RemoveOnPlaybackSuspended(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnPlaybackSuspended, handler)
  end
end

function UMG_NRCMedia_C:AddOnPlaybackResumed(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnPlaybackResumed, handler)
end

function UMG_NRCMedia_C:RemoveOnPlaybackResumed(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnPlaybackResumed, handler)
  end
end

function UMG_NRCMedia_C:AddOnSeekCompleted(listener, handler)
  self._eventDispatcher:AddEventListener(listener, MediaPlayer_Event.OnSeekCompleted, handler)
end

function UMG_NRCMedia_C:RemoveOnSeekCompleted(listener, handler)
  if self._eventDispatcher then
    self._eventDispatcher:RemoveEventListener(listener, MediaPlayer_Event.OnSeekCompleted, handler)
  end
end

local function CloseAudio(self, audioSessionID)
  Log.Info("UMG_NRCMedia_C:CloseAudio ", audioSessionID)
  if audioSessionID and audioSessionID > 0 then
    _G.NRCAudioManager:ReleaseSession(audioSessionID, true, self._audioSource)
  end
end

local function UnregisterMediaPlayerEvents(self)
  if self.MediaPlayer.RemoveOnMediaOpened then
    self.MediaPlayer:RemoveOnMediaOpened(self, self.OnMediaOpened)
  end
  if self.MediaPlayer.RemoveOnMediaClosed then
    self.MediaPlayer:RemoveOnMediaClosed(self, self.OnMediaClosed)
  end
  if self.MediaPlayer.RemoveOnMediaOpenFailed then
    self.MediaPlayer:RemoveOnMediaOpenFailed(self, self.OnMediaOpenFailed)
  end
  if self.MediaPlayer.RemoveOnEndReached then
    self.MediaPlayer:RemoveOnEndReached(self, self.OnEndReached)
  end
  if self.MediaPlayer.RemoveOnPlaybackSuspended then
    self.MediaPlayer:RemoveOnPlaybackSuspended(self, self.OnPlaybackSuspended)
  end
  if self.MediaPlayer.RemoveOnPlaybackResumed then
    self.MediaPlayer:RemoveOnPlaybackResumed(self, self.OnPlaybackResumed)
  end
  if self.MediaPlayer.RemoveOnSeekCompleted then
    self.MediaPlayer:RemoveOnSeekCompleted(self, self.OnSeekCompleted)
  end
  if self.MediaPlayer.RemoveOnVideoRenderingStart then
    self.MediaPlayer:RemoveOnVideoRenderingStart(self, self.OnVideoRenderingStart)
  end
  if self.MediaPlayer.RemoveOnSetNextVideoFail then
    self.MediaPlayer:RemoveOnSetNextVideoFail(self, self.OnSetNextVideoFail)
  end
  if self.MediaPlayer.RemoveOnSetNextVideoSucc then
    self.MediaPlayer:RemoveOnSetNextVideoSucc(self, self.OnSetNextVideoSucc)
  end
end

local function RegisterMediaPlayerEvents(self)
  if self.MediaPlayer.AddOnMediaOpened then
    self.MediaPlayer:AddOnMediaOpened(self, self.OnMediaOpened)
  end
  if self.MediaPlayer.AddOnMediaClosed then
    self.MediaPlayer:AddOnMediaClosed(self, self.OnMediaClosed)
  end
  if self.MediaPlayer.AddOnMediaOpenFailed then
    self.MediaPlayer:AddOnMediaOpenFailed(self, self.OnMediaOpenFailed)
  end
  if self.MediaPlayer.AddOnEndReached then
    self.MediaPlayer:AddOnEndReached(self, self.OnEndReached)
  end
  if self.MediaPlayer.AddOnPlaybackSuspended then
    self.MediaPlayer:AddOnPlaybackSuspended(self, self.OnPlaybackSuspended)
  end
  if self.MediaPlayer.AddOnPlaybackResumed then
    self.MediaPlayer:AddOnPlaybackResumed(self, self.OnPlaybackResumed)
  end
  if self.MediaPlayer.AddOnSeekCompleted then
    self.MediaPlayer:AddOnSeekCompleted(self, self.OnSeekCompleted)
  end
  if self.MediaPlayer.AddOnVideoRenderingStart then
    self.MediaPlayer:AddOnVideoRenderingStart(self, self.OnVideoRenderingStart)
  end
  if self.MediaPlayer.AddOnSetNextVideoFail then
    self.MediaPlayer:AddOnSetNextVideoFail(self, self.OnSetNextVideoFail)
  end
  if self.MediaPlayer.AddOnSetNextVideoSucc then
    self.MediaPlayer:AddOnSetNextVideoSucc(self, self.OnSetNextVideoSucc)
  end
end

local function OnCloseFunc(self, bForceStopAudio)
  Log.Debug("UMG_NRC_Media_C:OnClose")
  self:CancelDelayByFunc(self.OnOpenMediaTimeout)
  if self.MediaPlayer then
    UnregisterMediaPlayerEvents(self)
    self.MediaPlayer:Close()
  end
  Log.Debug("UMG_NRCMedia_C: Remove All Event Successfully")
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.bResourceClear = true
  if self.ForceStopAudioWhenClose or bForceStopAudio then
    CloseAudio(self, self._audioSessionID)
    self._audioSessionID = 0
    if self._nextVideoDataList then
      for i, v in ipairs(self._nextVideoDataList) do
        if v and v.audioSessionID then
          CloseAudio(self, v.audioSessionID)
        end
      end
    end
  end
  self._audioSessionID = 0
  self._srtDict = {}
  self._srtTrackID = 0
  self.SubtitleText:SetText("")
  if self.LockeWordText then
    self.LockeWordText:SetText("")
  end
  self._curShowSrt = nil
  self._lastSyncAudioTimestamp = nil
  self._nextVideoDataList = {}
  self._curPlayingNextVideoIndex = nil
  self._nextVideoIndexTriggeredPlayNextVideoSuccess = nil
  self._videoHasTriggerPlayNextVideoSuccess = nil
  if self._checkOpenMediaPanelValidAsyncContext then
    a.kill(self._checkOpenMediaPanelValidAsyncContext)
    self._checkOpenMediaPanelValidAsyncContext = nil
  end
  if self._checkNextVideoAsyncContextDict then
    for k, v in pairs(self._checkNextVideoAsyncContextDict) do
      if v then
        a.kill(v)
      end
    end
  end
  self._checkNextVideoAsyncContextDict = nil
  self._nextMediaSetSource = nil
  self._openMediaPanelSource = nil
  self._isInMediaOpenFailedProcess = nil
end

local function OpenAudio(self, soundID)
  Log.DebugFormat("UMG_NRCMedia_C:OpenAudio SoundID %s", tostring(soundID or "nil"))
  if not soundID then
    return
  end
  local audioSessionID = _G.NRCAudioManager:PlaySound2DAuto(soundID, self._audioSource)
  if audioSessionID <= 0 then
    Log.ErrorFormat("UMG_NRCMedia_C:OpenAudio SoundID %d Sournce %s Failed", soundID, self._audioSource)
    return false
  end
  _G.NRCAudioManager:SeekOnEventBySession(audioSessionID, 0.0, soundID)
  local audioMaxTimeInMS = _G.NRCAudioManager:GetMaxTimeFromID(soundID) * 1000.0
  return audioSessionID, audioMaxTimeInMS
end

local function FillSrtDict(self, srtTrackID)
  self._curShowSrt = nil
  self._srtDict = {}
  if srtTrackID then
    local RowConfs = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.VIDEO_SUBTITLES_CONF)
    local SrtList = {}
    if RowConfs then
      for _, v in pairs(RowConfs) do
        if tonumber(v.track_id) == srtTrackID then
          table.insert(SrtList, v)
        end
      end
    end
    table.sort(SrtList, function(a, b)
      return a.id < b.id
    end)
    self._srtDict = {}
    for _, srt in pairs(SrtList) do
      local beginTimeSec = GetSecondFromSrtTime(srt.begin_time)
      if not table.containsKey(self._srtDict, beginTimeSec) then
        self._srtDict[beginTimeSec] = {}
      end
      table.insert(self._srtDict[beginTimeSec], srt)
    end
    for sec, srtList in pairs(self._srtDict) do
      Log.DebugFormat("FillSrtDict: Sec %d has List %d", sec, table.len(srtList))
    end
  end
end

local function FindSetNotPlayedNextVideoData(self)
  if self._nextVideoDataList then
    for i, v in ipairs(self._nextVideoDataList) do
      if v.videoState == VIDEO_STATE.SET_NOT_PLAYED and v.source then
        return i
      end
    end
  end
  return nil
end

local function FindNotSetOrSetNotPlayedNextVideoToHandle(self)
  if self._nextVideoDataList then
    for i, v in ipairs(self._nextVideoDataList) do
      if v.videoState == VIDEO_STATE.NOT_SET then
        if v.source then
          return i, v
        end
      elseif v.videoState == VIDEO_STATE.SET_NOT_PLAYED and v.source then
        return i, v
      end
    end
  end
  return nil
end

local function SyncAudioAndVideo(self, audioSessionID, audioMaxTimeInMS, soundID, fVideoTimeInMS)
  if audioSessionID and _G.NRCAudioManager:CheckSessionValidAndNotFinished(audioSessionID) then
    local nAudioTimeInMS = _G.NRCAudioManager:GetPlayPositionInMs(audioSessionID)
    local diff = nAudioTimeInMS - fVideoTimeInMS
    if audioMaxTimeInMS and audioMaxTimeInMS > 0.0 and nAudioTimeInMS > 0.0 and (not self._lastSyncAudioTimestamp or fVideoTimeInMS - self._lastSyncAudioTimestamp > 10.0) then
      if math.abs(diff) > 100.0 then
        local sign = (diff > 0.0 and 1.0 or 0.0 == diff and 0.0 or -1.0) * -1.0
        local fTargetAudioProgressMS = fVideoTimeInMS + 20.0 * sign
        _G.NRCAudioManager:SeekOnEventBySession(audioSessionID, fTargetAudioProgressMS / audioMaxTimeInMS, soundID)
        self._lastSyncAudioTimestamp = 10000000
        Log.DebugFormat("seek to %f percent %f audioMaxTimeInMS %f", fTargetAudioProgressMS, fTargetAudioProgressMS / audioMaxTimeInMS, audioMaxTimeInMS)
      else
        self._lastSyncAudioTimestamp = 10000000
        Log.InfoFormat("ignore sync by setting lastSyncAudioTimestamp %f", self._lastSyncAudioTimestamp)
      end
    end
  end
end

local function SetNextVideo(self, isFile, strNextVideoUrl, bLoop)
  Log.Info("UMG_NRCMedia_C:SetNextVideo ", strNextVideoUrl)
  if isFile then
    strNextVideoUrl = _G.MediaUtils.ComputeFilePathByDeviceLevelAndPlatform(strNextVideoUrl)
    strNextVideoUrl = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(strNextVideoUrl)
  end
  if self.MediaPlayer then
    self.MediaPlayer:SetNextVideo(isFile, strNextVideoUrl, bLoop)
  end
end

local function GetPandoraVideoCacheRootPath()
  local PandoraVideoCacheRootDir = UE.UBlueprintPathsLibrary.Combine({
    UE4.UBlueprintPathsLibrary.ProjectPersistentDownloadDir(),
    "PandoraVideoCache"
  })
  return PandoraVideoCacheRootDir
end

function UMG_NRCMedia_C:OnConstruct(ParentWidget)
  Log.Debug("UMG_NRCMedia_C:OnConstruct")
  self.Overridden.Construct(self)
  self.SubtitleText:SetText("")
  if self.LockeWordText then
    self.LockeWordText:SetText("")
  end
  self.ParentWidget = ParentWidget
  self._audioSource = "UMG_NRCMedia"
  self._videoProgressInMS = 0.0
  self._eventDispatcher = {}
  self._enableOpenFailedDialogue = true
  self._isInMediaOpenFailedProcess = false
  self._hasWarnedGPUDriverVersionLimited = false
  if UE.UNRCStatics.CheckEnableUEVideoPlayer() then
    Log.Info("Use UE VideoPlayer")
    self.NRCVideoPlayerWidget:OnConstruct()
    self.MediaPlayer = self.NRCVideoPlayerWidget
    self.MediaSwitcher:SetActiveWidgetIndex(0)
  else
    Log.Info("Use Pandora VideoPlayer")
    self.PVideoPlayerWidget:OnConstruct()
    local PandoraVideoCacheRootDir = GetPandoraVideoCacheRootPath()
    self.PVideoPlayerWidget:EnableCacheResource(true, PandoraVideoCacheRootDir)
    self.MediaPlayer = self.PVideoPlayerWidget
    self.MediaSwitcher:SetActiveWidgetIndex(1)
  end
  EventDispatcher():Attach(self._eventDispatcher)
  self:SetNRCMediaImageSize(MediaUtils.DIALOGUE_VIDEO_RESOLUTION.X, MediaUtils.DIALOGUE_VIDEO_RESOLUTION.Y)
end

function UMG_NRCMedia_C:OnDestruct()
  Log.Debug("UMG_NRCMedia_C:OnDestruct")
  OnCloseFunc(self)
  if self.MediaPlayer then
    self.MediaPlayer:OnDestruct()
  end
  self._eventDispatcher:RemoveAllListeners()
  self.ParentWidget = nil
  self._isInMediaOpenFailedProcess = false
  self._hasWarnedGPUDriverVersionLimited = false
end

function UMG_NRCMedia_C:OnActive()
  Log.Debug("UMG_NRC_Media_C:OnActive")
  if self.MediaPlayer then
    self.MediaPlayer:OnActive()
  end
end

function UMG_NRCMedia_C:OnDeactive()
  Log.Debug("UMG_NRC_Media_C:OnDeactive")
  OnCloseFunc(self)
  if self.MediaPlayer then
    self.MediaPlayer:OnDeactive()
  end
end

local ParentScreenSizeCache = UE4.FVector2D()
local ScreenSizeCache = UE4.FVector2D()

local function OnTickSubtitlePos(self)
  if not self then
    return
  end
  if not self.ParentWidget then
    return
  end
  local ParentScreenSize = ParentScreenSizeCache
  local InScreenSize = ScreenSizeCache
  UE4.UNRCStatics.GetLocalSizeFromWidgetCachedGeometry(self.ParentWidget, ParentScreenSize)
  UE4.UNRCStatics.GetLocalSizeFromWidgetCachedGeometry(self, InScreenSize)
  if 0.0 == InScreenSize.X or 0.0 == InScreenSize.Y then
    return
  end
  if not (self._screenSizeCache and self._screenSizeCache.X == InScreenSize.X and self._screenSizeCache.Y == InScreenSize.Y and self._parentScreenSize) or self._parentScreenSize.X ~= ParentScreenSize.X or self._parentScreenSize.Y ~= ParentScreenSize.Y then
    self._screenSizeCache = UE4.FVector2D(InScreenSize.X, InScreenSize.Y)
    self._parentScreenSize = UE4.FVector2D(ParentScreenSize.X, ParentScreenSize.Y)
    Log.Info("ScreenSizeCache ", InScreenSize.X, InScreenSize.Y, " ParentScreenSIze: ", ParentScreenSize.X, ParentScreenSize.Y)
    local scaleX = ParentScreenSize.X / InScreenSize.X
    local targetScreenY = scaleX * InScreenSize.Y
    local offsetY = (self._parentScreenSize.Y - targetScreenY) / (2.0 * scaleX)
    if self.SubtitleText and self.LockeWordText then
      local subtitleSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SubtitleText)
      local lockeWordTextSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.LockeWordText)
      if not self._subtitleSlotY then
        self._subtitleSlotY = subtitleSlot:GetPosition().Y
      end
      if not self._lockeWordTextY then
        self._lockeWordTextY = lockeWordTextSlot:GetPosition().Y
      end
      if offsetY < 0 then
        subtitleSlot:SetPosition(UE4.FVector2D(subtitleSlot:GetPosition().X, self._subtitleSlotY + offsetY))
        lockeWordTextSlot:SetPosition(UE4.FVector2D(lockeWordTextSlot:GetPosition().X, self._lockeWordTextY + offsetY))
      else
        subtitleSlot:SetPosition(UE4.FVector2D(subtitleSlot:GetPosition().X, self._subtitleSlotY))
        lockeWordTextSlot:SetPosition(UE4.FVector2D(lockeWordTextSlot:GetPosition().X, self._lockeWordTextY))
      end
    end
  end
end

function UMG_NRCMedia_C:OnTick(deltaTime)
  if not self.MediaPlayer or not self.MediaPlayer:IsPlaying() then
    return
  end
  OnTickSubtitlePos(self)
  local fVideoTimeInMS = self.MediaPlayer:GetTimeMilliseconds()
  local fVideoDurationInMS = self.MediaPlayer:GetDurationMilliseconds()
  self._videoProgressInMS = fVideoTimeInMS
  if fVideoDurationInMS <= 0.0 then
    return
  end
  if not self._curPlayingNextVideoIndex then
    SyncAudioAndVideo(self, self._audioSessionID, self._audioMaxTimeInMS, self._soundID, fVideoTimeInMS)
  else
    local nextVideoData = self._nextVideoDataList and self._nextVideoDataList[self._curPlayingNextVideoIndex] or nil
    if nextVideoData and nextVideoData.videoState == VIDEO_STATE.PLAYED then
      SyncAudioAndVideo(self, nextVideoData.audioSessionID, nextVideoData.audioMaxTimeInMS, nextVideoData.soundID, fVideoTimeInMS)
    end
  end
  local nVideoTimeInSec = math.floor(fVideoTimeInMS / 1000.0)
  if self._curShowSrt then
    local endTimeInMS = GetMilliSecondFromSrtTime(self._curShowSrt.end_time)
    if fVideoTimeInMS > endTimeInMS then
      self._curShowSrt = nil
    end
  end
  if not self._curShowSrt then
    local firstValidSrt
    if self._srtDict and table.containsKey(self._srtDict, nVideoTimeInSec) then
      for _, srt in pairs(self._srtDict[nVideoTimeInSec]) do
        local begTimeInMS = GetMilliSecondFromSrtTime(srt.begin_time)
        local endTimeInMS = GetMilliSecondFromSrtTime(srt.end_time)
        if fVideoTimeInMS >= begTimeInMS and fVideoTimeInMS <= endTimeInMS then
          firstValidSrt = srt
          break
        end
      end
    end
    self._curShowSrt = firstValidSrt
  end
  if not self._curShowSrt then
    self.SubtitleText:SetText("")
    if self.LockeWordText then
      self.LockeWordText:SetText("")
    end
  else
    self.SubtitleText:SetText(self._curShowSrt.content)
    if self.LockeWordText then
      self.LockeWordText:SetText(self._curShowSrt.roco_content)
    end
  end
end

function UMG_NRCMedia_C:SetLoop(isLoop)
  if self.MediaPlayer then
    self.MediaPlayer:SetLooping(isLoop)
  end
end

local function OpenUrl(self, url)
  if self.MediaPlayer then
    return self.MediaPlayer:OpenUrl(url)
  end
  return false
end

function UMG_NRCMedia_C:GetExternalDirRoot()
  return UE4.UBlueprintPathsLibrary.ProjectSavedDir()
end

function UMG_NRCMedia_C:GetInternalDirRoot()
  return UE4.UBlueprintPathsLibrary.ProjectContentDir()
end

local function OpenFile(self, filePath)
  Log.DebugFormat("UMG_NRCMedia_C:OpenFile filePath %s", filePath)
  if not filePath then
    return false
  end
  filePath = _G.MediaUtils.ComputeFilePathByDeviceLevelAndPlatform(filePath)
  filePath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(filePath)
  if self.MediaPlayer then
    Log.Info("UMG_NRCMedia_C:OpenFile filePath", filePath)
    return self.MediaPlayer:OpenFile(filePath)
  end
  return false
end

function UMG_NRCMedia_C:SetAutoPlay(bAutoPlay)
  self.bAutoPlay = bAutoPlay
  if self.MediaPlayer then
    self.MediaPlayer:SetAutoPlay(bAutoPlay)
  end
end

function UMG_NRCMedia_C:SetNRCMediaImageSize(imageSizeX, imageSizeY)
  if self.MediaPlayer then
    self.MediaPlayer:SetMediaTextureSize(imageSizeX, imageSizeY)
  end
end

local function OpenMediaPanel_Internal(self, internalParam)
  local source = internalParam.source
  local isFile = internalParam.isFile
  local needAutoPlay = internalParam.needAutoPlay
  local isLoop = internalParam.isLoop
  local OpenResultCaller = internalParam.OpenResultCaller
  local OpenResultCallback = internalParam.OpenResultCallback
  local soundID = internalParam.soundID
  local videoSubtitleTrackID = internalParam.videoSubtitleTrackID
  local forceStopAudioWhenClose = internalParam.forceStopAudioWhenClose
  if not source or "" == source then
    Log.ErrorFormat("UMG_NRCMedia_C:OpenMediaPanel invalid source: %s", tostring(source))
    return false
  end
  Log.DebugFormat("UMG_NRCMedia_C:OpenMediaPanel source %s isFile %s needAutoPlay %s isLoop %s soundID %s videoSubtitleTrackID %s forceStopAudioWhenClose %s", source, tostring(isFile or "false"), tostring(needAutoPlay or "false"), tostring(isLoop or "false"), tostring(soundID or "nil"), tostring(videoSubtitleTrackID or "nil"), tostring(forceStopAudioWhenClose or "false"))
  self._curPlayingNextVideoIndex = nil
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ForceStopAudioWhenClose = forceStopAudioWhenClose
  self.SubtitleText:SetText("")
  if self.LockeWordText then
    self.LockeWordText:SetText("")
  end
  if videoSubtitleTrackID then
    self._srtTrackID = tonumber(videoSubtitleTrackID)
  end
  if soundID then
    self._soundID = tonumber(soundID)
  end
  FillSrtDict(self, self._srtTrackID)
  self:SetAutoPlay(needAutoPlay)
  if self.MediaPlayer then
    self.MediaPlayer:SetLooping(isLoop)
    UnregisterMediaPlayerEvents(self)
    RegisterMediaPlayerEvents(self)
  end
  self._lastSyncAudioTimestamp = nil
  self._videoProgressInMS = 0.0
  local OpenSucceed = false
  if isFile then
    OpenSucceed = OpenFile(self, source)
  else
    OpenSucceed = OpenUrl(self, source)
  end
  if needAutoPlay then
    if not OpenSucceed then
      if OpenResultCallback then
        if OpenResultCaller then
          OpenResultCallback(OpenResultCaller)
        else
          OpenResultCallback()
        end
      end
    else
      self._audioSessionID, self._audioMaxTimeInMS = OpenAudio(self, self._soundID)
    end
  end
  self:DelaySeconds(3, self.OnOpenMediaTimeout, self)
end

function UMG_NRCMedia_C:OnGetRemoteFileSizeCallback(Url, bResult, nFileSize)
  Log.Info("UMG_NRCMedia_C:OnGetRemoteFileSizeCallback ", Url, bResult, nFileSize)
end

local aCheckOpenMediaPanelValid = a.sync(function(self, source, isFile)
  Log.Info("UMG_NRCMedia_C:OpenMediaPanel TaskBegin")
  if not isFile then
    local protocol, domain, path = string.match(source, "^(%w+)://([^:/]+)(.*)$")
    Log.Info("UMG_NRCMedia_C: protocol ", protocol, " domain ", domain, " path ", path)
    local ip_url = source
    Log.Info("UMG_NRCMedia_C: ip url ", ip_url)
    
    local function asyncGetUrlFileSizeThunk(URL, callback)
      local simpleDelegate = SimpleDelegateFactory:CreateCallback(self, function(_, pUrl, pResult, bFileSize)
        Log.Info("UMG_NRCMedia_C:OpenMediaPanel CreateCallback pUrl ", pUrl, " pResult ", pResult, " bFileSize ", bFileSize)
        if callback then
          callback(pUrl, pResult, bFileSize)
        end
      end)
      UE4.UNRCHTTPFileSizeHelper.GetRemoteFileSize(URL, {self, simpleDelegate})
    end
    
    local strReturnURL, bResult, nFileSize = a.wait(a.wrap(asyncGetUrlFileSizeThunk)(ip_url))
    Log.Info("UMG_NRCMedia_C:OpenMediaPanel file size status ", source, " result ", bResult, " nFileSize ", nFileSize)
    if not bResult then
      return false, "Get File Size Failed"
    end
    local FreeDiskSpace = UE.UNRCStatics.GetFreeDiskSpace() * 1024 * 1024
    Log.Info("UMG_NRCMedia_C:OpenMediaPanel Check FreeDiskSPace Video File Size", nFileSize, " FreeDiskSpace ", FreeDiskSpace)
    if FreeDiskSpace < nFileSize * 1.5 then
      local cacheRootPath = GetPandoraVideoCacheRootPath()
      self.PVideoPlayerWidget:ClearCacheResource(cacheRootPath)
      FreeDiskSpace = UE.UNRCStatics.GetFreeDiskSpace() * 1024 * 1024
      Log.Info("UMG_NRCMedia_C:OpenMediaPanel Check FreeDiskSPace Again Video File Size", nFileSize, " FreeDiskSpace ", FreeDiskSpace)
      if FreeDiskSpace < nFileSize * 1.5 then
        Log.Error("UMG_NRCMedia_C:OpenMediaPanel Failed, no enough disk space even after clean cache")
        return false, "Nout Enough Space"
      end
    end
  end
  Log.Info("UMG_NRCMedia_C:OpenMediaPanel TaskEnd")
  return true, "Success"
end)

function UMG_NRCMedia_C:SetDefaultCoverTexture()
  Log.Info("UMG_NRCMedia_C:SetDefaultCoverTexture")
  if self.MediaPlayer then
    self.MediaPlayer:SetCoverTexture(UEPath.DefaultMediaPlayerCoverTexture)
  end
end

function UMG_NRCMedia_C:SetEnableOpenFailedDialogue(bEnable)
  Log.Info("UMG_NRCMedia_C:SetEnableOpenFailedDialogue ", bEnable)
  self._enableOpenFailedDialogue = bEnable
end

local function GetDecryptKeysByMovieFileName(filePath)
  local movieSecretKey = UE4.UNRCStatics.GetStringFromGGameIni("/Script/NRC.MovieSettings", "MovieSecretKey")
  local fileNameWithoutExtension = UE4.UNRCStatics.GetBaseFilename(filePath, false)
  local fileRelativePathAfterMovies = fileNameWithoutExtension
  if string.find(fileNameWithoutExtension, "Movies/") then
    fileRelativePathAfterMovies = string.sub(fileNameWithoutExtension, string.find(fileNameWithoutExtension, "Movies/") + string.len("Movies/"))
    Log.Info("UMG_NRCMedia_C:GetDecryptKeysByMovieFileName ", filePath, fileRelativePathAfterMovies)
    local hmac_key = UE4.UNRCStatics.HMACSHA256(movieSecretKey, "KEY_" .. fileRelativePathAfterMovies)
    local hmac_kid = UE4.UNRCStatics.HMACSHA256(movieSecretKey, "KID_" .. fileRelativePathAfterMovies)
    return hmac_key, hmac_kid
  end
  return nil, nil
end

function UMG_NRCMedia_C:OpenMediaPanelByParamTable(paramTable)
  local source = paramTable.source
  local needAutoPlay = false
  if paramTable.needAutoPlay ~= nil then
    needAutoPlay = paramTable.needAutoPlay
  end
  local isLoop = false
  if nil ~= paramTable.isLoop then
    isLoop = paramTable.isLoop
  end
  local OpenResultCaller = paramTable.OpenResultCaller
  local OpenResultCallback = paramTable.OpenResultCallback
  local soundID = paramTable.soundID
  local videoSubtitleTrackID = paramTable.videoSubtitleTrackID
  local forceStopAudioWhenClose = false
  if nil ~= paramTable.forceStopAudioWhenClose then
    forceStopAudioWhenClose = paramTable.forceStopAudioWhenClose
  end
  local bEncryptVideo = true
  if nil ~= paramTable.bEncryptVideo then
    bEncryptVideo = paramTable.bEncryptVideo
  end
  local useDefaultCoverTexture = true
  if nil ~= paramTable.useDefaultCoverTexture then
    useDefaultCoverTexture = paramTable.useDefaultCoverTexture
  end
  local checkGPUDriverVersion = true
  if nil ~= paramTable.checkGPUDriverVersion then
    checkGPUDriverVersion = paramTable.checkGPUDriverVersion
  end
  self:OpenMediaPanel(source, needAutoPlay, isLoop, OpenResultCaller, OpenResultCallback, soundID, videoSubtitleTrackID, forceStopAudioWhenClose, bEncryptVideo, useDefaultCoverTexture, checkGPUDriverVersion)
end

function UMG_NRCMedia_C:OpenMediaPanel(source, needAutoPlay, isLoop, OpenResultCaller, OpenResultCallback, soundID, videoSubtitleTrackID, forceStopAudioWhenClose, bEncryptVideo, useDefaultCoverTexture, checkGPUDriverVersion)
  if self._isInMediaOpenFailedProcess then
    Log.Warning("UMG_NRCMedia_C:OpenMediaPanel is already in media open failed process")
    return
  end
  self._openMediaPanelSource = source
  self._isInMediaOpenFailedProcess = false
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self._curPlayingNextVideoIndex = nil
  local isFile = source and not string.StartsWith(source, "http")
  if useDefaultCoverTexture and not isFile then
    self:SetDefaultCoverTexture()
  end
  if nil == bEncryptVideo then
    self._encryptVideo = true
  else
    self._encryptVideo = bEncryptVideo
  end
  if not isFile then
    self._encryptVideo = false
  end
  if checkGPUDriverVersion and not UE4.UNRCPlatformStatics.IsMediaPlayerSupported() then
    Log.Error("UMG_NRCMedia_C:OpenMediaPanel GPU Driver Version Not Support Media Player")
    if OpenResultCallback then
      if OpenResultCaller then
        OpenResultCallback(OpenResultCaller)
      else
        OpenResultCallback()
      end
    end
    self:OnMediaOpenFailed()
    if not self._hasWarnedGPUDriverVersionLimited then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.driver_outdated, -1, nil, 5.0)
      self._hasWarnedGPUDriverVersionLimited = true
    end
    return
  end
  Log.Info("UMG_NRCMedia_C: OpenMediaPanel Called ", self._encryptVideo)
  if self._encryptVideo then
    local key, _ = GetDecryptKeysByMovieFileName(source)
    if not key or "" == key then
      Log.Error("UMG_NRCMedia_C:OpenMediaPanel Get Decrypt Key Failed")
    else
      local decryptionKey = string.sub(key, 1, 32)
      Log.Info("UMG_NRCMedia_C:OpenMediaPanel Get Decrypt  Key", key, source, decryptionKey)
      self.MediaPlayer:SetDecryptionKey(decryptionKey)
    end
  end
  if self._checkOpenMediaPanelValidAsyncContext then
    a.kill(self._checkOpenMediaPanelValidAsyncContext)
    self._checkOpenMediaPanelValidAsyncContext = nil
  end
  self._checkOpenMediaPanelValidAsyncContext = au.Launch(aCheckOpenMediaPanelValid(self, source, isFile), function(taskStatus, checkStatus, checkResult)
    Log.Info("UMG_NRCMedia_C:OpenMediaPanelTask Call callback", taskStatus, checkStatus, checkResult)
    if not taskStatus then
      return
    end
    self._checkOpenMediaPanelValidAsyncContext = nil
    if not checkStatus then
      Log.Error("UMG_NRCMedia_C:OpenMediaPanel failed: ", checkResult)
      if OpenResultCallback then
        if OpenResultCaller then
          OpenResultCallback(OpenResultCaller)
        else
          OpenResultCallback()
        end
      end
      self:OnMediaOpenFailed()
      return
    end
    local status, err = tcall(self, OpenMediaPanel_Internal, {
      source = source,
      isFile = isFile,
      needAutoPlay = needAutoPlay,
      isLoop = isLoop,
      OpenResultCaller = OpenResultCaller,
      OpenResultCallback = OpenResultCallback,
      soundID = soundID,
      videoSubtitleTrackID = videoSubtitleTrackID,
      forceStopAudioWhenClose = forceStopAudioWhenClose
    })
    if not status then
      Log.Error("UMG_NRCMedia_C:OpenMediaPanel failed: ", err)
      if OpenResultCallback then
        if OpenResultCaller then
          OpenResultCallback(OpenResultCaller)
        else
          OpenResultCallback()
        end
      end
      self:OnMediaOpenFailed()
    end
  end)
end

function UMG_NRCMedia_C:OnOpenMediaTimeout()
  Log.Error("\230\137\147\229\188\128\232\181\132\230\186\144\232\182\133\230\151\182\239\188\129\239\188\129\239\188\129")
  if self.MediaPlayer then
    Log.Error(self.MediaPlayer:GetMediaFileOrURL())
  end
  self:CancelDelayByFunc(self.OnOpenMediaTimeout)
  Log.Debug("UMG_NRCMedia_C:OnOpenMediaTimeout")
  self:OnMediaOpenFailed()
end

local function AddNextVideo_Internal(self, url, isFile, loop, soundID, subtitleTrackID)
  Log.Info("UMG_NRCMedia_C:AddNextVideo ", "isFile ", isFile, " url ", url, " soundID ", soundID, " loop ", loop, " subtitleTrackID ", subtitleTrackID, "curPlayingNextVideoIndex ", self._curPlayingNextVideoIndex, " _videoHasTriggerPlayNextVideoSuccess ", self._videoHasTriggerPlayNextVideoSuccess)
  if not self._nextVideoDataList then
    self._nextVideoDataList = {}
  end
  local nextVideoData = {}
  nextVideoData.isFile = isFile
  nextVideoData.source = url
  nextVideoData.soundID = soundID and tonumber(soundID) or nil
  nextVideoData.loop = loop
  nextVideoData.subtitleTrackID = subtitleTrackID and tonumber(subtitleTrackID) or nil
  nextVideoData.videoState = VIDEO_STATE.NOT_SET
  table.insert(self._nextVideoDataList, nextVideoData)
  if not self._curPlayingNextVideoIndex then
    if self._videoHasTriggerPlayNextVideoSuccess then
      local nextVideoDataToSet
      if #self._nextVideoDataList > 0 then
        nextVideoDataToSet = self._nextVideoDataList[1]
        if not nextVideoDataToSet then
          Log.Warning("UMG_NRCMedia_C: nextVideoDataToSet is nil, weird!!!")
          return
        end
        if nextVideoDataToSet.videoState == VIDEO_STATE.NOT_SET then
          SetNextVideo(self, nextVideoDataToSet.isFile, nextVideoDataToSet.source, nextVideoDataToSet.loop)
          nextVideoDataToSet.videoState = VIDEO_STATE.SET_NOT_PLAYED
        end
      end
    end
  elseif self._nextVideoIndexTriggeredPlayNextVideoSuccess then
    local nextVideoDataToSet
    if #self._nextVideoDataList >= self._nextVideoIndexTriggeredPlayNextVideoSuccess then
      nextVideoDataToSet = self._nextVideoDataList[self._nextVideoIndexTriggeredPlayNextVideoSuccess + 1]
    end
    if not nextVideoDataToSet then
      Log.Warning("UMG_NRCMedia_C: nextVideoDataToSet is nil, weird!!!")
      return
    end
    if nextVideoDataToSet.videoState == VIDEO_STATE.NOT_SET then
      SetNextVideo(self, nextVideoDataToSet.isFile, nextVideoDataToSet.source, nextVideoDataToSet.loop)
      nextVideoDataToSet.videoState = VIDEO_STATE.SET_NOT_PLAYED
    end
  end
end

function UMG_NRCMedia_C:AddNextVideo(url, loop, soundID, subtitleTrackID)
  local isFile = url and not string.StartsWith(url, "http")
  Log.Info("UMG_NRCMedia_C:AddNextVideo", url, isFile, loop, soundID, subtitleTrackID)
  if self._checkNextVideoAsyncContextDict == nil then
    self._checkNextVideoAsyncContextDict = {}
  end
  if self._checkNextVideoAsyncContextDict[url] then
    a.kill(self._checkNextVideoAsyncContextDict[url])
    self._checkNextVideoAsyncContextDict[url] = nil
  end
  self._checkNextVideoAsyncContextDict[url] = au.Launch(aCheckOpenMediaPanelValid(self, url, isFile), function(taskStatus, checkStatus, checkResult)
    Log.Info("UMG_NRCMedia_C:AddNextVideo CheckOpenMediaPanelValid callback", taskStatus, checkStatus, checkResult)
    if not checkStatus then
      Log.Error("UMG_NRCMedia_C:OpenMediaPanel failed: ", checkResult)
      self._nextMediaSetSource = url
      self:OnMediaOpenFailed()
      return
    end
    local status, err = tcall(self, AddNextVideo_Internal, url, isFile, loop, soundID, subtitleTrackID)
    if not status then
      Log.Error("UMG_NRCMedia_C:AddNextVideo failed: ", err)
      self:OnMediaOpenFailed()
    end
  end)
end

function UMG_NRCMedia_C:Pause()
  Log.Debug("UMG_NRCMedia_C:Pause")
  if self.MediaPlayer then
    self.MediaPlayer:Pause()
  end
  if not self._curPlayingNextVideoIndex then
    CloseAudio(self, self._audioSessionID)
    self._audioSessionID = 0
  elseif self._nextVideoDataList and #self._nextVideoDataList >= self._curPlayingNextVideoIndex and self._nextVideoDataList[self._curPlayingNextVideoIndex] and self._nextVideoDataList[self._curPlayingNextVideoIndex].audioSessionID then
    CloseAudio(self, self._nextVideoDataList[self._curPlayingNextVideoIndex].audioSessionID)
    self._nextVideoDataList[self._curPlayingNextVideoIndex].audioSessionID = 0
  end
end

function UMG_NRCMedia_C:Play()
  Log.Debug("UMG_NRCMedia_C:Play")
  if self.MediaPlayer then
    self.MediaPlayer:Play()
  end
  if not self._curPlayingNextVideoIndex then
    CloseAudio(self, self._audioSessionID)
    self._audioSessionID, self._audioMaxTimeInMS = OpenAudio(self, self._soundID)
    if self._videoProgressInMS and self._videoProgressInMS > 0.0 and self._audioSessionID and self._audioSessionID > 0 and self._audioMaxTimeInMS > 0 then
      _G.NRCAudioManager:SeekOnEventBySession(self._audioSessionID, self._videoProgressInMS / self._audioMaxTimeInMS, self._soundID)
    end
  elseif self._nextVideoDataList and #self._nextVideoDataList >= self._curPlayingNextVideoIndex and self._nextVideoDataList[self._curPlayingNextVideoIndex] then
    local nextVideoData = self._nextVideoDataList[self._curPlayingNextVideoIndex]
    CloseAudio(self, nextVideoData.audioSessionID)
    nextVideoData.audioSessionID, nextVideoData.audioMaxTimeInMS = OpenAudio(self, nextVideoData.soundID)
    if self._videoProgressInMS and self._videoProgressInMS > 0.0 and nextVideoData.audioSessionID and nextVideoData.audioSessionID > 0 and nextVideoData.audioMaxTimeInMS > 0 then
      _G.NRCAudioManager:SeekOnEventBySession(nextVideoData.audioSessionID, self._videoProgressInMS / nextVideoData.audioMaxTimeInMS, nextVideoData.soundID)
    end
  end
  self._lastSyncAudioTimestamp = nil
end

function UMG_NRCMedia_C:Seek(timeSpan)
  Log.Info("UMG_NRCMedia_C:Seek ======")
  if nil == timeSpan then
    Log.Error("UMG_NRCMedia_C:Seek timeSpan is nil")
    return
  end
  if self._isInMediaOpenFailedProcess then
    Log.Error("UMG_NRCMedia_C:Seek return is in MediaOpenFailedProcess ")
    return
  end
  if self.MediaPlayer then
    self.MediaPlayer:Seek(timeSpan)
  end
  Log.Info("UMG_NRCMedia_C:Seek _curPlayingNextVideoIndex", self._curPlayingNextVideoIndex)
  if not self._curPlayingNextVideoIndex then
    if self._audioSessionID and _G.NRCAudioManager:CheckSessionValidAndNotFinished(self._audioSessionID) then
      local fAudioTotalTimeInMS = _G.NRCAudioManager:GetMaxTimeFromID(self._soundID) * 1000.0
      if fAudioTotalTimeInMS <= 0.0 then
        Log.ErrorFormat("UMG_NRCMedia_C:Seek fAudioTotalTime %f Error Sound ID %s", fAudioTotalTimeInMS, tostring(self._soundID or "nil"))
        return
      end
      local fTimeSpanInMS = timeSpan:GetTotalMilliseconds()
      local fTimeSpanPercent = fTimeSpanInMS / fAudioTotalTimeInMS
      _G.NRCAudioManager:SeekOnEventBySession(self._audioSessionID, fTimeSpanPercent, self._soundID)
    end
  elseif self._nextVideoDataList and #self._nextVideoDataList >= self._curPlayingNextVideoIndex and self._nextVideoDataList[self._curPlayingNextVideoIndex] then
    local nextVideoData = self._nextVideoDataList[self._curPlayingNextVideoIndex]
    if nextVideoData.audioSessionID and _G.NRCAudioManager:CheckSessionValidAndNotFinished(nextVideoData.audioSessionID) then
      local fAudioTotalTimeInMS = _G.NRCAudioManager:GetMaxTimeFromID(nextVideoData.soundID) * 1000.0
      if fAudioTotalTimeInMS <= 0.0 then
        Log.ErrorFormat("UMG_NRCMedia_C:Seek fAudioTotalTime %f Error Sound ID %s", fAudioTotalTimeInMS, tostring(nextVideoData.soundID or "nil"))
        return
      end
      local fTimeSpanInMS = timeSpan:GetTotalMilliseconds()
      local fTimeSpanPercent = fTimeSpanInMS / fAudioTotalTimeInMS
      _G.NRCAudioManager:SeekOnEventBySession(nextVideoData.audioSessionID, fTimeSpanPercent, nextVideoData.soundID)
    end
  end
  self._lastSyncAudioTimestamp = nil
end

function UMG_NRCMedia_C:GetTime()
  if self.MediaPlayer then
    return self.MediaPlayer:GetTime()
  end
  return nil
end

function UMG_NRCMedia_C:CloseMedia(bForceStopAudio)
  Log.Debug("UMG_NRCMedia_C:CloseMedia")
  OnCloseFunc(self, bForceStopAudio)
end

function UMG_NRCMedia_C:OnPlaybackSuspended()
  Log.Debug("UMG_NRCMedia_C:OnPlaybackSuspended")
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnPlaybackSuspended)
end

function UMG_NRCMedia_C:OnPlaybackResumed()
  Log.Debug("UMG_NRCMedia_C:OnPlaybackResumed")
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnPlaybackResumed)
end

function UMG_NRCMedia_C:OnSeekCompleted()
  Log.Debug("UMG_NRCMedia_C:OnSeekCompleted")
  if self._videoProgressInMS and self._videoProgressInMS > 0.0 and self._audioSessionID and self._audioSessionID > 0 and self._audioMaxTimeInMS > 0 then
    _G.NRCAudioManager:SeekOnEventBySession(self._audioSessionID, self._videoProgressInMS / self._audioMaxTimeInMS, self._soundID)
  end
  self._lastSyncAudioTimestamp = nil
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnSeekCompleted)
end

function UMG_NRCMedia_C:OnEndReached()
  Log.Debug("UMG_NRCMedia_C:OnEndReached")
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnEndReached)
end

function UMG_NRCMedia_C:OnMediaOpened()
  Log.Debug("UMG_NRCMedia_C:OnMediaOpened")
  self._isInMediaOpenFailedProcess = nil
  self:CancelDelayByFunc(self.OnOpenMediaTimeout)
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnMediaOpened)
end

function UMG_NRCMedia_C:OnMediaClosed()
  Log.Debug("UMG_NRCMedia_C:OnMediaClosed")
  self._eventDispatcher:SendEvent(MediaPlayer_Event.OnMediaClosed)
end

function UMG_NRCMedia_C:OnMediaOpenFailed()
  if self._isInMediaOpenFailedProcess then
    return
  end
  self._isInMediaOpenFailedProcess = true
  local failSource = ""
  if self._nextMediaSetSource then
    failSource = self._nextMediaSetSource
  elseif self._openMediaPanelSource then
    failSource = self._openMediaPanelSource
  elseif self.MediaPlayer then
    failSource = self.MediaPlayer:GetMediaFileOrURL()
  end
  local bShouldPlayHDVideo = _G.MediaUtils.CheckCurrentDeviceShouldPlayHDVideo()
  Log.Debug("UMG_NRCMedia_C:OnMediaOpenFailed IsInMediaOpenFailedProcess : ", self._isInMediaOpenFailedProcess, " enableOpenFailedDialogue ", self._enableOpenFailedDialogue, " shouldPlayHDVideo : ", bShouldPlayHDVideo, " failSource: ", failSource)
  if failSource and not string.StartsWith(failSource, "http") and bShouldPlayHDVideo then
    _G.GEMPostManager:SendHDVideoPlayFaildataLog()
  end
  self:CancelDelayByFunc(self.OnOpenMediaTimeout)
  CloseAudio(self, self._audioSessionID)
  if self._nextVideoDataList then
    for i, v in ipairs(self._nextVideoDataList) do
      if v and v.audioSessionID then
        CloseAudio(self, v.audioSessionID)
      end
    end
  end
  self._audioSessionID = 0
  self._srtDict = {}
  self._curShowSrt = nil
  if failSource and string.StartsWith(failSource, "http") then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.weak_network_video_fail)
  end
  if not RocoEnv.IS_SHIPPING and self._enableOpenFailedDialogue then
    Log.Info("UMG_NRCMedia_C: Open Failure Dialogue")
    local Ctx = DialogContext()
    Ctx:SetTitle("\230\137\147\229\188\128\232\167\134\233\162\145\229\164\177\232\180\165")
    Ctx:SetContent("\230\137\147\229\188\128\232\167\134\233\162\145\229\164\177\232\180\165\239\188\140\231\155\174\229\137\141\228\188\154\231\187\147\230\157\159\232\167\134\233\162\145\230\146\173\230\148\190\229\185\182\231\187\167\231\187\173\230\184\184\230\136\143\239\188\140\232\175\183\230\163\128\230\159\165\232\167\134\233\162\145\232\181\132\230\186\144: " .. failSource)
    Ctx:SetDialogType(DialogContext.DialogType.GeneralTip)
    Ctx:SetMode(DialogContext.Mode.OK)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
  end
  if self and self._eventDispatcher then
    self._eventDispatcher:SendEvent(MediaPlayer_Event.OnMediaOpenFailed)
  end
  if self and self._eventDispatcher then
    self._eventDispatcher:SendEvent(MediaPlayer_Event.OnEndReached)
  end
  if self and self._eventDispatcher then
    self._eventDispatcher:SendEvent(MediaPlayer_Event.OnMediaClosed)
  end
end

function UMG_NRCMedia_C:OnSetNextVideoFail()
  local setNotPlayedNextVideoIndex = FindSetNotPlayedNextVideoData(self)
  if not setNotPlayedNextVideoIndex then
    Log.Warning("UMG_NRCMedia_C: Cannot find any set not played next video!!!")
    return
  end
  if not self._nextVideoDataList then
    Log.Warning("UMG_NRCMedia_C: _nextVideoDataList is nil")
    return
  end
  if not self._nextVideoDataList[setNotPlayedNextVideoIndex] then
    return
  end
  local setNotPlayedNextVideoData = self._nextVideoDataList[setNotPlayedNextVideoIndex]
  self._nextMediaSetSource = setNotPlayedNextVideoData.source
  Log.Info("UMG_NRCMedia_C:OnSetNextVideoFail nextMediaSetSource: ", self._nextMediaSetSource)
end

function UMG_NRCMedia_C:OnSetNextVideoSucc()
  local setNotPlayedNextVideoIndex = FindSetNotPlayedNextVideoData(self)
  if not setNotPlayedNextVideoIndex then
    Log.Warning("UMG_NRCMedia_C: Cannot find any set not played next video!!!")
    return
  end
  if not self._nextVideoDataList then
    Log.Warning("UMG_NRCMedia_C: _nextVideoDataList is nil")
    return
  end
  if not self._nextVideoDataList[setNotPlayedNextVideoIndex] then
    return
  end
  local setNotPlayedNextVideoData = self._nextVideoDataList[setNotPlayedNextVideoIndex]
  self._nextMediaSetSource = setNotPlayedNextVideoData.source
  Log.Info("UMG_NRCMedia_C:OnSetNextVideoSucc nextMediaSetSource: ", self._nextMediaSetSource)
end

function UMG_NRCMedia_C:OnVideoRenderingStart()
  Log.Info("UMG_NRCMedia_C:OnVideoRenderingStart curPlayingNextVideoIndex ", self._curPlayingNextVideoIndex)
  local setNotPlayedNextVideoIndex = FindSetNotPlayedNextVideoData(self)
  if not setNotPlayedNextVideoIndex then
    self._videoHasTriggerPlayNextVideoSuccess = true
    self._curPlayingNextVideoIndex = nil
  else
    self._nextVideoIndexTriggeredPlayNextVideoSuccess = setNotPlayedNextVideoIndex
    self._curPlayingNextVideoIndex = self._nextVideoIndexTriggeredPlayNextVideoSuccess
  end
  Log.Info("UMG_NRCMedia_C:OnVideoRenderingStart curPlayingNextVideoIndex ", self._curPlayingNextVideoIndex, " _nextVideoIndexTriggeredPlayNextVideoSuccess ", self._nextVideoIndexTriggeredPlayNextVideoSuccess, " _videoHasTriggerPlayNextVideoSuccess ", self._videoHasTriggerPlayNextVideoSuccess)
  if not self._nextVideoDataList then
    Log.Info("UMG_NRCMedia_C:OnVideoRenderingStart no next video")
    return
  end
  local _, nextVideoData = FindNotSetOrSetNotPlayedNextVideoToHandle(self)
  if not nextVideoData then
    Log.Warning("UMG_NRCMedia_C: nextVideoData is nil, weird!!!")
    return
  end
  if nextVideoData.videoState == VIDEO_STATE.NOT_SET then
    SetNextVideo(self, nextVideoData.isFile, nextVideoData.source, nextVideoData.loop)
    nextVideoData.videoState = VIDEO_STATE.SET_NOT_PLAYED
  elseif nextVideoData.videoState == VIDEO_STATE.SET_NOT_PLAYED then
    if nextVideoData.soundID then
      local nextVideoSoundID = tonumber(nextVideoData.soundID)
      local nextAudioSessionID, nextAudioMaxTimeInMS = OpenAudio(self, nextVideoSoundID)
      nextVideoData.audioSessionID = nextAudioSessionID
      nextVideoData.audioMaxTimeInMS = nextAudioMaxTimeInMS
    end
    if nextVideoData.subtitleTrackID then
      local subtitleTrackID = tonumber(nextVideoData.subtitleTrackID)
      FillSrtDict(self, subtitleTrackID)
    end
    self._lastSyncAudioTimestamp = nil
    nextVideoData.videoState = VIDEO_STATE.PLAYED
  end
end

return UMG_NRCMedia_C
