local UMG_PetReport_Reminder_C = _G.NRCPanelBase:Extend("UMG_PetReport_Reminder_C")

function UMG_PetReport_Reminder_C:OnActive()
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(1000, "UMG_PetReport_Reminder_C:OnActive")
end

function UMG_PetReport_Reminder_C:OnDeactive()
end

function UMG_PetReport_Reminder_C:OnAddEventListener()
end

function UMG_PetReport_Reminder_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    self:PlayAnimation(self.Out)
  elseif Anim == self.Out then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.StartShowPetReportTips)
  end
end

return UMG_PetReport_Reminder_C
