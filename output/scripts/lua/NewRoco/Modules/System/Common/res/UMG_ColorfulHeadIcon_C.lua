local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local UMG_ColorfulHeadIcon_C = _G.NRCPanelBase:Extend("UMG_ColorfulHeadIcon_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_ColorfulHeadIcon_C:OnConstruct()
  self.ParticleIndex = nil
  self.MatchIndex = nil
  self.isNightmareIconShieldMat = false
end

function UMG_ColorfulHeadIcon_C:OnDestruct()
end

function UMG_ColorfulHeadIcon_C:OnActive()
end

function UMG_ColorfulHeadIcon_C:OnDeactive()
end

function UMG_ColorfulHeadIcon_C:OnAddEventListener()
end

function UMG_ColorfulHeadIcon_C:SetIconPathAndMaterial(PetBaseId, mutation_type, glass_info, useBigIcon, inParam)
  self.glassInfo = glass_info
  local path = UMG_ColorfulHeadIcon_C.GetIconPath(PetBaseId, mutation_type, useBigIcon)
  if path then
    local flag = self:SetPetIconPathAndMaterial(path, mutation_type, glass_info, inParam)
    return flag, path
  end
end

function UMG_ColorfulHeadIcon_C.GetIconPath(PetBaseId, mutation_type, useBigIcon)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetBaseId)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      local path = useBigIcon and modelConf.big_icon or modelConf.icon
      if mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
        path = useBigIcon and modelConf.big_shiny_icon or modelConf.shiny_icon
      end
      return path
    end
  end
  return nil
end

function UMG_ColorfulHeadIcon_C:SetIconPath(IconPath)
  if IconPath then
    self.headIcon:SwitchToSetBrushFromMaterialInstanceMode(false)
    self.headIcon:SetPath(IconPath)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_ColorfulHeadIcon_C:SetPetIconPathAndMaterial(IconPath, mutation_type, glass_info, inParam)
  self.glassInfo = glass_info
  if mutation_type and PetUtils.CheckIsCHAOS(mutation_type) then
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self:NeedLoadNightMareMaterial(IconPath, mutation_type, glass_info, inParam) then
      self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
      return true
    end
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Visible)
    self.headIcon_Nightmare:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.headIcon_Nightmare:SetPathWithCallBack(IconPath, {
      self,
      self.LoadImageEnd
    })
    return true
  elseif mutation_type and glass_info and PetUtils.CheckIsHiddenShiningGlass(mutation_type, glass_info) then
    self.HeadIcon_HideDazzlingColors:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.iconPath = IconPath
    self:SetHiddenShinePetIcon()
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Visible)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return true
  elseif mutation_type and PetUtils.CheckIsShiningGlass(mutation_type) then
    self.shineHeadIcon:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.shineHeadIcon:SetPathWithCallBack(IconPath, {
      self,
      self.SetShinePetIcon
    })
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return true
  elseif mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    self.headIcon:SwitchToSetBrushFromMaterialInstanceMode(false)
    self.headIcon:SetPathWithCallBack(IconPath, {
      self,
      self.LoadImageEnd
    })
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return false
  elseif mutation_type and glass_info and PetUtils.CheckIsHiddenGlass(mutation_type, glass_info) then
    self.HeadIcon_HideDazzlingColors:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.iconPath = IconPath
    self:SetHiddenShinePetIcon()
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Visible)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return true
  elseif mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.shineHeadIcon:SwitchToSetBrushFromMaterialInstanceMode(true)
    self.shineHeadIcon:SetPathWithCallBack(IconPath, {
      self,
      self.SetShinePetIcon
    })
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return true
  else
    self.headIcon:SwitchToSetBrushFromMaterialInstanceMode(false)
    self.headIcon:SetPathWithCallBack(IconPath, {
      self,
      self.LoadImageEnd
    })
    self.headIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.shineHeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.headIcon_Nightmare:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HeadIcon_HideDazzlingColors:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return false
  end
end

function UMG_ColorfulHeadIcon_C:loadBigIconResSuccess(req, asset)
  if self and UE4.UObject.IsValid(self) then
    local material = self.shineHeadIcon:GetDynamicMaterial()
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
    if self.nestIcon then
      self.nestIcon:OnImageLoadFinished()
      self.nestIcon = nil
    end
  end
end

function UMG_ColorfulHeadIcon_C:loadBigIconResFailed(req, asset)
  Log.Error("\231\130\171\229\189\169\229\164\180\229\131\143\230\155\180\230\141\162\230\157\144\232\180\168\231\154\132\232\180\180\229\155\190\228\184\173\231\154\132\229\155\190\231\137\135\229\164\177\232\180\165\239\188\140\232\175\183\230\159\165\231\156\139\232\181\132\230\186\144\230\152\175\229\144\166\229\173\152\229\156\168")
end

function UMG_ColorfulHeadIcon_C:SetShinePetIcon()
  self:LoadImageEnd()
  if self.glassInfo and self.glassInfo.glass_value then
    local shineId = self.glassInfo.glass_value
    self.ParticleIndex = nil
    self.MatchIndex = nil
    if shineId then
      self.ParticleIndex, shineId = PetUtils.GetShineDataValue(shineId, 20)
      self.MatchIndex, shineId = PetUtils.GetShineDataValue(shineId, 0)
      local particleConf = _G.DataConfigManager:GetParticleRandomConf(self.ParticleIndex)
      if particleConf and particleConf.headicon_particle_res then
        local res = particleConf.headicon_particle_res
        self:LoadPanelRes(res, 255, self.loadBigIconResSuccess, self.loadBigIconResFailed)
      end
    end
  end
end

function UMG_ColorfulHeadIcon_C:SetHiddenShinePetIcon()
  local path = self:GetHiddenGlassMaterialPath()
  if "" ~= path then
    local function OnSuccess(caller, request, asset)
      if caller and caller.iconPath and asset then
        caller.HeadIcon_HideDazzlingColors.MaterialInstance = asset
        
        caller.HeadIcon_HideDazzlingColors:SetBrushFromMaterial(asset)
        caller.HeadIcon_HideDazzlingColors:SetPath(caller.iconPath)
      end
      if self.nestIcon then
        self.nestIcon:OnImageLoadFinished()
        self.nestIcon = nil
      end
    end
    
    local function OnFail(request, msg)
      if self and self.HeadIcon_HideDazzlingColors then
        self.HeadIcon_HideDazzlingColors:SetPath(self.iconPath)
      end
    end
    
    _G.NRCResourceManager:LoadResAsync(self, path, 255, -1, OnSuccess, OnFail)
  else
    self.HeadIcon_HideDazzlingColors:SetPath(self.iconPath)
  end
end

function UMG_ColorfulHeadIcon_C:GetHiddenGlassMaterialPath()
  if self.glassInfo and self.glassInfo.glass_value then
    local HiddenGlassConf = _G.DataConfigManager:GetHiddenGlassConf(self.glassInfo.glass_value)
    if HiddenGlassConf and HiddenGlassConf.headicon_mat_path then
      return HiddenGlassConf.headicon_mat_path
    end
  end
  return ""
end

function UMG_ColorfulHeadIcon_C:SetBookHeadPetIconPathAndMaterial(IconPath, mutation_type, glass_info, bookHead)
  self.bookHead = bookHead
  self:SetPetIconPathAndMaterial(IconPath, mutation_type, glass_info)
end

function UMG_ColorfulHeadIcon_C:SetNestIconPathAndMaterial(IconPath, mutation_type, glass_info, nestIcon)
  self.nestIcon = nestIcon
  self:SetPetIconPathAndMaterial(IconPath, mutation_type, glass_info)
end

function UMG_ColorfulHeadIcon_C:LoadImageEnd()
  if self.bookHead then
    self.bookHead:LoadImageEnd()
    self.bookHead = nil
  elseif self.nestIcon then
    self.nestIcon:OnImageLoadFinished()
    self.nestIcon = nil
  end
end

function UMG_ColorfulHeadIcon_C:PrepareUIParam(insidePetInfo)
  local uiParam = {}
  uiParam.hasNightMareShield = PetUtils.CheckHasNightMareShield(insidePetInfo)
  if uiParam.hasNightMareShield == nil then
    uiParam.hasNightMareShield = false
  end
  return uiParam
end

function UMG_ColorfulHeadIcon_C:NeedLoadNightMareMaterial(IconPath, mutation_type, glass_info, inParam)
  if inParam and inParam.hasNightMareShield ~= nil then
    if self.isLoadingNightmareIconMat then
      if self.asyncData and self.asyncData.inParam then
        if inParam.hasNightMareShield ~= self.asyncData.inParam.hasNightMareShield then
          self:UnLoadRes(self.asyncData.matReq)
        else
          return true
        end
      end
    elseif self.isNightmareIconShieldMat == inParam.hasNightMareShield then
      return false
    end
    self.asyncData = {}
    self.asyncData.IconPath = IconPath
    self.asyncData.mutation_type = mutation_type
    self.asyncData.glass_info = glass_info
    self.asyncData.inParam = inParam
    if inParam.hasNightMareShield then
      self.asyncData.matReq = self:LoadPanelRes(BattleConst.NightMareShieldHeadIconMatPath, 255, self.OnLoadNightMareShieldIconMatSuc, self.OnLoadNightMareShieldIconMatFail, nil)
    else
      self.asyncData.matReq = self:LoadPanelRes(BattleConst.NightMareHeadIconMatPath, 255, self.OnLoadNightMareShieldIconMatSuc, self.OnLoadNightMareShieldIconMatFail, nil)
    end
    self.isLoadingNightmareIconMat = true
    return true
  end
end

function UMG_ColorfulHeadIcon_C:OnLoadNightMareShieldIconMatSuc(_, asset)
  self.isLoadingNightmareIconMat = false
  if asset and self.headIcon_Nightmare and self.asyncData then
    if self.asyncData.inParam then
      self.isNightmareIconShieldMat = self.asyncData.inParam.hasNightMareShield
    end
    self.headIcon_Nightmare.MaterialInstance = asset
    self:SetPetIconPathAndMaterial(self.asyncData.IconPath, self.asyncData.mutation_type, self.asyncData.glass_info, self.asyncData.inParam)
    self.asyncData = nil
  end
end

function UMG_ColorfulHeadIcon_C:OnLoadNightMareShieldIconMatFail()
  self.isLoadingNightmareIconMat = false
  self.asyncData = nil
end

return UMG_ColorfulHeadIcon_C
