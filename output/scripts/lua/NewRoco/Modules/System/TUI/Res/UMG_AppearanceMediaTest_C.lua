local UMG_AppearanceMediaTest_C = _G.NRCPanelBase:Extend("UMG_AppearanceMediaTest_C")

function UMG_AppearanceMediaTest_C:OnConstruct()
  self.NRCMedia:OnConstruct()
  self.bPlay = false
  self.MediaUrl:SetText("https://d1iv7db44yhgxn.cloudfront.net/documentation/attachments/2c9838e8-dc25-4fa0-a064-740f80480216/samplevideo.mp4")
end

function UMG_AppearanceMediaTest_C:OnActive()
  self.NRCMedia:OnActive()
  self:OnAddEventListener()
end

function UMG_AppearanceMediaTest_C:OnDeactive()
  self.NRCMedia:OnDeactive()
end

function UMG_AppearanceMediaTest_C:OnAddEventListener()
  self:AddButtonListener(self.BtnStart, self.OnBtnStartClicked)
  self:AddButtonListener(self.BtnClose.btnClose, self.OnCloseBtnClicked)
end

function UMG_AppearanceMediaTest_C:OnDestruct()
  self.NRCMedia:OnDestruct()
end

function UMG_AppearanceMediaTest_C:OnBtnStartClicked()
  self.bPlay = not self.bPlay
  self:PlayOrStop(self.bPlay)
end

function UMG_AppearanceMediaTest_C:OnCloseBtnClicked()
  self.NRCMedia:CloseMedia()
  self:DoClose()
end

function UMG_AppearanceMediaTest_C:PlayOrStop(bPlay)
  if bPlay then
    local fileUrl = self.MediaUrl:GetText()
    self:PlayMedia(fileUrl, false, true, true)
    self.NRCMedia:Play()
  else
    self.NRCMedia:Pause()
  end
end

function UMG_AppearanceMediaTest_C:PlayMedia(source, isFile, needAutoPlay, isLoop)
  local paramTable = {
    source = source,
    needAutoPlay = needAutoPlay,
    isLoop = isLoop
  }
  self.NRCMedia:OpenMediaPanelByParamTable(paramTable)
end

return UMG_AppearanceMediaTest_C
