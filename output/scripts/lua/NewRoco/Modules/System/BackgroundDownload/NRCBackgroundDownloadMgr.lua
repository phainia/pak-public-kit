local NRCBackgroundDownloadMgr = _G.Singleton:Extend("NRCBackgroundDownloadMgr")

function NRCBackgroundDownloadMgr:Ctor()
  Log.Debug("BackgroundDownloadMgr:Ctor")
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance then
    Log.Error("GameInstance is nil")
    return
  end
  self.bind = GameInstance:GetBackgroundDownloadMgr()
end

function NRCBackgroundDownloadMgr:InitLocalTexts()
  local Downloading = LuaText.Downloading_in_the_background
  local Failed = LuaText.Download_failed
  local Success = LuaText.Download_complete
  local Paused = LuaText.Download_using_data
  self:SetDownloadTexts(Downloading, Failed, Success, Paused)
end

function NRCBackgroundDownloadMgr:SetIsEnableBackgroundDownload(bEnable)
  if self.bind then
    self.bind:SetIsEnableBackgroundDownload(bEnable)
  else
    Log.Error("BackgroundDownloadMgr:SetIsEnableBackgroundDownload: self.bind is nil")
  end
end

function NRCBackgroundDownloadMgr:IsEnableBackgroundDownload()
  if self.bind then
    return self.bind:IsEnableBackgroundDownload()
  else
    Log.Error("BackgroundDownloadMgr:IsEnableBackgroundDownload: self.bind is nil")
    return false
  end
end

function NRCBackgroundDownloadMgr:SetIsUpdating(bIsUpdating)
  if self.bind then
    self.bind:SetIsUpdating(bIsUpdating)
  else
    Log.Error("BackgroundDownloadMgr:SetIsUpdating: self.bind is nil")
  end
end

function NRCBackgroundDownloadMgr:IsUpdating()
  if self.bind then
    return self.bind:IsUpdating()
  else
    Log.Error("BackgroundDownloadMgr:IsUpdating: self.bind is nil")
    return false
  end
end

function NRCBackgroundDownloadMgr:StopBackgroundDownload()
  if self.bind then
    return self.bind:StopBackgroundDownload()
  else
    Log.Error("BackgroundDownloadMgr:StopBackgroundDownload: self.bind is nil")
  end
end

function NRCBackgroundDownloadMgr:SetBackgroundDownloadInfo(BackgroundDownloadType, InTaskID)
  if self.bind then
    self.bind:SetBackgroundDownloadInfo(BackgroundDownloadType, InTaskID)
  else
    Log.Error("BackgroundDownloadMgr:SetBackgroundDownloadInfo: self.bind is nil")
  end
end

function NRCBackgroundDownloadMgr:SetDownloadTexts(InDownloading, InFailed, InSuccess, InPaused)
  if self.bind then
    self.bind:SetDownloadTexts(InDownloading, InFailed, InSuccess, InPaused)
  else
    Log.Error("BackgroundDownloadMgr:SetDownloadTexts: self.bind is nil")
  end
end

return NRCBackgroundDownloadMgr
