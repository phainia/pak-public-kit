local UMG_DialogWithBase_C = _G.NRCPanelBase:Extend("UMG_DialogWithBase_C")

function UMG_DialogWithBase_C:OnActive(dialogContent)
  self.Title:SetText(dialogContent.title)
  self.Desc1:SetText(dialogContent.content)
  self.Desc:SetText(dialogContent.contentBase)
  self.Desc2:SetText(dialogContent.content1)
  if dialogContent.clickAnywhereClose then
    self.BtnClose:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BtnClose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if dialogContent.ShowBtn then
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:LoadAnimation(0)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_Activity_Hint_C:OnCancel")
  self:OnAddEventListener()
end

function UMG_DialogWithBase_C:OnDeactive()
end

function UMG_DialogWithBase_C:OnAddEventListener()
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnClickOkButton)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnClickCancelButton)
  self:AddButtonListener(self.BtnClose, self.OnClickCancelButton)
end

function UMG_DialogWithBase_C:OnClickOkButton()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Activity_Hint_C:OnCancel")
  self:LoadAnimation(2)
end

function UMG_DialogWithBase_C:OnPcClose()
  self:OnClickCancelButton()
end

function UMG_DialogWithBase_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_DialogWithBase_C:OnClickCancelButton()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Activity_Hint_C:OnCancel")
  self:LoadAnimation(2)
end

return UMG_DialogWithBase_C
