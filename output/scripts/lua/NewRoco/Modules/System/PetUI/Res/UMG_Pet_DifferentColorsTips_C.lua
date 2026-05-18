local UMG_Pet_DifferentColorsTips_C = _G.NRCPanelBase:Extend("UMG_Pet_DifferentColorsTips_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_Pet_DifferentColorsTips_C:OnActive(petData)
  self.PetData = petData
  self.IsCanClose = true
  self:OnAddEventListener()
  self:ShowInfo()
  self:LoadAnimation(0)
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_Pet_DifferentColorsTips_C:OnActive")
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").DAZZLING
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
end

function UMG_Pet_DifferentColorsTips_C:OnDeactive()
end

function UMG_Pet_DifferentColorsTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnBtnCloseTipsClick)
end

function UMG_Pet_DifferentColorsTips_C:ShowInfo()
  self.BloodPulse:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BloodPulse2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if PetUtils.CheckIsShiningChaos(self.PetData.mutation_type) then
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("mutation_explain_tips_4")
    local name = _G.DataConfigManager:GetLocalizationConf("mutation_text_5")
    if tipTxt and name and tipTxt.msg and name.msg then
      self.NRCText_76:SetText(name.msg)
      self.ChangeText:SetText(tipTxt.msg)
    end
    local path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_emengyis_png.img_emengyis_png'"
    self.BloodPulse2:SetPath(path)
  elseif PetUtils.CheckIsCHAOS(self.PetData.mutation_type) then
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("mutation_explain_tips_2")
    local name = _G.DataConfigManager:GetLocalizationConf("mutation_text_2")
    if tipTxt and name and tipTxt.msg and name.msg then
      self.NRCText_76:SetText(name.msg)
      self.ChangeText:SetText(tipTxt.msg)
    end
    local path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_emeng_png.img_emeng_png'"
    self.BloodPulse2:SetPath(path)
  elseif PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("mutation_explain_tips_1")
    local name = _G.DataConfigManager:GetLocalizationConf("mutation_text_1")
    if tipTxt and name and tipTxt.msg and name.msg then
      self.NRCText_76:SetText(name.msg)
      self.ChangeText:SetText(tipTxt.msg)
    end
    local path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_yisetubian_png.img_yisetubian_png'"
    self.BloodPulse2:SetPath(path)
  end
end

function UMG_Pet_DifferentColorsTips_C:OnBtnCloseTipsClick()
  if not self.IsCanClose then
    return
  end
  self.IsCanClose = false
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Pet_DifferentColorsTips_C:OnBtnCloseTipsClick")
end

function UMG_Pet_DifferentColorsTips_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif Animation == self:GetAnimByIndex(1) then
    self:LoadAnimation(1)
  elseif Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Pet_DifferentColorsTips_C:OnPcClose()
  self:OnBtnCloseTipsClick()
end

return UMG_Pet_DifferentColorsTips_C
