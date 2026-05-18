local WB_FontTestIOS2_C = _G.NRCPanelBase:Extend("WB_FontTestIOS2_C")

function WB_FontTestIOS2_C:OnActive()
  self:OnAddEventListener()
end

function WB_FontTestIOS2_C:OnDeactive()
end

function WB_FontTestIOS2_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnClickCloseBtn)
end

function WB_FontTestIOS2_C:OnClickCloseBtn()
  self:DoClose()
end

return WB_FontTestIOS2_C
