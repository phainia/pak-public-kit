local UMG_RecoverTimeUpItem_C = _G.NRCPanelBase:Extend("UMG_RecoverTimeUpItem_C")

function UMG_RecoverTimeUpItem_C:OnActive()
end

function UMG_RecoverTimeUpItem_C:OnDeactive()
end

function UMG_RecoverTimeUpItem_C:OnAddEventListener()
end

function UMG_RecoverTimeUpItem_C:SetData(num)
  self.OldText:SetText(string.format("\195\151%d", num or 0))
end

return UMG_RecoverTimeUpItem_C
