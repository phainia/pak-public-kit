local UMG_MagicManualDescTips_C = _G.NRCPanelBase:Extend("UMG_MagicManualDescTips_C")

function UMG_MagicManualDescTips_C:OnActive(DescId)
  local DescNoteConf = _G.DataConfigManager:GetDescNoteConf(tonumber(DescId))
  if not DescNoteConf then
    self:DoClose()
    return
  end
  if DescNoteConf.picture then
    self.ContentImage:SetPath(DescNoteConf.picture)
  end
  self.ContentText:SetText(DescNoteConf.desc)
  self.TitleText:SetText(DescNoteConf.note)
  self:OnAddEventListener()
end

function UMG_MagicManualDescTips_C:OnDeactive()
end

function UMG_MagicManualDescTips_C:ClosePanel()
  self:DoClose()
end

function UMG_MagicManualDescTips_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_GlobalClose, self.ClosePanel)
end

return UMG_MagicManualDescTips_C
