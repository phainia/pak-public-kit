local UMG_Dialog1_C = _G.NRCPanelBase:Extend("UMG_Dialog1_C")

function UMG_Dialog1_C:OnActive(context)
  UE4Helper.SetDesiredShowCursor(true, "UMG_Dialog1_C")
  self:AddButtonListener(self.BIGBT, self.ClosePanel)
  self:AddButtonListener(self.Btn_GlobalClose, self.ClosePanel)
  self:RefreshContent(context)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1011, "UMG_Dialog1_C:OnActive")
  self.InAnim = self:GetAnimByIndex(0)
  self.OutAnim = self:GetAnimByIndex(2)
  self:PlayAnimation(self.InAnim)
  self.isClosing = false
  self:BindInputAction()
end

function UMG_Dialog1_C:RefreshContent(context)
  self:SetContent(context.title, context.content, context.contentTextJustify)
  if context.listenHandler then
    self.CloseCallback = _G.MakeWeakFunctor(context.listener, context.listenHandler)
  end
end

function UMG_Dialog1_C:OnDisable()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Dialog1_C")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.CheckIFHasShouldOpenDialog)
end

function UMG_Dialog1_C:SetContent(title, content, contentTextJustify)
  if string.IsNilOrEmpty(title) then
    self.TitleText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.TitleText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TitleText:SetText(title)
  end
  if string.IsNilOrEmpty(content) then
    self.ContentText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ContentText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ContentText:SetText(content)
    if contentTextJustify then
      self.ContentText:SetJustification(contentTextJustify)
    end
  end
end

function UMG_Dialog1_C:ClosePanel()
  self.isClosing = true
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_Dialog1_C:ClosePanel")
  UE4Helper.ReleaseDesiredShowCursor("UMG_Dialog1_C")
  self:ClearAllEnhancedInput()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player then
    Player.inputComponent:SetCameraControlEnable(self, true)
  end
  self:StopAllAnimations()
  if self.OutAnim then
    self:PlayAnimation(self.OutAnim)
  else
    self:OnAnimationFinished(self.OutAnim)
  end
  if self.CloseCallback then
    self.CloseCallback()
  end
end

function UMG_Dialog1_C:OnAnimationFinished(anim)
  if anim == self.OutAnim then
    self:OnClose()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400010, "UMG_Dialog1_C:OnAnimationFinished")
  end
end

function UMG_Dialog1_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_Dialog1")
  if mappingContext then
    mappingContext:BindAction("IA_CloseDialog1", self, "OnPcClose2")
  end
end

function UMG_Dialog1_C:OnPcClose2()
  self:ClosePanel()
end

return UMG_Dialog1_C
