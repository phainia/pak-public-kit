local UMG_ErrorPanel_C = _G.NRCPanelBase:Extend("UMG_ErrorPanel_C")

function UMG_ErrorPanel_C:OnActive(ErrorString, ErrorTrace)
  Log.Debug("UMG_ErrorPanel_C:OnActive", ErrorString, ErrorTrace)
  self.TxtTitle:SetText(ErrorString)
  self.TxtDescribe:SetText(ErrorTrace)
  self:OnAddEventListener()
end

function UMG_ErrorPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtn)
end

function UMG_ErrorPanel_C:OnClickCloseBtn()
  self:DoClose()
end

return UMG_ErrorPanel_C
