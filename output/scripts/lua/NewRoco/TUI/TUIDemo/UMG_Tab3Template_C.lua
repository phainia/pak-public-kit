local UMG_Tab3Template_C = _G.NRCPanelBase:Extend("UMG_Tab3Template_C")

function UMG_Tab3Template_C:OnConstruct()
  Log.Debug("UMG_Tab3Template_C:OnConstruct")
  self.UMG_NRCMedia:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Tab3Template_C:PlayMedia(source, isFile, needAutoPlay, isLoop)
  Log.Debug("UMG_Tab3Template_C:PlayMedia", source, isFile, needAutoPlay, isLoop)
  local paramTable = {
    source = source,
    needAutoPlay = needAutoPlay,
    isLoop = isLoop
  }
  self.UMG_NRCMedia:OpenMediaPanelByParamTable(paramTable)
end

function UMG_Tab3Template_C:OnDestruct()
  Log.Debug("UMG_Tab3Template_C:OnDestruct")
  self.UMG_NRCMedia:OnDestruct()
end

function UMG_Tab3Template_C:OnActive()
  Log.Debug("UMG_Tab3Template_C:OnActive")
  self.UMG_NRCMedia:OnActive()
  local fileSource = "C:/NRC/Project/Content/NewRoco/TUI/TUIDemo/test11.mp4"
  self:PlayMedia(fileSource, true, false, true)
  self.NRCWebView:LoadURL("https://space.bilibili.com/626796832?from=search&seid=10436496077278067540&spm_id_from=333.337.0.0")
  self.UMG_NRCPreview3D1:SetPreviewByPath("Blueprint'/Game/ArtRes/BP/Pets/Com_YaJiJi1_002/BP_Com_YaJiJi1_002.BP_Com_YaJiJi1_002_C'")
end

function UMG_Tab3Template_C:OnDeactive()
  self.UMG_NRCMedia:OnDeactive()
end

function UMG_Tab3Template_C:OnAddEventListener()
  self:AddButtonListener(self.Play, self.OnPlayClick)
  self:AddButtonListener(self.Pause, self.OnPauseClick)
  self:AddButtonListener(self.Replay, self.OnReplayClick)
end

function UMG_Tab3Template_C:OnPlayClick()
  self.UMG_NRCMedia:Play()
end

function UMG_Tab3Template_C:OnPauseClick()
  self.UMG_NRCMedia:Pause()
end

function UMG_Tab3Template_C:OnReplayClick()
  self.UMG_NRCMedia:Replay()
end

return UMG_Tab3Template_C
