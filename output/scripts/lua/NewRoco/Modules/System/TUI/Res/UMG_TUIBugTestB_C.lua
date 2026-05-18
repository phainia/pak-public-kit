local UMG_TUIBugTestB_C = _G.NRCPanelBase:Extend("UMG_TUIBugTestB_C")

function UMG_TUIBugTestB_C:OnConstruct()
end

function UMG_TUIBugTestB_C:OnActive()
  self:AddButtonListener(self.Closebtn, self.CloseClick)
  self:Disable()
end

function UMG_TUIBugTestB_C:CloseClick()
  self:DoClose()
end

function UMG_TUIBugTestB_C:OnEnable()
  self.UMG_TUIBugTestA:OnChange()
end

function UMG_TUIBugTestB_C:OnDisable()
end

function UMG_TUIBugTestB_C:OnDeactive()
end

function UMG_TUIBugTestB_C:OnAddEventListener()
end

return UMG_TUIBugTestB_C
