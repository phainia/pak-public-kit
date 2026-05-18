local WB_FontTestIOS1_C = _G.NRCPanelBase:Extend("WB_FontTestIOS1_C")

function WB_FontTestIOS1_C:OnActive()
  self:OnAddEventListener()
end

function WB_FontTestIOS1_C:OnDeactive()
end

function WB_FontTestIOS1_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnClickCloseBtn)
end

function WB_FontTestIOS1_C:OnClickCloseBtn()
  self:DoClose()
end

return WB_FontTestIOS1_C
