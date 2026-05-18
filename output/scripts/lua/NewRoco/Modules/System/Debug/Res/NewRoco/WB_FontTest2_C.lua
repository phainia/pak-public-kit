local WB_FontTest2_C = _G.NRCPanelBase:Extend("WB_FontTest2_C")

function WB_FontTest2_C:OnActive()
  self:OnAddEventListener()
end

function WB_FontTest2_C:OnDeactive()
end

function WB_FontTest2_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnClickCloseBtn)
end

function WB_FontTest2_C:OnClickCloseBtn()
  self:DoClose()
end

return WB_FontTest2_C
