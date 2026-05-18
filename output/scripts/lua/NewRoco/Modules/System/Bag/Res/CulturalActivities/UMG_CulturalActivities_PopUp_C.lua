local UMG_CulturalActivities_PopUp_C = _G.NRCPanelBase:Extend("UMG_CulturalActivities_PopUp_C")

function UMG_CulturalActivities_PopUp_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_CulturalActivities_PopUp_C:OnActive()
  self.InAnim = self:GetAnimByIndex(0)
  self.OutAnim = self:GetAnimByIndex(2)
  self:PlayAnimation(self.InAnim)
  local titleText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_title").str
  local sendText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_send").str
  local messageText = _G.DataConfigManager:GetActivityGlobalConfig("SIM_Phone_message").str
  self.NRCText_0:SetText(titleText)
  self.Text_Title:SetText(sendText)
  self.Text_Title_1:SetText(messageText)
end

function UMG_CulturalActivities_PopUp_C:OnDeactive()
end

function UMG_CulturalActivities_PopUp_C:OnAddEventListener()
  self:AddButtonListener(self.FullScreen_Close, self.ClosePanel)
end

function UMG_CulturalActivities_PopUp_C:ClosePanel()
  Log.Error(11)
  self:PlayAnimation(self.OutAnim)
end

function UMG_CulturalActivities_PopUp_C:OnPcClose()
  self:ClosePanel()
end

function UMG_CulturalActivities_PopUp_C:OnAnimationFinished(anim)
  if anim == self.OutAnim then
    self:DoClose()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400010, "UMG_Dialog1_C:OnAnimationFinished")
  end
end

return UMG_CulturalActivities_PopUp_C
