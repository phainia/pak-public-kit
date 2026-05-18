local UMG_Common_Dazzling_C = _G.NRCViewBase:Extend("UMG_Common_Dazzling_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_Common_Dazzling_C:OnActive()
end

function UMG_Common_Dazzling_C:UpdateState(isGlassItem, wearingGlass)
  self.glassInfo = wearingGlass
  if not isGlassItem then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.glassInfo then
      self.Switcher_Dazzling:SetActiveWidgetIndex(0)
    else
      self:SetGlassIcon()
    end
  end
end

function UMG_Common_Dazzling_C:SetGlassIcon()
  self.Switcher_Dazzling:SetActiveWidgetIndex(1)
  if self.glassInfo.glass_type == _G.Enum.GlassType.GT_HIDDEN then
    self:ShowHiddenGlassInfo()
  else
    self:ShowNormalGlassInfo()
  end
end

function UMG_Common_Dazzling_C:ShowNormalGlassInfo()
  self.Switcher_Dazzling:SetActiveWidgetIndex(1)
  local shineColorId = self.glassInfo.glass_value
  self.ParticleIndex, shineColorId = PetUtils.GetShineDataValue(shineColorId, 20)
  self.MatchIndex, shineColorId = PetUtils.GetShineDataValue(shineColorId, 0)
  self.NRCImage_A:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCImage_B:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Image_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.MatchIndex and 0 ~= self.MatchIndex then
    local matchConf = _G.DataConfigManager:GetColorRandomConf(self.MatchIndex)
    if not matchConf then
      return
    end
    if matchConf.ui_color_1 then
      local color1 = matchConf.ui_color_1 .. "FF"
      self.NRCImage_A:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
    end
    if matchConf.ui_color_2 then
      local color2 = matchConf.ui_color_2 .. "FF"
      self.NRCImage_B:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
    end
  end
  if self.ParticleIndex and 0 ~= self.ParticleIndex then
    local particleSmallIconRes = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex).particle_small_icon
    if particleSmallIconRes then
      self.Image_Icon:SetPath(particleSmallIconRes)
    end
  end
end

function UMG_Common_Dazzling_C:ShowHiddenGlassInfo()
  self.Switcher_Dazzling:SetActiveWidgetIndex(2)
  local path = self:GetHiddenGlassPic()
  if "" ~= path then
    self.Image_Icon_3:SetPath(path)
  end
end

function UMG_Common_Dazzling_C:GetHiddenGlassPic()
  if self.glassInfo then
    local HiddenGlassID = self.glassInfo.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf and HiddenGlassConf.particle_small_icon then
        return HiddenGlassConf.particle_small_icon
      end
    end
  end
  return ""
end

function UMG_Common_Dazzling_C:OnDeactive()
end

function UMG_Common_Dazzling_C:OnAddEventListener()
end

return UMG_Common_Dazzling_C
