local UMG_SystemSettingBtn_C = _G.NRCPanelBase:Extend("UMG_SystemSettingBtn_C")

function UMG_SystemSettingBtn_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_SystemSettingBtn_C:OnDestruct()
end

function UMG_SystemSettingBtn_C:OnActive()
end

function UMG_SystemSettingBtn_C:OnDeactive()
end

function UMG_SystemSettingBtn_C:OnAddEventListener()
  self.btnLevelUp.OnPressed:Add(self, self.OnBtnPressed)
  self.btnLevelUp.OnReleased:Add(self, self.OnBtnReleased)
end

function UMG_SystemSettingBtn_C:SetBtnText(text)
  if text then
    self.Title:SetText(text)
    self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_SystemSettingBtn_C:OnBtnPressed()
  self:PlayAnimation(self.Press)
end

function UMG_SystemSettingBtn_C:OnBtnReleased()
  self:PlayAnimation(self.Up)
end

return UMG_SystemSettingBtn_C
