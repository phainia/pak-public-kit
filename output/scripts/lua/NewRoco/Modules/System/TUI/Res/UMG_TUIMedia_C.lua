local UMG_TUIMedia_C = _G.NRCPanelBase:Extend("UMG_TUIMedia_C")

function UMG_TUIMedia_C:OnConstruct()
  self.IsHide = false
  self.IsPause = false
  self.UMG_NRCMedia:OnConstruct()
end

function UMG_TUIMedia_C:OnDestruct()
  self.UMG_NRCMedia:OnDestruct()
end

function UMG_TUIMedia_C:OnActive()
  self.UMG_NRCMedia:OnActive()
  self:OnAddEventListener()
end

function UMG_TUIMedia_C:OnDeactive()
  self.UMG_NRCMedia:OnDeactive()
end

function UMG_TUIMedia_C:OnAddEventListener()
  self:AddButtonListener(self.CloseMediaBtn, self.OnClickCloseMediaBtn)
  self:AddButtonListener(self.ReplayBtn, self.OnClickReplayBtn)
  self:AddButtonListener(self.PlayBtn, self.OnPlayBtn)
  self:AddButtonListener(self.PauseBtn, self.OnPauseBtn)
  self:AddButtonListener(self.HideBtn, self.OnHideBtn)
end

function UMG_TUIMedia_C:OnPlayBtn()
  local fileSource = self.PathText:GetText()
  local File = string.format("%s%s", UE4.UBlueprintPathsLibrary.ProjectContentDir(), fileSource)
  Log.Debug(File, "UMG_TUIMedia_C:OnPlayBtn")
  if "" ~= File then
    self:PlayMedia(File, true, false, true)
    self.UMG_NRCMedia:Play()
  end
end

function UMG_TUIMedia_C:OnPauseBtn()
  self.IsPause = not self.IsPause
  if self.IsPause then
    self.UMG_NRCMedia:Pause()
  else
    self.UMG_NRCMedia:Pause()
  end
end

function UMG_TUIMedia_C:OnHideBtn()
  self.IsHide = not self.IsHide
  if self.IsHide then
    self.TextBlock_1:SetText("\230\152\190\231\164\186\229\138\159\232\131\189\233\148\174")
    self.HideBtn:SetRenderOpacity(0.2)
    self.ToolCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.TextBlock_1:SetText("\233\154\144\232\151\143\229\138\159\232\131\189\233\148\174")
    self.HideBtn:SetRenderOpacity(1)
    self.ToolCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_TUIMedia_C:OnClickReplayBtn()
  self.UMG_NRCMedia:Replay()
end

function UMG_TUIMedia_C:OnClickCloseMediaBtn()
  self.UMG_NRCMedia:CloseMedia()
end

function UMG_TUIMedia_C:PlayMedia(source, isFile, needAutoPlay, isLoop)
  Log.Debug("UMG_Tab3Template_C:PlayMedia", source, isFile, needAutoPlay, isLoop)
  local paramTable = {
    source = source,
    needAutoPlay = needAutoPlay,
    isLoop = isLoop
  }
  self.UMG_NRCMedia:OpenMediaPanelByParamTable(paramTable)
end

return UMG_TUIMedia_C
