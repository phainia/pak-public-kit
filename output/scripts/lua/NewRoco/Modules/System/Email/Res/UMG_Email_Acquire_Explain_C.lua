local UMG_Email_Acquire_Explain_C = _G.NRCPanelBase:Extend("UMG_Email_Acquire_Explain_C")

function UMG_Email_Acquire_Explain_C:OnActive(arg)
  self:OnAddEventListener()
  if 0 == arg.type then
    self:ShowHelp(arg.title, arg.des)
  else
    self:ShowAward(arg.items)
  end
  self:PlayAnimation(self.Open)
  self:AddPcInputBlock()
end

function UMG_Email_Acquire_Explain_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_Email_Acquire_Explain_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_Email_Acquire_Explain_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_Email_Acquire_Explain_C:ShowHelp(title, des)
  self.Switcher:SetActiveWidgetIndex(0)
  self.NRCTitle_0:SetText(title)
  self.NRCText_77:SetText(des)
  self.UMG_Btn2_3:SetBtnText(LuaText.umg_email_acquire_explain_1)
  self.UMG_Btn2_2:SetBtnText(LuaText.umg_plane_teamitem_3)
end

function UMG_Email_Acquire_Explain_C:ShowAward(items)
  self.Switcher:SetActiveWidgetIndex(1)
end

function UMG_Email_Acquire_Explain_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_Btn2_2.btnLevelUp, self.OnClickbtnCloseRenamePanel)
  self:AddButtonListener(self.UMG_Btn2_3.btnLevelUp, self.OnClickOkbtn)
end

function UMG_Email_Acquire_Explain_C:OnClickOkbtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Email_C.OnShowTips")
  self:PlayAnimation(self.Close)
end

function UMG_Email_Acquire_Explain_C:OnClickbtnCloseRenamePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Email_C.OnShowTips")
  self:PlayAnimation(self.Close)
end

function UMG_Email_Acquire_Explain_C:OnAnimationFinished(Anim)
  if Anim == self.Close then
    self:DoClose()
  end
end

return UMG_Email_Acquire_Explain_C
