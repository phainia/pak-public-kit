local UMG_BeautyLogin_Tab_C = _G.NRCViewBase:Extend("UMG_BeautyLogin_Tab_C")

function UMG_BeautyLogin_Tab_C:OnConstruct()
  self.data = self.module:GetData("AppearanceLoginModuleData")
  self:OnAddEventListener()
end

function UMG_BeautyLogin_Tab_C:OnActive()
end

function UMG_BeautyLogin_Tab_C:OnDeactive()
end

function UMG_BeautyLogin_Tab_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Skin, self.OnBtnSkinClicked)
  self:AddButtonListener(self.Btn_Hair, self.OnBtnHairClicked)
  self:AddButtonListener(self.Btn_Eyebrow, self.OnBtnEyebrowClicked)
  self:AddButtonListener(self.Btn_Eyelash, self.OnBtnEyelashClicked)
  self:AddButtonListener(self.Btn_EyeColor, self.OnBtnEyeColorClicked)
  self:AddButtonListener(self.Btn_MakeUp, self.OnBtnMakeUpClicked)
end

function UMG_BeautyLogin_Tab_C:OnDestruct()
end

function UMG_BeautyLogin_Tab_C:OnBtnSkinClicked(_IsPlaySound)
  Log.Error("UMG_BeautyLogin_Tab_C:OnBtnSkinClicked")
  self:UnChooseAnimation(_IsPlaySound)
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_SKIN
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_SKIN)
  self:PlayAnimation(self.Btn_Skin_A)
end

function UMG_BeautyLogin_Tab_C:OnBtnHairClicked()
  self:UnChooseAnimation()
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_HAIR
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_HAIR)
  self:PlayAnimation(self.Btn_Hair_A)
end

function UMG_BeautyLogin_Tab_C:OnBtnEyebrowClicked()
  self:UnChooseAnimation()
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_EYEBORWS
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_EYEBORWS)
  self:PlayAnimation(self.Btn_Eyebrow_A)
end

function UMG_BeautyLogin_Tab_C:OnBtnEyelashClicked()
  self:UnChooseAnimation()
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_EYELASH
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_EYELASH)
  self:PlayAnimation(self.Btn_Eyelash_A)
end

function UMG_BeautyLogin_Tab_C:OnBtnEyeColorClicked()
  self:UnChooseAnimation()
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_EYES
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_EYES)
  self:PlayAnimation(self.Btn_EyeColor_A)
end

function UMG_BeautyLogin_Tab_C:OnBtnMakeUpClicked()
  self:UnChooseAnimation()
  self.data.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_MAKEUP
  self.module:OnCmdChangeBeautyChooseType(_G.Enum.SalonLabelType.SLT_MAKEUP)
  self:PlayAnimation(self.Btn_MakeUp_A)
end

function UMG_BeautyLogin_Tab_C:UnChooseAnimation(_IsPlaySound)
  if self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_SKIN then
    self:PlayAnimation(self.Btn_Skin_Out)
    self:StopAnimation(self.Btn_Skin_A)
  elseif self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_HAIR then
    self:PlayAnimation(self.Btn_Hair_Out)
    self:StopAnimation(self.Btn_Hair_A)
  elseif self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_EYEBORWS then
    self:PlayAnimation(self.Btn_Eyebrow_Out)
    self:StopAnimation(self.Btn_Eyebrow_A)
  elseif self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_EYELASH then
    self:PlayAnimation(self.Btn_Eyelash_Out)
    self:StopAnimation(self.Btn_Eyelash_A)
  elseif self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_EYES then
    self:PlayAnimation(self.Btn_EyeColor_Out)
    self:StopAnimation(self.Btn_EyeColor_A)
  elseif self.data.curBeautyChooseType == _G.Enum.SalonLabelType.SLT_MAKEUP then
    self:PlayAnimation(self.Btn_MakeUp_Out)
    self:StopAnimation(self.Btn_MakeUp_A)
  end
  if false ~= _IsPlaySound then
    _G.NRCAudioManager:PlaySound2DAuto(1060, "UMG_Beauty_Tab_C:UnChooseAnimation")
  end
end

return UMG_BeautyLogin_Tab_C
