local UMG_Pet_DazzlingTips_C = _G.NRCPanelBase:Extend("UMG_Pet_DazzlingTips_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")

function UMG_Pet_DazzlingTips_C:OnActive(petData)
  self.PetData = petData
  self.IsCanClose = true
  self:OnAddEventListener()
  self:ShowInfo()
  self:LoadAnimation(0)
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_Pet_DazzlingTips_C:OnActive")
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "EggIncubatePanel").DAZZLING
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "PetUIModule", "EggIncubatePanel", touchReasonType)
end

function UMG_Pet_DazzlingTips_C:OnDeactive()
end

function UMG_Pet_DazzlingTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnBtnCloseTipsClick)
end

function UMG_Pet_DazzlingTips_C:ShowInfo()
  if PetUtils.CheckIsHiddenShiningGlass(self.PetData.mutation_type, self.PetData.glass_info) or PetUtils.CheckIsHiddenGlass(self.PetData.mutation_type, self.PetData.glass_info) then
    self:ShowHiddenGlassInfo()
  else
    self:ShowNormalGlassInfo()
  end
  self:ShowIconType()
end

function UMG_Pet_DazzlingTips_C:OnBtnCloseTipsClick()
  if not self.IsCanClose then
    return
  end
  self.IsCanClose = false
  self:LoadAnimation(2)
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Pet_DazzlingTips_C:OnBtnCloseTipsClick")
end

function UMG_Pet_DazzlingTips_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif Animation == self:GetAnimByIndex(1) then
    self:LoadAnimation(1)
  elseif Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Pet_DazzlingTips_C:ShowNormalGlassInfo()
  self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  local shineColorId = self.PetData.glass_info.glass_value
  self.ParticleIndex, shineColorId = PetUtils.GetShineDataValue(shineColorId, 20)
  self.MatchIndex, shineColorId = PetUtils.GetShineDataValue(shineColorId, 0)
  self.ColourBg1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ColourBg2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ParticleBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.ParticleIndex and 0 ~= self.ParticleIndex then
    local particleIconRes = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex).particle_icon
    self.Particle:SetPath(particleIconRes)
  end
  if self.MatchIndex and 0 ~= self.MatchIndex then
    local matchConf = _G.DataConfigManager:GetColorRandomConf(self.MatchIndex)
    if not matchConf then
      return
    end
    if matchConf.ui_color_1 then
      local color1 = matchConf.ui_color_1 .. "FF"
      self.Colour1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
      self.ColourBg2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
    end
    if matchConf.ui_color_2 then
      local color2 = matchConf.ui_color_2 .. "FF"
      self.Colour2:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
      self.ColourBg1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
    end
  end
  if self.ParticleIndex and 0 ~= self.ParticleIndex then
    local particleBigIconRes = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex).particle_big_icon
    if particleBigIconRes then
      self.ParticleBg:SetPath(particleBigIconRes)
    else
      Log.Error("UMG_Pet_DazzlingTips_C:ShowInfo \229\164\167\229\155\190\230\160\135\232\181\132\230\186\144\231\188\186\229\164\177\239\188\129\239\188\129\239\188\129")
    end
  end
end

function UMG_Pet_DazzlingTips_C:ShowHiddenGlassInfo()
  self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  local preName, realName = self:GetHiddenGlassName()
  self.NameText_3:SetText(preName)
  self.NameText_4:SetText(realName)
  self.ColourBg1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ColourBg2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ParticleBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ColourBg1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFFFF"))
  local path = self:GetHiddenGlassTipsPic()
  if "" ~= path then
    self.ColourBg1:SetPath(path)
  end
end

function UMG_Pet_DazzlingTips_C:ShowIconType()
  local name
  if PetUtils.CheckIsHiddenShiningGlass(self.PetData.mutation_type, self.PetData.glass_info) then
    self.BloodPulse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BloodPulse2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local path = self:GetHiddenGlassIcon(true)
    if "" ~= path then
      self.BloodPulse:SetPath(path)
    end
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_4")
  elseif PetUtils.CheckIsHiddenGlass(self.PetData.mutation_type, self.PetData.glass_info) then
    self.BloodPulse2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BloodPulse:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local path = self:GetHiddenGlassIcon(false)
    if "" ~= path then
      self.BloodPulse2:SetPath(path)
    end
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_3")
  elseif PetUtils.CheckIsShiningGlass(self.PetData.mutation_type) then
    self.BloodPulse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BloodPulse2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BloodPulse:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_yisexuancai_png.img_yisexuancai_png'")
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_4")
  elseif PetMutationUtils.GetMutationValue(self.PetData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.BloodPulse2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BloodPulse:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BloodPulse2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_bolitubian_png.img_bolitubian_png'")
    name = _G.DataConfigManager:GetLocalizationConf("mutation_text_3")
  end
  if name and name.msg then
    self.NRCText_76:SetText(name.msg)
  end
end

function UMG_Pet_DazzlingTips_C:GetHiddenGlassName()
  if self.PetData and self.PetData.glass_info then
    local HiddenGlassID = self.PetData.glass_info.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf then
        local preName = ""
        local realName = ""
        if HiddenGlassConf.type == _G.Enum.HiddenGlassType.HGT_RESIDENT then
          preName = LuaText.mutation_explain_tips_5
        elseif HiddenGlassConf.active_season and 0 ~= HiddenGlassConf.active_season then
          local text = _G.DataConfigManager:GetLocalizationConf("mutation_explain_tips_3")
          if text and text.msg then
            preName = string.format(text.msg, HiddenGlassConf.active_season)
          end
        end
        if HiddenGlassConf.name then
          realName = HiddenGlassConf.name
        end
        return preName, realName
      end
    end
  end
  return "", ""
end

function UMG_Pet_DazzlingTips_C:GetHiddenGlassIcon(bShiningGlass)
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

function UMG_Pet_DazzlingTips_C:GetHiddenGlassTipsPic()
  if self.PetData and self.PetData.glass_info then
    local HiddenGlassID = self.PetData.glass_info.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf and HiddenGlassConf.glass_tips_pic then
        return HiddenGlassConf.glass_tips_pic
      end
    end
  end
  return ""
end

function UMG_Pet_DazzlingTips_C:OnPcClose()
  self:OnBtnCloseTipsClick()
end

return UMG_Pet_DazzlingTips_C
