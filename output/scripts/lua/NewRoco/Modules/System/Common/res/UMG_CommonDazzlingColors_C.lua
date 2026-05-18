local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_CommonDazzlingColors_C = _G.NRCPanelBase:Extend("UMG_CommonDazzlingColors_C")

function UMG_CommonDazzlingColors_C:OnActive()
end

function UMG_CommonDazzlingColors_C:OnDeactive()
  self.Button_DazzlingSeason.OnPressed:Remove(self, self.OnOpenIconTips)
  self.Button_DazzlingSeason.OnReleased:Remove(self, self.OnButton_DazzlingSeasonReleased)
end

function UMG_CommonDazzlingColors_C:OnAddEventListener()
end

function UMG_CommonDazzlingColors_C:InitUI(InPetData)
  self:SetPetData(InPetData)
  if not self.PetData then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.Button_DazzlingSeason.OnPressed:Remove(self, self.OnOpenIconTips)
  self.Button_DazzlingSeason.OnReleased:Remove(self, self.OnButton_DazzlingSeasonReleased)
  self.Button_DazzlingSeason.OnPressed:Add(self, self.OnOpenIconTips)
  self.Button_DazzlingSeason.OnReleased:Add(self, self.OnButton_DazzlingSeasonReleased)
  local name = ""
  local path = ""
  local needtoShow = true
  if PetUtils.CheckIsShiningChaos(self.PetData.mutation_type) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_5")
    path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_emengyis_png.img_emengyis_png'"
  elseif PetUtils.CheckIsCHAOS(self.PetData.mutation_type) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_2")
    path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_emeng_png.img_emeng_png'"
  elseif PetUtils.CheckIsHiddenShiningGlass(self.PetData.mutation_type, self.PetData.glass_info) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_4")
    path = self:GetHiddenGlassIcon(true)
  elseif PetUtils.CheckIsShiningGlass(self.PetData.mutation_type) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_4")
    path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_yisexuancai_png.img_yisexuancai_png'"
  elseif PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_1")
    path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_yisetubian_png.img_yisetubian_png'"
  elseif PetUtils.CheckIsHiddenGlass(self.PetData.mutation_type, self.PetData.glass_info) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_3")
    path = self:GetHiddenGlassIcon(false)
  elseif PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_3")
    path = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_bolitubian_png.img_bolitubian_png'"
  else
    needtoShow = false
  end
  if needtoShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SeasonColorsDazzling1:SetPath(path)
    if name and name.msg then
      self.Text_4:SetText(name.msg)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CommonDazzlingColors_C:SetPetData(InPetData)
  self.PetData = InPetData
end

function UMG_CommonDazzlingColors_C:GetHiddenGlassIcon(bShiningGlass)
  if self.PetData and self.PetData.glass_info then
    local HiddenGlassID = self.PetData.glass_info.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf then
        if bShiningGlass and HiddenGlassConf.yise_icon then
          return HiddenGlassConf.yise_icon
        elseif HiddenGlassConf.icon then
          return HiddenGlassConf.icon
        end
      end
    end
  end
  return ""
end

function UMG_CommonDazzlingColors_C:OnOpenIconTips()
  local islock = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetPetHatchingIsSelected)
  if islock then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").DAZZLING
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
  self:StopAllAnimations()
  self:PlayAnimation(self.Press)
end

function UMG_CommonDazzlingColors_C:OnButton_DazzlingSeasonReleased()
  self:StopAllAnimations()
  self:PlayAnimation(self.Up)
end

function UMG_CommonDazzlingColors_C:OnAnimationFinished(Animation)
  if Animation == self.Press then
    if PetUtils.CheckIsHiddenShiningGlass(self.PetData.mutation_type, self.PetData.glass_info) or PetUtils.CheckIsHiddenGlass(self.PetData.mutation_type, self.PetData.glass_info) or PetUtils.CheckIsShiningGlass(self.PetData.mutation_type) or PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenDazzlingTipsPanel, self.PetData)
    elseif PetUtils.CheckIsCHAOS(self.PetData.mutation_type) or PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenMutationTipsPanel, self.PetData)
    else
      local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").DAZZLING
      _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
    end
  end
end

return UMG_CommonDazzlingColors_C
