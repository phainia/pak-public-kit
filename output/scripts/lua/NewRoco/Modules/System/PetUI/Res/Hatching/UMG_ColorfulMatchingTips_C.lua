local UMG_ColorfulMatchingTips_C = _G.NRCPanelBase:Extend("UMG_ColorfulMatchingTips_C")

function UMG_ColorfulMatchingTips_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_ColorfulMatchingTips_C:OnActive(EggGID, ParticleIconConf, SelectColorConf)
  self.EggGID = EggGID
  self.ParticleIconConf = ParticleIconConf
  self.SelectColorConf = SelectColorConf
  self:SetCommonPopUpInfo(self.PopUp3)
  self:UpdateView()
  self:LoadAnimation(0)
end

function UMG_ColorfulMatchingTips_C:SetCommonPopUpInfo(PopUp)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Btn_RightText = LuaText.umg_bag_popup_2
  CommonPopUpData.Btn_LeftText = LuaText.umg_bag_popup_1
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancelBtnClicked
  CommonPopUpData.Btn_RightHandler = self.OnSureBtnClicked
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ColorfulMatchingTips_C:OnCancelBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_ColorfulMatchingTips_C:OnCancelBtnClicked")
  self:ClosePanel()
end

function UMG_ColorfulMatchingTips_C:OnSureBtnClicked()
  Log.Debug("UMG_ColorfulMatchingTips_C:OnSureBtnClicked")
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_HATCH_EGG, true)
  isBan = isBan or _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_HATCH_EGG_GET_BACK, true)
  if isBan then
    return
  end
  if self.EggGID == nil then
    Log.Error("UMG_ColorfulMatchingTips_C:OnSureBtnClicked self.EggGID == nil")
    return
  end
  if nil == self.SelectColorConf then
    Log.Error("UMG_ColorfulMatchingTips_C:OnSureBtnClicked self.SelectColorConf == nil")
    return
  end
  if nil == self.ParticleIconConf then
    Log.Error("UMG_ColorfulMatchingTips_C:OnSureBtnClicked self.ParticleIconConf == nil")
    return
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ZoneCrackEggReq, self.EggGID, nil, nil, self.SelectColorConf.id, self.ParticleIconConf.id)
  self:ClosePanel()
end

function UMG_ColorfulMatchingTips_C:UpdateView()
  self.InstructionalText:SetText(LuaText.umg_pethatching11)
  if self.ParticleIconConf == nil then
    Log.Error("UMG_ColorfulMatchingTips_C:UpdateView ParticleIconConf is nil")
    return
  end
  if nil == self.SelectColorConf then
    Log.Error("UMG_ColorfulMatchingTips_C:UpdateView SelectColorConf is nil")
    return
  end
  if self.SelectColorConf.ui_color_1 then
    local color1 = self.SelectColorConf.ui_color_1 .. "FF"
    self.ColorfulColorScheme.NRCImage_A:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
  end
  if self.SelectColorConf.ui_color_2 then
    local color2 = self.SelectColorConf.ui_color_2 .. "FF"
    self.ColorfulColorScheme.NRCImage_B:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
  end
  local particleIconRes = self.ParticleIconConf.particle_big_icon
  if particleIconRes then
    self.ColorfulColorScheme.Image_Icon:SetPath(particleIconRes)
  end
end

function UMG_ColorfulMatchingTips_C:OnDeactive()
end

function UMG_ColorfulMatchingTips_C:OnAddEventListener()
end

function UMG_ColorfulMatchingTips_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_ColorfulMatchingTips_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_ColorfulMatchingTips_C:OnCancelBtnClicked")
  self:LoadAnimation(2)
end

return UMG_ColorfulMatchingTips_C
