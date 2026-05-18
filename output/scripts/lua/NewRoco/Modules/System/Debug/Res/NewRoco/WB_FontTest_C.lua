local WB_FontTest_C = _G.NRCPanelBase:Extend("WB_FontTest_C")

function WB_FontTest_C:OnActive()
  self:OnAddEventListener()
end

function WB_FontTest_C:OnDeactive()
end

function WB_FontTest_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnClickCloseBtn)
end

function WB_FontTest_C:OnClickCloseBtn()
  self:DoClose()
end

return WB_FontTest_C
