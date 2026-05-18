local PetUtils = require("NewRoco.Utils.PetUtils")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MutationOption_C = Base:Extend("UMG_MutationOption_C")

function UMG_MutationOption_C:OnConstruct()
end

function UMG_MutationOption_C:OnDestruct()
end

function UMG_MutationOption_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Switcher:SetActiveWidgetIndex(0)
  self:SetIsEnabled(true)
  if self.data then
    if self.data.IsNull then
      local color = UE4.UNRCStatics.HexToLinearColor("#000000FF")
      self.NRCImage_A:SetColorAndOpacity(color)
      self.NRCImage_B:SetColorAndOpacity(color)
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetIsEnabled(false)
      return
    end
    local color1 = ""
    local color2 = ""
    local effect_icon = ""
    local isHiddenGlass = false
    if self.data.isChaos then
      color1 = self.data.colorA
      color2 = self.data.colorB
      effect_icon = self.data.particle
    elseif self.data.info.glassType == ProtoEnum.GlassType.GT_COMMON then
      if self.data.info.colorInfo and self.data.info.colorInfo.colorId and self.data.info.colorInfo.particle then
        local colorConf = _G.DataConfigManager:GetColorRandomConf(self.data.info.colorInfo.colorId)
        if colorConf then
          color1 = colorConf.ui_color_1
          color2 = colorConf.ui_color_2
        end
        if 0 ~= self.data.info.colorInfo.particle then
          self.Image_Icon:SetVisibility(UE4.ESlateVisibility.Visible)
          effect_icon = _G.DataConfigManager:GetParticleRandomConf(self.data.info.colorInfo.particle).particle_big_icon
        else
          self.Image_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    elseif self.data.info.glassType == ProtoEnum.GlassType.GT_HIDDEN then
      isHiddenGlass = true
      if self.data.info.hiddenGlassValue then
        local path = self:GetHiddenGlassTipsPic(self.data.info.hiddenGlassValue)
        if "" ~= path then
          self.Image_Icon_3:SetPath(path)
        end
        self.NRCImage_A:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.NRCImage_B:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
        self.Switcher:SetActiveWidgetIndex(2)
      end
    end
    if not isHiddenGlass then
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Image_Icon:SetPath(effect_icon)
      self.NRCImage_A:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCImage_B:SetVisibility(UE4.ESlateVisibility.Visible)
      self.NRCImage_A:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color1))
      self.NRCImage_B:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(color2))
    end
  end
end

function UMG_MutationOption_C:GetChaos(mutation)
  local mutation_type = _G.Enum.MutationDiffType.MDT_NONE
  if PetMutationUtils.GetMutationValue(mutation, _G.Enum.MutationDiffType.MDT_CHAOS) then
    mutation_type = _G.Enum.MutationDiffType.MDT_CHAOS
  elseif PetMutationUtils.GetMutationValue(mutation, _G.Enum.MutationDiffType.MDT_CHAOS_TWO) then
    mutation_type = _G.Enum.MutationDiffType.MDT_CHAOS_TWO
  elseif PetMutationUtils.GetMutationValue(mutation, _G.Enum.MutationDiffType.MDT_CHAOS_THREE) then
    mutation_type = _G.Enum.MutationDiffType.MDT_CHAOS_THREE
  end
  return mutation_type
end

function UMG_MutationOption_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    if self.data == nil or self.data.IsNull then
      return
    end
    local isChaos = self.data.isChaos or false
    if isChaos then
      local glass_info = {glass_type = 0, glass_value = 0}
      _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnChangCurBookPreviewWorld, glass_info, self.data.mutationInfo)
    else
      local glass_info = PetMutationUtils.EncodeShineColorInfo(self.data.info)
      local mutation_type = _G.Enum.MutationDiffType.MDT_NONE
      _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnChangCurBookPreviewWorld, glass_info, self.data.mutationInfo)
    end
    self:PlayAnimation(self.Selected)
  else
    self:PlayAnimation(self.close)
  end
end

function UMG_MutationOption_C:OnDeactive()
end

function UMG_MutationOption_C:OnClickNRCButton_16()
end

function UMG_MutationOption_C:GetHiddenGlassTipsPic(glass_value)
  if glass_value and glass_value > 0 then
    local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(glass_value)
    if HiddenGlassConf and HiddenGlassConf.glass_tips_pic then
      return HiddenGlassConf.glass_tips_pic
    end
  end
  return ""
end

return UMG_MutationOption_C
