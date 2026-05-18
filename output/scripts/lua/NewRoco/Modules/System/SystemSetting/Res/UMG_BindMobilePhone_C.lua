local UMG_BindMobilePhone_C = _G.NRCPanelBase:Extend("UMG_BindMobilePhone_C")

function UMG_BindMobilePhone_C:OnConstruct()
  self.CodeNum = ""
  self.TimeCd = 0
  self.OperateType = nil
  self.UnbindAllScenes = false
  self:SetChildViews(self.PopUp)
  self:SetCanGetCode(true)
  self:OnAddEventListener()
  self.CountdownBtn:SetShowLockIcon(false)
end

function UMG_BindMobilePhone_C:OnActive(showType, data)
  self.moduleData = self.module.data
  self.ShowType = showType
  self.Check:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.IsCheck = false
  self.CanClickCheckBtn = true
  self.TimeCd = 0
  self:SetCommonPopUpInfo(self.PopUp)
  if data then
    self.UnbindAllScenes = data.unbind_all_scenes
  end
  if showType == self.moduleData.BindMobilePhoneEnum.BIND then
    self:ShowBindPanel()
  elseif showType == self.moduleData.BindMobilePhoneEnum.UNBIND then
    self:ShowUnBindPanel()
  elseif showType == self.moduleData.BindMobilePhoneEnum.BIND_SUCCESS then
    self:ShowBindSuccessPanel()
  elseif showType == self.moduleData.BindMobilePhoneEnum.UNBIND_SUCCESS then
    self:ShowUnBindSuccessPanel()
  end
  self:LoadAnimation(0)
end

function UMG_BindMobilePhone_C:ShowBindPanel()
  self:InitPhoneInfo()
  self.OperateType = self.moduleData.BindMobileOperateEnum.BIND
  self.BindingSuccessful:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Bind:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SizeBox_Input:SetVisibility(UE4.ESlateVisibility.Visible)
  self.AcquireBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CountdownBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PopUp:SetTitleTextInfo(_G.LuaText.Bound_Phone_Number_Title)
  self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Visible)
  local descData = self.moduleData:GetBindPhoneDesc()
  self.NRCText_2:SetText("        " .. descData.bind)
  self.Btn2:SetBtnText(_G.LuaText.Bound_Phone_Button_Text)
end

function UMG_BindMobilePhone_C:ShowUnBindPanel()
  self:InitPhoneInfo()
  self.OperateType = self.moduleData.BindMobileOperateEnum.UNBIND
  self.BindingSuccessful:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Bind:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCText:SetVisibility(UE4.ESlateVisibility.Visible)
  self.SizeBox_Input:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.AcquireBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CountdownBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCText:SetText(self.moduleData:GetEncryptPhoneNum(self.PhoneNum))
  self.PopUp:SetTitleTextInfo(_G.LuaText.Unbind_Phone_Number_Title)
  self.CanvasPanel_19:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local descData = self.moduleData:GetBindPhoneDesc()
  if self.UnbindAllScenes then
    self.NRCText_2:SetText(descData.unbind2_allScene)
  else
    self.NRCText_2:SetText(descData.unbind2)
  end
  self.Btn2:SetBtnText(_G.LuaText.Unbind_Phone_Button_Text)
end

function UMG_BindMobilePhone_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_BindMobilePhone_C:ShowBindSuccessPanel()
  self:InitPhoneInfo()
  self.BindingSuccessful:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Bind:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local text = string.format(_G.LuaText.Binding_Success_Tip_Text, self.moduleData:GetEncryptPhoneNum(self.PhoneNum))
  self.Text_BindingSuccessful:SetText(text)
  self.PopUp:SetTitleTextInfo(_G.LuaText.Binding_Success_Tip_Title)
  self.Btn2:SetBtnText(_G.LuaText.umg_petaltar_1)
end

function UMG_BindMobilePhone_C:ShowUnBindSuccessPanel()
  self.BindingSuccessful:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Bind:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local descData = self.moduleData:GetBindPhoneDesc()
  if self.UnbindAllScenes then
    self.Text_BindingSuccessful:SetText(descData.unbind3_allScene)
  else
    self.Text_BindingSuccessful:SetText(descData.unbind3)
  end
  self.PopUp:SetTitleTextInfo(_G.LuaText.Unbinding_Success_Tip_Title)
  self.Btn2:SetBtnText(_G.LuaText.umg_petaltar_1)
end

function UMG_BindMobilePhone_C:OnDeactive()
end

function UMG_BindMobilePhone_C:OnAddEventListener()
  self:AddDelegateListener(self.InputText1.OnTextChanged, self.OnPhoneTextChanged)
  self:AddDelegateListener(self.InputText2.OnTextChanged, self.OnCodeTextChanged)
  self.AcquireBtn.btnLevelUp.OnClicked:Add(self, self.OnGetVerificationCode)
  self:AddButtonListener(self.CountdownBtn.btnLevelUp, self.CountDownCodeBtnClicked)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnConfirmBtnClick)
  self:AddButtonListener(self.NRCButton_87, self.OnCheckBtnClick)
end

function UMG_BindMobilePhone_C:OnPhoneTextChanged()
  _G.NRCAudioManager:PlaySound2DAuto(40008038, "UMG_BindMobilePhone_C:OnPhoneTextChanged")
  local inputStr = self.InputText1:GetText()
  if "" == inputStr or inputStr:match("^%d+$") and #inputStr <= 11 then
    self.PhoneNum = inputStr
  else
    self.InputText1:SetText(self.PhoneNum)
  end
end

function UMG_BindMobilePhone_C:OnCodeTextChanged()
  _G.NRCAudioManager:PlaySound2DAuto(40008038, "UMG_BindMobilePhone_C:OnCodeTextChanged")
  local inputStr = self.InputText2:GetText()
  if "" == inputStr or inputStr:match("^%d+$") and #inputStr <= 6 then
    self.CodeNum = inputStr
  else
    self.InputText2:SetText(self.CodeNum)
  end
end

function UMG_BindMobilePhone_C:OnGetVerificationCode()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_BindMobilePhone_C:OnGetVerificationCode")
  if not self.CanGetCode then
    return
  end
  Log.Debug("UMG_BindMobilePhone_C:OnGetVerificationCode==\231\187\153\229\144\142\229\143\176\229\143\145\233\128\129\232\142\183\229\143\150\233\170\140\232\175\129\231\160\129")
  if self.ShowType == self.moduleData.BindMobilePhoneEnum.BIND then
    if not self.IsCheck then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Confirmation_Tick_Prompt, nil, nil, 1)
      return
    end
    if self.PhoneNum == "" then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Message_Cell_Phone_Number_Not_Entered, nil, nil, 1)
      return
    end
    if not string.match(self.PhoneNum, "^1%d%d%d%d%d%d%d%d%d%d$") then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Error_Code_2336, nil, nil, 1)
      return
    end
    self:SetCanGetCode(false)
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqGetPhoneBindCode, self.PhoneNum)
  elseif self.ShowType == self.moduleData.BindMobilePhoneEnum.UNBIND then
    self:SetCanGetCode(false)
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqGetPhoneBindCode, self.PhoneNum)
  end
end

function UMG_BindMobilePhone_C:OnConfirmBtnClick()
  if self.ShowType == self.moduleData.BindMobilePhoneEnum.BIND then
    _G.NRCAudioManager:PlaySound2DAuto(1144, "UMG_BindMobilePhone_C:OnConfirmBtnClick")
    Log.Debug("UMG_BindMobilePhone_C:OnGetVerificationCode==\231\187\145\229\174\154\230\137\139\230\156\186\239\188\140\229\143\145\233\128\129\230\137\139\230\156\186\229\143\183\231\160\129\229\146\140\233\170\140\232\175\129\231\160\129")
    if not self.IsCheck then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Confirmation_Tick_Prompt, nil, nil, 1)
      return
    end
    if self.PhoneNum == "" then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Message_Cell_Phone_Number_Not_Entered, nil, nil, 1)
      return
    end
    if #self.PhoneNum ~= self.moduleData.PhoneLimitLen then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Error_Code_2336, nil, nil, 1)
      return
    end
    if "" == self.CodeNum then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Verification_Code_Prompt, nil, nil, 1)
      return
    end
    if #self.CodeNum ~= self.moduleData.CodeLimitLen then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Error_Code_2334, nil, nil, 1)
      return
    end
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqBindPhoneNum, self.OperateType, self.PhoneNum, self.CodeNum, false)
  elseif self.ShowType == self.moduleData.BindMobilePhoneEnum.UNBIND then
    _G.NRCAudioManager:PlaySound2DAuto(1144, "UMG_BindMobilePhone_C:OnConfirmBtnClick")
    Log.Debug("UMG_BindMobilePhone_C:OnGetVerificationCode==\232\167\163\231\187\145\230\137\139\230\156\186\239\188\140\229\143\145\233\128\129\230\137\139\230\156\186\229\143\183\231\160\129\229\146\140\233\170\140\232\175\129\231\160\129")
    if #self.PhoneNum ~= self.moduleData.PhoneLimitLen then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Error_Code_2336, nil, nil, 1)
      return
    end
    if "" == self.CodeNum then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Popup_Error_Verification_Code_Prompt, nil, nil, 1)
      return
    end
    if #self.CodeNum ~= self.moduleData.CodeLimitLen then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Error_Code_2334, nil, nil, 1)
      return
    end
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqBindPhoneNum, self.OperateType, self.PhoneNum, self.CodeNum, self.UnbindAllScenes)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1220002026, "UMG_BindMobilePhone_C:OnConfirmBtnClick")
    self:DoClose()
  end
end

function UMG_BindMobilePhone_C:UpdateUIByGetCode()
  local phoneInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerMobileBindInfo()
  if phoneInfo and phoneInfo.sms_code_time then
    local currentTime = _G.ZoneServer:GetServerTime() / 1000.0
    local timeStamp = currentTime - phoneInfo.sms_code_time
    if timeStamp < 60 then
      self.TimeCd = 60 - timeStamp
      self:ShowTimeCd()
      return
    end
  end
  self.TimeCd = 0
  self:ShowCodeBtn()
end

function UMG_BindMobilePhone_C:SetCanGetCode(enable)
  self.CanGetCode = enable
end

function UMG_BindMobilePhone_C:OnTick(deltaTime)
  if self.TimeCd > 0 then
    self.TimeCd = self.TimeCd - deltaTime
    if self.TimeCd < 0 then
      self.TimeCd = 0
    end
    self:ShowTimeCd()
  else
    self.TimeCd = 0
    self:ShowCodeBtn()
  end
end

function UMG_BindMobilePhone_C:OnCheckBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_BindMobilePhone_C:OnCheckBtnClick")
  if not self.CanClickCheckBtn then
    return
  end
  self.CanClickCheckBtn = false
  if self.IsCheck then
    self.IsCheck = false
    self:PlayCheckAnimation(self.Click_out)
  else
    self.IsCheck = true
    self:PlayCheckAnimation(self.Click)
  end
end

function UMG_BindMobilePhone_C:PlayCheckAnimation(anim)
  if self.Check:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.Check:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimation(anim)
end

function UMG_BindMobilePhone_C:OnAnimationFinished(anim)
  if anim == self.Click_out or anim == self.Click then
    self.CanClickCheckBtn = true
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_BindMobilePhone_C:OnClose()
  self:LoadAnimation(2)
end

function UMG_BindMobilePhone_C:InitPhoneInfo()
  local phoneInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerMobileBindInfo()
  local isGetPhone = false
  local isGetTimeCd = false
  if phoneInfo then
    if phoneInfo.mobile_num and phoneInfo.mobile_num ~= "" then
      self.PhoneNum = phoneInfo.mobile_num
      isGetPhone = true
    end
    if phoneInfo.sms_code_time then
      local currentTime = _G.ZoneServer:GetServerTime() / 1000.0
      local timeStamp = currentTime - phoneInfo.sms_code_time
      if timeStamp < 60 then
        self.TimeCd = 60 - timeStamp
        self:ShowTimeCd()
        isGetTimeCd = true
      end
    end
  end
  if not isGetPhone then
    self.PhoneNum = ""
  end
  if not isGetTimeCd then
    self.TimeCd = 0
    self:ShowCodeBtn()
  end
end

function UMG_BindMobilePhone_C:ShowTimeCd()
  local showNum = math.floor(self.TimeCd)
  self.CountdownBtn:SetBtnText(tostring(showNum))
  self.CountdownBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.AcquireBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_BindMobilePhone_C:ShowCodeBtn()
  self.CountdownBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.AcquireBtn:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_BindMobilePhone_C:CountDownCodeBtnClicked()
  local desc = _G.LuaText.Error_Code_2333
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, desc, nil, nil, 1)
end

return UMG_BindMobilePhone_C
