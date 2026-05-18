local UMG_TUIFontTest_C = _G.NRCPanelBase:Extend("UMG_TUIFontTest_C")

function UMG_TUIFontTest_C:OnActive()
  UE4Helper.SetEnableWorldRendering(false)
  self:OnAddEventListener()
end

function UMG_TUIFontTest_C:OnDeactive()
end

function UMG_TUIFontTest_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseBtn)
end

function UMG_TUIFontTest_C:OnCloseBtn()
  UE4Helper.SetEnableWorldRendering(true)
  self:DoClose()
end

return UMG_TUIFontTest_C
