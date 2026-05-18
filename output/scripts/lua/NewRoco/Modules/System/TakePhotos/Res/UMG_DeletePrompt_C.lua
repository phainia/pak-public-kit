local UMG_DeletePrompt_C = _G.NRCPanelBase:Extend("UMG_DeletePrompt_C")

function UMG_DeletePrompt_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_DeletePrompt_C:OnCancel()
  if self.bPendingClose then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_DeletePrompt_C:OnCancel")
  self:ReqClose()
end

function UMG_DeletePrompt_C:ReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:LoadAnimation(2)
end

function UMG_DeletePrompt_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_DeletePrompt_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_RightHandler = self.OnConfirmBtnClicked
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_DeletePrompt_C:GetModule()
  return self.module
end

function UMG_DeletePrompt_C:OnActive(Data)
  self._Data = Data
  if not self:GetModule().data:IfNeedNotifyDelete() then
    return self:DoClose()
  end
  self:BindInputAction()
  self.Switch:SetIsChecked(false)
  self:SetCommonPopUpInfo(self.PopUp3, Data.TitleText or LuaText.takephoto_storage_delete_title)
  self.Desc1:SetText(Data.Text or LuaText.takephoto_storage_delete_tips)
  self:LoadAnimation(0)
end

function UMG_DeletePrompt_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CloseThird")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseThird")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_DeletePrompt_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseThird")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CloseThird")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_DeletePrompt_C:OnPcClose()
  self:ReqClose()
end

function UMG_DeletePrompt_C:OnDeactive()
  self:UnBindInputAction()
end

function UMG_DeletePrompt_C:OnAddEventListener()
end

function UMG_DeletePrompt_C:OnConfirmBtnClicked()
  if self.bPendingClose then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_DeletePrompt_C:OnConfirmBtnClicked")
  self:GetModule().data:OnDeleteNotifyConfirm(self.Switch:IsChecked())
  if self._Data.OnConfirm then
    self._Data.OnConfirm()
  end
  self:ReqClose()
end

return UMG_DeletePrompt_C
