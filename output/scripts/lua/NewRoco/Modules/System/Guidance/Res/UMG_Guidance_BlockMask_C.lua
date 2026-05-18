local UMG_Guidance_BlockMask_C = _G.NRCPanelBase:Extend("UMG_Guidance_BlockMask_C")

function UMG_Guidance_BlockMask_C:OnActive()
  self.OnPcCloseHandler = self.OnPcEscClose
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.GuidanceModuleEvent.OpenBlockMask, self.OnOpenBlockMask)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.GuidanceModuleEvent.CloseBlockMask, self.OnCloseBlockMask)
end

function UMG_Guidance_BlockMask_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.GuidanceModuleEvent.OpenBlockMask, self.OnOpenBlockMask)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.GuidanceModuleEvent.CloseBlockMask, self.OnCloseBlockMask)
end

function UMG_Guidance_BlockMask_C:OnPcEscClose()
end

function UMG_Guidance_BlockMask_C:OnOpenBlockMask()
  if self.Mask:IsVisible() then
    return
  end
  Log.Debug("UMG_Guidance_BlockMask_C:OnOpenBlockMask")
  self.Mask:SetVisibility(UE4.ESlateVisibility.Visible)
  self.panelData.enablePcEsc = true
  _G.NRCPanelManager:PushPanelWaitJudgeImc(self.panelData)
end

function UMG_Guidance_BlockMask_C:OnCloseBlockMask()
  if not self.Mask:IsVisible() then
    return
  end
  Log.Debug("UMG_Guidance_BlockMask_C:OnCloseBlockMask")
  self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.NRCPanelManager:TryRemoveImcManual(self.panelData)
  self.panelData.enablePcEsc = false
end

return UMG_Guidance_BlockMask_C
