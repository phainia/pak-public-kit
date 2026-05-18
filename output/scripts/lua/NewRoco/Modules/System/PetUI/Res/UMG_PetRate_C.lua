local UMG_PetRate_C = _G.NRCViewBase:Extend("UMG_PetRate_C")
local NRCPanelDynamicData = require("Core.NRCPanel.NRCPanelDynamicData")

function UMG_PetRate_C:OnConstruct()
  self.PetData = nil
  self:OnAddEventListener()
end

function UMG_PetRate_C:OnDestruct()
end

function UMG_PetRate_C:OnActive()
end

function UMG_PetRate_C:OnDeactive()
end

function UMG_PetRate_C:SetText(petData, openType)
  self.openType = openType
  self.PetData = petData
  local talent = petData.talent_rank
  self:IsShowStart(talent == Enum.PetTalentRate.PTR_PERFECT)
  local Text
  if talent == _G.Enum.PetTalentRate.PTR_NORMAL then
    Text = _G.DataConfigManager:GetPetGlobalConfig("pet_talent_text1").str
    self.Switcher_TalentBg:SetActiveWidgetIndex(3)
    self.Gift_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#D4D2C5FF"))
  elseif talent == Enum.PetTalentRate.PTR_GOOD then
    Text = _G.DataConfigManager:GetPetGlobalConfig("pet_talent_text2").str
    self.Switcher_TalentBg:SetActiveWidgetIndex(0)
    self.Gift_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFFFF"))
  elseif talent == Enum.PetTalentRate.PTR_AMAZING then
    Text = _G.DataConfigManager:GetPetGlobalConfig("pet_talent_text3").str
    self.Switcher_TalentBg:SetActiveWidgetIndex(1)
    self.Gift_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFC65FFF"))
  elseif talent == Enum.PetTalentRate.PTR_PERFECT then
    Text = _G.DataConfigManager:GetPetGlobalConfig("pet_talent_text4").str
    self.Switcher_TalentBg:SetActiveWidgetIndex(2)
    self:IsShowStart(true)
    self:PlayAnimation(self.Level4, 0, 99999)
  else
    Text = _G.DataConfigManager:GetPetGlobalConfig("pet_talent_text1").str
    self.Switcher_TalentBg:SetActiveWidgetIndex(0)
    self.Gift_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#D4D2C5FF"))
  end
  self.NRCText_68:SetText(Text)
end

function UMG_PetRate_C:IsShowStart(Show)
  self:StopAllAnimations()
  if self.ParticleSystemWidget2_29 then
    if Show then
      self.ParticleSystemWidget2_29:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.ParticleSystemWidget2_29:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PetRate_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Talent, self.OnBtn_TalentClick)
end

function UMG_PetRate_C:OnBtn_TalentClick()
  local islock = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetHatchingIsSelected)
  if islock then
    return
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Press)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
  local panelDynamicData = NRCPanelDynamicData()
  local tipDesirePanelLayer = self.tipDesirePanelLayer
  if tipDesirePanelLayer then
    panelDynamicData:SetModifiedPanelLayerType(tipDesirePanelLayer)
  end
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenPetRateTip, self.PetData, self.openType, panelDynamicData)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").RATE
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
end

function UMG_PetRate_C:SetTipDesirePanelLayer(uiLayer)
  self.tipDesirePanelLayer = uiLayer
end

return UMG_PetRate_C
