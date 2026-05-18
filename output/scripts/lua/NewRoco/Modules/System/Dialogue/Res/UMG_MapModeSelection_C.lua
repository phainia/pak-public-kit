local UMG_MapModeSelection_C = _G.NRCPanelBase:Extend("UMG_MapModeSelection_C")

function UMG_MapModeSelection_C:OnConstruct()
  UE4Helper.SetDesiredShowCursor(true, "UMG_MapModeSelection_C")
  self:SetChildViews(self.Option1, self.Option2)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, false, "UMG_MapModeSelection_C")
end

function UMG_MapModeSelection_C:OnActive(action)
  if action then
    self.action = action
  end
  self.SelectMode = _G.DataModelMgr.PlayerDataModel:GetNavigationMode()
  if not self.action then
    self.PromptText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Cancel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.EmptyButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.PromptText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPower:SetText(LuaText.navigation_mode_help_text)
    self.Cancel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.EmptyButton:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Btn2:SetBtnText(LuaText.navigation_mode_btn)
  self.Options = {
    self.Option1,
    self.Option2
  }
  self:SetInfo()
  _G.NRCAudioManager:PlaySound2DAuto(40006009, "UMG_MapModeSelection_C:OnActive")
  self:PlayAnimation(self.In_3)
  self:OnAddEventListener()
end

function UMG_MapModeSelection_C:SetInfo()
  for i, v in ipairs(self.Options) do
    v:SetInfo(i, self.SelectMode)
  end
end

function UMG_MapModeSelection_C:SetSelectMode(Mode)
  if self.SelectMode and self.SelectMode ~= Mode then
    for i, v in ipairs(self.Options) do
      v:PlayUnSelectAnimation(Mode)
    end
  end
  self.SelectMode = Mode
end

function UMG_MapModeSelection_C:OnDeactive()
  local NavigationMode = _G.DataModelMgr.PlayerDataModel:GetNavigationMode()
  if self.action and NavigationMode and NavigationMode ~= ProtoEnum.NavigationModeType.NMT_NONE then
    self.action:EndAction()
  end
  UE4Helper.ReleaseDesiredShowCursor("UMG_MapModeSelection_C")
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, true, "UMG_MapModeSelection_C")
end

function UMG_MapModeSelection_C:CancelBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_MapModeSelection_C:CancelBtnClick")
  self:PlayAnimation(self.Out)
end

function UMG_MapModeSelection_C:OkBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_MapModeSelection_C:OkBtnClick")
  if self.SelectMode then
    _G.DataModelMgr.PlayerDataModel:SetNavigationMode(self.SelectMode)
    self:PlayAnimation(self.Out)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.navigation_mode_no_select_tips)
  end
end

function UMG_MapModeSelection_C:OnPcClose()
  if self.action then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.navigation_mode_first_help_tips)
  else
    self:PlayAnimation(self.Out)
  end
end

function UMG_MapModeSelection_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_MapModeSelection_C:ClosePanel")
  self:PlayAnimation(self.Out)
end

function UMG_MapModeSelection_C:OnAnimationStarted(anim)
  if anim == self.Out then
    _G.NRCAudioManager:PlaySound2DAuto(40006010, "UMG_MapModeSelection_C:OnActive")
  end
end

function UMG_MapModeSelection_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:DoClose()
  end
end

function UMG_MapModeSelection_C:EmptyButtonClick()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.navigation_mode_first_help_tips)
end

function UMG_MapModeSelection_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.ClosePanel)
  self:AddButtonListener(self.EmptyButton, self.EmptyButtonClick)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.CancelBtnClick)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OkBtnClick)
end

return UMG_MapModeSelection_C
