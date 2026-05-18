local UMG_KeystrokeCollision_C = _G.NRCPanelBase:Extend("UMG_KeystrokeCollision_C")
local SystemSettingEnum = require("NewRoco.Modules.System.SystemSetting.SystemSettingEnum")
local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")

function UMG_KeystrokeCollision_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
  self:OnAddEventListener()
end

function UMG_KeystrokeCollision_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_KeystrokeCollision_C:OnActive(actMode, buttonSettingConf, OperateItemIndex)
  self.uiData = {}
  self.uiData.ActData = {}
  self:SetCommonPopUpInfo(self.PopUp4)
  local param1, param2
  if actMode == SystemSettingEnum.KeyStrokeActMode.WaitingInput then
    self.uiData.buttonSettingConf = buttonSettingConf
    self.uiData.OperateItemIndex = OperateItemIndex
    param1 = buttonSettingConf.id
    param2 = buttonSettingConf.button_type
  end
  self:ChangeActMode(true, actMode, param1, param2)
end

function UMG_KeystrokeCollision_C:OnDeactive()
  self.uiData = {}
  self:LoadAnimation(2)
end

function UMG_KeystrokeCollision_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClickBtn2
  CommonPopUpData.Btn_RightHandler = self.OnClickBtn1
  CommonPopUpData.ClosePanelHandler = self.ExitCustomMapping
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_KeystrokeCollision_C:ChangeActMode(bFromActive, actMode, param1, param2)
  if bFromActive then
    self:LoadAnimation(0)
  else
    self:LoadAnimation(1)
  end
  self.uiData.ActMode = actMode
  if actMode == SystemSettingEnum.KeyStrokeActMode.WaitingInput then
    self.uiData.ActData[actMode] = {}
    self.uiData.ActData[actMode].buttonSettingId = param1
    self.uiData.ActData[actMode].buttonType = param2
    self:SetFocus()
    self.PopUp4:SetTitleTextInfo(LuaText.button_setting_pop_title1)
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PopUp4:SetDescInfo("")
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ConflictResolve then
    self.uiData.ActData[actMode] = {}
    self.uiData.ActData[actMode].buttonSettingId = param1
    self.uiData.ActData[actMode].conflictButtonSettingId = param2
    self.PopUp4:SetTitleTextInfo(LuaText.button_setting_pop_title2)
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp4:SetDescInfo("")
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local conflictButtonSettingConf = DataConfigManager:GetButtonSettingConf(param2)
    if nil == conflictButtonSettingConf then
      return
    end
    self.text_1:SetText(string.format(LuaText.button_setting_changing_conflict_tips, LuaText[SystemSettingEnum.ButtonTypeName[conflictButtonSettingConf.button_type]], conflictButtonSettingConf.button_action_name))
    local keyName, keyUIName, keyUIImage = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetButtonSettingMappingKey, param2, true)
    if string.IsNilOrEmpty(keyUIImage) then
      self.Text_Key:SetText(keyUIName)
      self.Text_Key:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.KeyBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.KeyBg:SetPath(keyUIImage)
      self.Text_Key:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.KeyBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ResetCustomMapping then
    self.uiData.ActData[actMode] = {}
    self.PopUp4:SetTitleTextInfo(LuaText.button_setting_pop_title3)
    self.PopUp4.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
    self.PopUp4.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.text_1:SetText(LuaText.button_setting_reset_tips)
  else
    Log.Error("\230\156\170\229\174\154\228\185\137\232\161\140\228\184\186", actMode)
    return
  end
end

function UMG_KeystrokeCollision_C:UpdateUI(param1, param2)
  if actMode == SystemSettingEnum.KeyStrokeActMode.WaitingInput then
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ConflictResolve then
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ResetCustomMapping then
    self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HorizontalBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCText_269:SetText(LuaText.button_setting_reset_tips)
  else
    Log.Error("\230\156\170\229\174\154\228\185\137\232\161\140\228\184\186", actMode)
    return
  end
end

function UMG_KeystrokeCollision_C:OnPcClose()
  self:ExitCustomMapping()
end

function UMG_KeystrokeCollision_C:ExitCustomMapping(bUpdateAllButtonThisType)
  local systemSettingModule = NRCModuleManager:GetModule("SystemSettingModule")
  if systemSettingModule then
    local actData = self.uiData.ActData[self.uiData.ActMode]
    local operateItemIndex = self.uiData.OperateItemIndex
    if bUpdateAllButtonThisType then
      operateItemIndex = nil
    end
    systemSettingModule:DispatchEvent(SystemSettingModuleEvent.UpdateCustomMappingUI, actData.buttonType, operateItemIndex)
  end
  self:LoadAnimation(2)
end

function UMG_KeystrokeCollision_C:OnKeyDown(InGeometry, InKeyEvent)
  local unhandled = UE4.UWidgetBlueprintLibrary.Unhandled()
  local key = UE4.UKismetInputLibrary.GetKey(InKeyEvent)
  if UE4.UKismetInputLibrary.EqualEqual_KeyKey(key, UE4.EKeys.Escape) then
    return unhandled
  end
  local actMode = self.uiData.ActMode
  local actData = self.uiData.ActData[actMode]
  if actMode == SystemSettingEnum.KeyStrokeActMode.WaitingInput then
    local retCode, extraRet1, extraRet2 = NRCModuleManager:DoCmd(SystemSettingModuleCmd.ChangeCustomKeyMapping, actData.buttonSettingId, key.KeyName, UE4.UNRCStatics.GetKeyCode(InKeyEvent))
    if retCode == SystemSettingEnum.CustomKeyMapRetCode.Success then
      self:ExitCustomMapping()
    elseif retCode == SystemSettingEnum.CustomKeyMapRetCode.ConflictError then
      local targetButtonSettingConf = _G.DataConfigManager:GetButtonSettingConf(extraRet1)
      if nil == targetButtonSettingConf or nil == targetButtonSettingConf.button_type or nil == targetButtonSettingConf.button_action_name then
        self:ExitCustomMapping()
        return unhandled
      end
      if not targetButtonSettingConf.button_ischangeable then
        local unChangeableKeyUIName = NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetKeyUIName, key.KeyName)
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.button_setting_cannot_be_set_key_here, LuaText[SystemSettingEnum.ButtonTypeName[targetButtonSettingConf.button_type]], unChangeableKeyUIName))
        return unhandled
      end
      self:ChangeActMode(false, SystemSettingEnum.KeyStrokeActMode.ConflictResolve, actData.buttonSettingId, extraRet1)
    elseif retCode == SystemSettingEnum.CustomKeyMapRetCode.UnMappableKeyError then
      local unMappableKeyUIName = NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetKeyUIName, extraRet1)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.button_setting_cannot_be_set_key, unMappableKeyUIName))
    elseif retCode == SystemSettingEnum.CustomKeyMapRetCode.SaveError then
      Log.Error("\228\191\157\229\173\152\231\148\168\230\136\183\232\135\170\229\174\154\228\185\137\230\140\137\233\148\174\230\152\160\229\176\132\230\150\135\228\187\182\229\164\177\232\180\165", retCode, actData.buttonSettingId)
      self:ExitCustomMapping()
    else
      Log.Error("\233\162\132\230\156\159\228\185\139\229\164\150\231\154\132\233\148\153\232\175\175", retCode, actData.buttonSettingId)
      self:ExitCustomMapping()
    end
  end
  return unhandled
end

function UMG_KeystrokeCollision_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_KeystrokeCollision_C:OnClickBtn2()
  local actMode = self.uiData.ActMode
  if actMode == SystemSettingEnum.KeyStrokeActMode.ConflictResolve then
    local actData = self.uiData.ActData[SystemSettingEnum.KeyStrokeActMode.WaitingInput]
    if actData then
      self:ChangeActMode(false, SystemSettingEnum.KeyStrokeActMode.WaitingInput, actData.buttonSettingId, actData.buttonType)
      return
    end
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ResetCustomMapping then
    self:LoadAnimation(2)
    return
  end
  Log.Error("\230\156\170\229\174\154\228\185\137\232\161\140\228\184\186")
  self:LoadAnimation(2)
end

function UMG_KeystrokeCollision_C:OnClickBtn1()
  local actMode = self.uiData.ActMode
  local actData = self.uiData.ActData[actMode]
  if actMode == SystemSettingEnum.KeyStrokeActMode.ConflictResolve then
    local switchRetCode = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.SwitchTwoCustomKeyMapping, actData.buttonSettingId, actData.conflictButtonSettingId)
    local bUpdateAllButtonThisType = false
    if switchRetCode == SystemSettingEnum.CustomKeyMapRetCode.Success then
      bUpdateAllButtonThisType = true
    elseif switchRetCode == SystemSettingEnum.CustomKeyMapRetCode.SaveError then
      Log.Error("\228\191\157\229\173\152\231\148\168\230\136\183\232\135\170\229\174\154\228\185\137\230\140\137\233\148\174\230\152\160\229\176\132\230\150\135\228\187\182\229\164\177\232\180\165", switchRetCode, actData.buttonSettingId, actData.conflictButtonSettingId)
    else
      Log.Error("\233\162\132\230\156\159\228\185\139\229\164\150\231\154\132\233\148\153\232\175\175", switchRetCode, actData.buttonSettingId, actData.conflictButtonSettingId)
    end
    self:ExitCustomMapping(bUpdateAllButtonThisType)
  elseif actMode == SystemSettingEnum.KeyStrokeActMode.ResetCustomMapping then
    _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.FullyApplyUserCustomKeyMapping, true)
    self:LoadAnimation(2)
  else
    Log.Error("\230\156\170\229\174\154\228\185\137\232\161\140\228\184\186", actMode)
    return
  end
end

function UMG_KeystrokeCollision_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_KeystrokeCollision_C", self, _G.NRCGlobalEvent.WINDOW_ACTIVATION_CHANGED, self.OnWindowActivationChanged)
end

function UMG_KeystrokeCollision_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.WINDOW_ACTIVATION_CHANGED, self.OnWindowActivationChanged)
end

function UMG_KeystrokeCollision_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_KeystrokeCollision_C:OnWindowActivationChanged(bActivate)
  if bActivate then
    if self:HasAnyUserFocus() then
      return
    else
      self:SetFocus()
    end
  end
end

return UMG_KeystrokeCollision_C
