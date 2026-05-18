local UMG_AlterSignature_C = _G.NRCPanelBase:Extend("UMG_AlterSignature_C")

function UMG_AlterSignature_C:OnConstruct()
  self.OldInput = nil
  self.NewInput = nil
  self:OnAddEventListener()
end

function UMG_AlterSignature_C:OnActive()
  local CardBriefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("card_signature_change_title").msg
  local LocalizationConf_1 = _G.DataConfigManager:GetLocalizationConf("card_signature_input_des").msg
  self.note = CardBriefInfo.card_signature
  self.InputBox:SetText(self.note)
  self.InputBox:SetHintText(LocalizationConf_1)
  self.NRCTitle_1:SetText(LocalizationConf)
  self:PlayAnimation(self.open)
end

function UMG_AlterSignature_C:OnDeactive()
end

function UMG_AlterSignature_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Affirm.btnLevelUp, self.OnClickConfirm)
  self:AddButtonListener(self.Btn_Cancel.btnLevelUp, self.CloseSignPanel)
  self.InputBox.OnTextChanged:Add(self, self.OnTextChanged)
  self.InputBox.OnTextEndTransaction:Add(self, self.OnTextEndTransaction)
end

function UMG_AlterSignature_C:OnTextChanged()
  if self._isPinYin then
    return
  end
  local text = self.InputBox:GetSelectedText()
  if text and "" ~= text then
    self._isPinYin = true
    return
  end
  self.NewInput = self.InputBox:GetText()
  local MaxCount = _G.DataConfigManager:GetRoleGlobalConfig("role_signature_num").num
  local MaxContent, CurrentNum = string.GetSubStr(self.NewInput, MaxCount)
  if MaxCount <= CurrentNum then
    self.InputBox:SetText(MaxContent)
  end
end

function UMG_AlterSignature_C:OnTextEndTransaction()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Plane_ExchangeVisits_C:OnActive")
  self._isPinYin = false
  self:OnTextChanged()
end

function UMG_AlterSignature_C:CloseSignPanel()
  _G.NRCAudioManager:PlaySound2DAuto(1006, "UMG_Plane_ExchangeVisits_C:OnActive")
  self:PlayAnimation(self.close)
end

function UMG_AlterSignature_C:OnClickConfirm()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Plane_ExchangeVisits_C:OnActive")
  local InputInfo = self.InputBox:GetText()
  if InputInfo ~= self.note then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ModifyPlayerSignature, self.note, InputInfo)
  else
    self:OnClose()
  end
end

function UMG_AlterSignature_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    self:DoClose()
  end
end

function UMG_AlterSignature_C:OnClose()
  self:PlayAnimation(self.close)
end

return UMG_AlterSignature_C
