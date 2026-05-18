local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ColorfulDyeing_Item_C = Base:Extend("UMG_ColorfulDyeing_Item_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_ColorfulDyeing_Item_C:OnConstruct()
end

function UMG_ColorfulDyeing_Item_C:OnDestruct()
end

function UMG_ColorfulDyeing_Item_C:OnItemUpdate(_data, datalist, index)
  self.glassInfo = _data.glassInfo
  self.itemID = _data.itemID
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.glassInfo.glass_type and self.glassInfo.glass_value then
    self.RedDot:SetupKey(461, {
      self.itemID,
      self.glassInfo.glass_type,
      self.glassInfo.glass_value
    })
    if self.glassInfo.glass_type == _G.Enum.GlassType.GT_HIDDEN then
      self:ShowHiddenGlassInfo()
    else
      self:ShowNormalGlassInfo()
    end
  else
    self.RedDot:SetupKey(0)
    self.Switcher:SetActiveWidgetIndex(2)
  end
end

function UMG_ColorfulDyeing_Item_C:ShowNormalGlassInfo()
  self.Switcher:SetActiveWidgetIndex(0)
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
    local particleBigIconRes = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex).particle_big_icon
    if particleBigIconRes then
      self.Image_Icon:SetPath(particleBigIconRes)
    end
  end
end

function UMG_ColorfulDyeing_Item_C:ShowHiddenGlassInfo()
  self.Switcher:SetActiveWidgetIndex(1)
  local path = self:GetHiddenGlassPic()
  if "" ~= path then
    self.Image_Icon_3:SetPath(path)
  end
end

function UMG_ColorfulDyeing_Item_C:GetHiddenGlassPic()
  if self.glassInfo then
    local HiddenGlassID = self.glassInfo.glass_value
    if HiddenGlassID then
      local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(HiddenGlassID)
      if HiddenGlassConf and HiddenGlassConf.glass_tips_pic then
        return HiddenGlassConf.glass_tips_pic
      end
    end
  end
  return ""
end

function UMG_ColorfulDyeing_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_ColorfulDyeing_Item_C:OnItemSelected")
    self:StopAnimation(self.Selected)
    self:StopAnimation(self.close)
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Selected)
    local itemConf = _G.DataConfigManager:GetFashionItemConf(self.itemID)
    local typeEnum
    if itemConf then
      typeEnum = itemConf.type
    end
    if self.glassInfo.glass_type and self.glassInfo.glass_value then
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetCurSelectedItemGlassMap, self.itemID, self.glassInfo)
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetCurTryOnItemInfo, typeEnum, self.itemID, nil, nil, true, nil, true, self.glassInfo)
    else
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetCurSelectedItemGlassMap, self.itemID, nil)
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetCurTryOnItemInfo, typeEnum, self.itemID, nil, nil, false, nil, true)
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetCurTryOnItemInfo, typeEnum, self.itemID, nil, nil, true, nil, true)
    end
  else
    self:StopAnimation(self.Selected)
    self:StopAnimation(self.close)
    self:PlayAnimation(self.close)
  end
end

function UMG_ColorfulDyeing_Item_C:OnAnimationFinished(Anim)
  if Anim == self.close then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ColorfulDyeing_Item_C:OnDeactive()
end

return UMG_ColorfulDyeing_Item_C
