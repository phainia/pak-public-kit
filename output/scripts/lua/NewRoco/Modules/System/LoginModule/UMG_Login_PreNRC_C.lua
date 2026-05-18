local UMG_Login_PreNRC_C = _G.NRCPanelBase:Extend("UMG_Login_PreNRC_C")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")

function UMG_Login_PreNRC_C:OnConstruct()
  self.VideoMap = {}
  self.VideoMap[UEPath.TENCENT_OPENING] = self.TencentOpeningVideo
  self.VideoMap[UEPath.MOREFUN_OPENING] = self.MoreFunOpeningVideo
  self.VideoMap[UEPath.LOGIN_CLOUD_LOOP] = self.CloudLoopVideo
  WeakTable(self.VideoMap)
  self.MediaPlayer.OnMediaOpened:Add(self, self.OnMediaOpened)
  self.MediaPlayer.OnEndReached:Add(self, self.OnMediaEnded)
end

function UMG_Login_PreNRC_C:OnActive()
  self.Video:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_Login_PreNRC_C:OnDeactive()
end

function UMG_Login_PreNRC_C:OnMediaOpened()
  Log.Debug("UMG_Login_PreNRC_C:OnMediaOpened")
  self.Video:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_Login_PreNRC_C:OnMediaEnded()
  Log.Debug("UMG_Login_PreNRC_C:OnMediaEnded")
  self.Video:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.MediaPlayer:Close()
  LoginUtils.CallAndRemoveCallback(self)
end

function UMG_Login_PreNRC_C:PlayVideo(VideoPath, bLoop, Caller, EndCallback)
  local VideoSource = self.VideoMap[VideoPath]
  if not VideoSource then
    Log.Error("VideoSource invalid")
    return
  end
  LoginUtils.RegisterCallback(self, Caller, EndCallback)
  local MediaOptions = UE4.FMediaPlayerOptions()
  MediaOptions.PlayOnOpen = true
  MediaOptions.Loop = bLoop
  self.MediaPlayer:OpenSourceWithOptions(VideoSource, MediaOptions)
end

function UMG_Login_PreNRC_C:OnAddEventListener()
end

return UMG_Login_PreNRC_C
