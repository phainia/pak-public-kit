local UMG_BattleVideo_C = _G.NRCPanelBase:Extend("UMG_BattleVideo_C")

function UMG_BattleVideo_C:OnConstruct()
  self:Clear()
  self.UMG_NRCMedia:OnConstruct(self)
end

function UMG_BattleVideo_C:Clear()
  self.FinishCallbackOwner = nil
  self.FinishCallbackFunc = nil
  self.CurrentSpan = nil
end

function UMG_BattleVideo_C:OnDestruct()
  self.UMG_NRCMedia:RemoveOnEndReached(self, self.MovieDone)
  self.UMG_NRCMedia:RemoveOnMediaOpenFailed(self, self.MovieFailed)
  self.UMG_NRCMedia:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationWillEnterBackground, self.OnMediaEnterBackground)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnMediaEnterForeground)
end

function UMG_BattleVideo_C:OnActive(_param)
  self.UMG_NRCMedia:OnActive()
  _G.NRCEventCenter:RegisterEvent("UMG_BattleVideo_C", self, NRCGlobalEvent.OnApplicationWillEnterBackground, self.OnMediaEnterBackground)
  _G.NRCEventCenter:RegisterEvent("UMG_BattleVideo_C", self, NRCGlobalEvent.OnApplicationHasEnteredForeground, self.OnMediaEnterForeground)
  self.file_path = _param.file_path
  self.FinishCallbackFunc = _param.callback
  self.FinishCallbackOwner = _param.caller
  self.bSkipAppearAndDisappear = _param.bSkip
  self.SoundID = _param.soundID
  self.UMG_NRCMedia:SetNRCMediaImageSize(MediaUtils.DIALOGUE_VIDEO_RESOLUTION.X, MediaUtils.DIALOGUE_VIDEO_RESOLUTION.Y)
  if self.bSkipAppearAndDisappear then
    self:PlayMedia()
  else
    self:PlayAnimation(self.Appear)
  end
end

function UMG_BattleVideo_C:OnMediaEnterBackground()
  Log.Info("UMG_BattleVideo_C:OnMediaEnterBackground")
  if self.UMG_NRCMedia then
    self.UMG_NRCMedia:Pause()
    self.CurrentSpan = self.UMG_NRCMedia.MediaPlayer:GetTime()
    Log.Info("UMG_BattleVideo_C:OnMediaEnterBackground CurrentSpan %f", self.CurrentSpan:GetTotalMilliseconds())
  end
end

function UMG_BattleVideo_C:OnMediaEnterForeground()
  Log.Info("UMG_BattleVideo_C:OnMediaEnterForeground")
  if self.UMG_NRCMedia and self.CurrentSpan then
    Log.InfoFormat("UMG_BattleVideo_C:OnMediaEnterForeground CurrentSpan %f", self.CurrentSpan:GetTotalMilliseconds())
    self.UMG_NRCMedia:Seek(self.CurrentSpan)
    self.UMG_NRCMedia:Play()
  end
end

function UMG_BattleVideo_C:OnAnimationFinished(Animation)
  if Animation == self.Appear then
    self:PlayMedia()
  elseif Animation == self.Disappear then
    self:MediaEnd()
  end
end

function UMG_BattleVideo_C:PlayMedia()
  self.UMG_NRCMedia:AddOnEndReached(self, self.MovieDone)
  self.UMG_NRCMedia:AddOnMediaOpenFailed(self, self.MovieFailed)
  local paramTable = {
    source = self.file_path,
    needAutoPlay = true,
    isLoop = false,
    OpenResultCaller = self,
    OpenResultCallback = self.MovieFailed,
    soundID = self.SoundID
  }
  self.UMG_NRCMedia:OpenMediaPanelByParamTable(paramTable)
  UE4Helper.SetEnableWorldRendering(false, nil, "BattleVideo")
  _G.NRCAudioManager:SetStateByName("Story_Movie", "Story")
end

function UMG_BattleVideo_C:MediaEnd()
  if self.FinishCallbackFunc and self.FinishCallbackOwner then
    local callback = self.FinishCallbackFunc
    local caller = self.FinishCallbackOwner
    self.FinishCallbackOwner = nil
    self.FinishCallbackFunc = nil
    if callback then
      callback(caller)
    end
  end
  _G.NRCAudioManager:SetStateByName("Story_Movie", "None")
  self:DoClose()
end

function UMG_BattleVideo_C:MovieFailed()
  UE4Helper.SetEnableWorldRendering(nil, nil, "BattleVideo")
  Log.Error("UMG_BattleVideo_C: \232\181\132\230\186\144\233\133\141\231\189\174\230\156\137\233\151\174\233\162\152", self.file_path)
  if self.bSkipAppearAndDisappear then
    self:MediaEnd()
  else
    self:PlayAnimation(self.Disappear)
  end
end

function UMG_BattleVideo_C:MovieDone()
  UE4Helper.SetEnableWorldRendering(nil, nil, "BattleVideo")
  self.UMG_NRCMedia:CloseMedia()
  if self.bSkipAppearAndDisappear then
    self:MediaEnd()
  else
    self:PlayAnimation(self.Disappear)
  end
end

function UMG_BattleVideo_C:OnDeactive()
  self.UMG_NRCMedia:OnDeactive()
end

function UMG_BattleVideo_C:OnPcClose()
end

return UMG_BattleVideo_C
