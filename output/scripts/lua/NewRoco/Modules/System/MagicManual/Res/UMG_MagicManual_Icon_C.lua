local UMG_MagicManual_Icon_C = _G.NRCPanelBase:Extend("UMG_MagicManual_Icon_C")

function UMG_MagicManual_Icon_C:Construct()
  self:OnAddEventListener()
end

function UMG_MagicManual_Icon_C:OnActive()
end

function UMG_MagicManual_Icon_C:OnDeactive()
end

function UMG_MagicManual_Icon_C:OnAddEventListener()
  self.Btn_Pass.OnClicked:Add(self, self.OnBtnClick)
end

function UMG_MagicManual_Icon_C:OnBtnClick()
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OpenMagicManual)
end

return UMG_MagicManual_Icon_C
