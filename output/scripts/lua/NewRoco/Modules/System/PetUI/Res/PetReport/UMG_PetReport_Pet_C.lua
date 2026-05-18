local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetReport_Pet_C = _G.NRCPanelBase:Extend("UMG_PetReport_Pet_C")

function UMG_PetReport_Pet_C:OnActive()
end

function UMG_PetReport_Pet_C:OnDeactive()
end

function UMG_PetReport_Pet_C:OnAddEventListener()
end

function UMG_PetReport_Pet_C:SetUILocation()
  self.UILocation = self.CanvasPanel_25.Slot:GetPosition()
end

function UMG_PetReport_Pet_C:SetPetIcon(bSkipShowAnim, baseConfID, mutation_type, glass_info)
  self:ReleaseResLoadRequest()
  self.PetImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Fx_icon_light2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.materialPath = ""
  self.iconPath = ""
  self.glass_info = glass_info
  self.bSkipShowAnim = bSkipShowAnim
  self.FinishSetPath = false
  self.FinishSetMaterial = false
  if baseConfID then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseConfID)
    if petBaseConf then
      self.petBaseConf = petBaseConf
      if mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
        self.iconPath = petBaseConf.JL_shiny_res
      else
        self.iconPath = petBaseConf.JL_res
      end
    end
  end
  self:SetIconScaleAndOffset()
  if mutation_type and PetUtils.CheckIsCHAOS(mutation_type) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_InnerLineCloseUp.MI_UI_InnerLineCloseUp'"
  elseif mutation_type and glass_info and PetUtils.CheckIsHiddenShiningGlass(mutation_type, glass_info) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.materialPath = self:GetHiddenGlassMaterialPath()
  elseif mutation_type and PetUtils.CheckIsShiningGlass(mutation_type) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_PetDazzleCloseUp.MI_UI_PetDazzleCloseUp'"
  elseif mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(false)
  elseif mutation_type and glass_info and PetUtils.CheckIsHiddenGlass(mutation_type, glass_info) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.materialPath = self:GetHiddenGlassMaterialPath()
  elseif mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_PetDazzleCloseUp.MI_UI_PetDazzleCloseUp'"
  else
    self.PetImage:SwitchToSetBrushFromMaterialInstanceMode(false)
  end
  self:SetPetIconInner()
end

function UMG_PetReport_Pet_C:SetPetIconInner()
  if self.materialPath ~= "" then
    self:LoadPanelRes(self.materialPath, 255, self.OnLoadIconMaterialSucceed, self.OnLoadIconMaterialFail, nil)
  else
    self.PetImage:SetPathWithCallBack(self.iconPath, {
      self,
      self.OnFinishSetPath
    })
    self:LoadPanelRes(self.iconPath, 255, self.LoadIconPathSucceed, nil, nil)
  end
end

function UMG_PetReport_Pet_C:OnFinishSetPath()
  self.PetImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.FinishSetPath = true
  if self.FinishSetMaterial and not self.bSkipShowAnim then
    self:PlayAnimation(self.Show)
  end
end

function UMG_PetReport_Pet_C:OnLoadIconMaterialSucceed(_, asset)
  if self.iconPath and asset then
    self.PetImage.MaterialInstance = asset
    self.PetImage:SetBrushFromMaterial(asset)
    self.PetImage:SetPathWithCallBack(self.iconPath, {
      self,
      self.OnFinishSetPath
    })
    self:LoadPanelRes(self.iconPath, 255, self.LoadIconPathSucceed, nil, nil)
    if self.glass_info and self.glass_info.glass_type == ProtoEnum.GlassType.GT_COMMON then
      self:SetCommonGlass()
    end
  end
end

function UMG_PetReport_Pet_C:OnLoadIconMaterialFail()
  if self.iconPath ~= "" then
    self.PetImage:SetPathWithCallBack(self.iconPath, {
      self,
      self.OnFinishSetPath
    })
    self:LoadPanelRes(self.iconPath, 255, self.LoadIconPathSucceed, nil, nil)
  end
end

function UMG_PetReport_Pet_C:LoadIconPathSucceed(_, asset)
  self.Fx_icon_light2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local Material = self.Fx_icon_light2:GetDynamicMaterial()
  if Material then
    Material:SetTextureParameterValue("Maintex", asset)
  end
  self.FinishSetMaterial = true
  if self.FinishSetPath and not self.bSkipShowAnim then
    self:PlayAnimation(self.Show)
  end
end

function UMG_PetReport_Pet_C:SetIconScaleAndOffset()
  if self.petBaseConf then
    local _scale = self.petBaseConf.report_res_ui_percentage and self.petBaseConf.report_res_ui_percentage > 0 and self.petBaseConf.report_res_ui_percentage or 1
    if 1 ~= self.petBaseConf.report_res_horizontal_flip_data then
      self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(_scale, _scale))
    else
      self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(-_scale, _scale))
    end
    local _offsetConf
    local NewUILocation = UE4.FVector2D(self.UILocation.X, self.UILocation.Y)
    self.CanvasPanel_25.Slot:GetPosition()
    if self.petBaseConf.report_res_offset and next(self.petBaseConf.report_res_offset) then
      _offsetConf = self.petBaseConf.report_res_offset
      _offsetConf = UE4.FVector2D(_offsetConf[1] or 0, _offsetConf[2] or 0)
    else
      _offsetConf = UE4.FVector2D(0, 0)
    end
    NewUILocation.X = NewUILocation.X + _offsetConf.X
    NewUILocation.Y = NewUILocation.Y + _offsetConf.Y
    self.CanvasPanel_25.Slot:SetPosition(NewUILocation)
  end
end

function UMG_PetReport_Pet_C:SetCommonGlass()
  if self.glass_info and self.glass_info.glass_value then
    local shineId = self.glass_info.glass_value
    self.ParticleIndex = nil
    self.MatchIndex = nil
    if shineId then
      self.ParticleIndex, shineId = PetUtils.GetShineDataValue(shineId, 20)
      self.MatchIndex, shineId = PetUtils.GetShineDataValue(shineId, 0)
      local particleConf = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex)
      if particleConf and particleConf.headicon_particle_res then
        local res = particleConf.headicon_particle_res
        self:LoadPanelRes(res, 255, self.loadGlassResSuccess)
      end
    end
  end
end

function UMG_PetReport_Pet_C:loadGlassResSuccess(req, asset)
  local material = self.PetImage:GetDynamicMaterial()
  if material then
    material:SetTextureParameterValue("StarTex", asset)
  end
  local matchConf = _G.DataConfigManager:GetColorRandomConf(self.MatchIndex)
  if matchConf and matchConf.mat_color_1 then
    local color1 = matchConf.mat_color_1
    if material then
      material:SetVectorParameterValue("Color01", UE4.FLinearColor(color1[1], color1[2], color1[3], color1[4]))
    end
  end
  if matchConf and matchConf.mat_color_2 then
    local color2 = matchConf.mat_color_2
    if material then
      material:SetVectorParameterValue("Color02", UE4.FLinearColor(color2[1], color2[2], color2[3], color2[4]))
    end
  end
end

function UMG_PetReport_Pet_C:GetHiddenGlassMaterialPath()
  if self.glass_info and self.glass_info.glass_value then
    local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(self.glass_info.glass_value)
    if HiddenGlassConf and HiddenGlassConf.pet_art_mat_path then
      return HiddenGlassConf.pet_art_mat_path
    end
  end
  return ""
end

function UMG_PetReport_Pet_C:SetPetUIImageRevert(_flip, _Scale)
  if UE4.UNRCStatics.IsEditor() then
    local PetVisualParam = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetPetVisualParam, true)
    if 1 ~= _flip then
      self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(_Scale, _Scale))
    else
      self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(-_Scale, _Scale))
    end
    if PetVisualParam then
      PetVisualParam.res_horizontal_flip_data = _flip
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetPetVisualParam, PetVisualParam)
    end
  end
end

function UMG_PetReport_Pet_C:UpdateUIScaleAndOffset(_flip, _scale, _Offset, _CurModifyAxis)
  if 1 ~= _flip then
    self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(_scale, _scale))
  else
    self.CanvasPanel_25:SetRenderScale(UE4.FVector2D(-_scale, _scale))
  end
  local CurPetUILocation = self.CanvasPanel_25.Slot:GetPosition()
  local NewPetUILocation = CurPetUILocation
  if 1 == _CurModifyAxis then
    NewPetUILocation.X = _Offset.X
  elseif 2 == _CurModifyAxis then
    NewPetUILocation.Y = _Offset.Y
  elseif 0 == _CurModifyAxis then
    NewPetUILocation = _Offset
  end
  self.CanvasPanel_25.Slot:SetPosition(NewPetUILocation)
end

return UMG_PetReport_Pet_C
