local UMG_Common_Skip_C = _G.NRCPanelBase:Extend("UMG_Common_Skip_C")

function UMG_Common_Skip_C:OnActive()
  self:AddButtonListener(self.SkipButton.Button, self.Skip)
  self.SkipButton:PlayAnimation(self.SkipButton.FadeIn, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 999)
end

function UMG_Common_Skip_C:OnDeactive()
end

function UMG_Common_Skip_C:OnAddEventListener()
end

function UMG_Common_Skip_C:OnPcClose()
  self:Skip()
end

function UMG_Common_Skip_C:Skip()
  self.module:DispatchEvent(_G.CommonModuleEvent.ON_SKIP)
end

return UMG_Common_Skip_C
