local Enum = require("Data.Config.Enum")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
require("Common.UE4Extension")
local ChaosExpressionNatureId = 22
local PetMutationUtils = {}
local colorIdBitNum = 20
local particleBitNum = 12

function PetMutationUtils.MakeEmptyShineInfo()
  return {colorId = 1, particle = 1}
end

function PetMutationUtils.MakeEmptyGlassInfoDetails()
  return {
    colorInfo = PetMutationUtils.MakeEmptyShineInfo(),
    glassType = ProtoEnum.GlassType.GT_COMMON,
    hiddenGlassValue = 0
  }
end

function PetMutationUtils.EncodeShineColorInfo(glassInfoDetails)
  local glassValue = 0
  local glassType = ProtoEnum.GlassType.GT_COMMON
  if glassInfoDetails then
    if glassInfoDetails.glassType == ProtoEnum.GlassType.GT_COMMON then
      if glassInfoDetails.colorInfo ~= nil then
        glassValue = glassInfoDetails.colorInfo.colorId + (glassInfoDetails.colorInfo.particle << colorIdBitNum)
        glassType = ProtoEnum.GlassType.GT_COMMON
      end
    elseif glassInfoDetails.glassType == ProtoEnum.GlassType.GT_HIDDEN then
      glassValue = glassInfoDetails.hiddenGlassValue
      glassType = ProtoEnum.GlassType.GT_HIDDEN
    end
  end
  local glassInfo = {glass_type = glassType, glass_value = glassValue}
  return glassInfo
end

function PetMutationUtils.DecodeShineColorId(glass_info)
  local glassInfoDetails = PetMutationUtils.MakeEmptyGlassInfoDetails()
  if glass_info and glass_info.glass_type and glass_info.glass_value then
    if glass_info.glass_type == ProtoEnum.GlassType.GT_COMMON then
      glassInfoDetails.glassType = ProtoEnum.GlassType.GT_COMMON
      glassInfoDetails.colorInfo.particle = glass_info.glass_value >> colorIdBitNum
      glassInfoDetails.colorInfo.colorId = glass_info.glass_value - (glassInfoDetails.colorInfo.particle << colorIdBitNum)
    elseif glass_info.glass_type == ProtoEnum.GlassType.GT_HIDDEN then
      glassInfoDetails.glassType = ProtoEnum.GlassType.GT_HIDDEN
      glassInfoDetails.hiddenGlassValue = glass_info.glass_value
    end
  end
  return glassInfoDetails
end

function PetMutationUtils.GetShineColor(rgba)
  if nil == rgba or #rgba < 3 then
    return nil
  end
  local color = UE.FLinearColor(0, 0, 0, 1)
  color.R = rgba[1]
  color.G = rgba[2]
  color.B = rgba[3]
  return color
end

function PetMutationUtils.GetPreloadList()
  local list = {}
  
  local function getAssetPath(longPath)
    if not longPath or type(longPath) ~= "string" then
      return longPath
    end
    local startQuote, endQuote = string.find(longPath, "'([^']+)'")
    if startQuote and endQuote then
      local extractedPath = string.sub(longPath, startQuote + 1, endQuote - 1)
      return extractedPath
    end
    return longPath
  end
  
  local particleRandomConfigs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PARTICLE_RANDOM_CONF)
  if particleRandomConfigs then
    for _, conf in pairs(particleRandomConfigs) do
      list[PetMutationUtils.GetGeneralParticleKey(conf.id)] = getAssetPath(conf.particle_res)
    end
  end
  local hiddenGlassConfigs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.HIDDEN_GLASS_CONF)
  if hiddenGlassConfigs then
    for _, conf in pairs(hiddenGlassConfigs) do
      if conf.main_tex and conf.main_tex ~= "" then
        list[PetMutationUtils.GetHiddenParticleKey(conf.id, "MainTex")] = getAssetPath(conf.main_tex)
      end
      if conf.particle and "" ~= conf.particle then
        list[PetMutationUtils.GetHiddenParticleKey(conf.id, "Star")] = getAssetPath(conf.particle)
      end
    end
  end
  list[PetMutationUtils.GetNormalEggKeyStarStickTex()] = "Texture2D'/Game/ArtRes/BP/Texture/PetGlassyStar/Tex_EggGlassyStar_001.Tex_EggGlassyStar_001'"
  list[PetMutationUtils.GetNormalEggKeyAdditionalMat()] = "MaterialInstanceConstant'/Game/ArtRes/Material/Characters/PetBase/MaterialInstance/Special/MI_P_EggGlassy_Outline.MI_P_EggGlassy_Outline'"
  return list
end

function PetMutationUtils.GetGeneralParticleKey(id)
  return string.format("PetMutationParticleGeneral-%d", id)
end

function PetMutationUtils.GetHiddenParticleKey(id, property)
  return string.format("PetMutationParticleHidden-%d-%s", id, property)
end

function PetMutationUtils.GetNormalEggKeyStarStickTex()
  return string.format("PetMutationShine-NormalEgg-StarStick")
end

function PetMutationUtils.GetNormalEggKeyAdditionalMat()
  return string.format("PetMutationShine-NormalEgg-AdditionalMat")
end

function PetMutationUtils.GetShineParticle(key)
  if not key then
    Log.Warning("PetMutationUtils.GetShineParticle key is nil", key)
    return
  end
  local particle = _G.NRCBigWorldPreloader:Get(key)
  if not particle then
    Log.Warning("PetMutationUtils.GetShineParticle particle is nil", key)
  end
  return particle
end

function PetMutationUtils.GetNpcColorMutatationModelCfg(npcCfg)
  local modelCfg
  if npcCfg.traverse_data_type and #npcCfg.traverse_data_param > 0 and npcCfg.traverse_data_type == Enum.Traverse_Data_Type.TDT_PETBASE then
    local petbaseId = npcCfg.traverse_data_param[1]
    modelCfg = PetMutationUtils.GetutatationModelCfgByPetbaseId(petbaseId)
  end
  modelCfg = modelCfg or _G.DataConfigManager:GetModelConf(npcCfg.model_conf)
  return modelCfg
end

function PetMutationUtils.GetutatationModelCfgByPetbaseId(petbaseId)
  local modelCfg
  local petbaseCfg = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  if petbaseCfg then
    modelCfg = _G.DataConfigManager:GetModelConf(petbaseCfg.shining_model_conf)
  end
  return modelCfg
end

function PetMutationUtils.GetNpcHeightModelScale(npcCfg, height)
  local heightModelScale = 1
  if npcCfg.traverse_data_type and #npcCfg.traverse_data_param > 0 and npcCfg.traverse_data_type == Enum.Traverse_Data_Type.TDT_PETBASE then
    local petbaseId = npcCfg.traverse_data_param[1]
    heightModelScale = PetMutationUtils.GetHeightModelScale(petbaseId, height)
  end
  return heightModelScale
end

local _height_low_scale_percent, _height_scale_space

function PetMutationUtils.GetHeightModelScale(petbaseId, height)
  if nil == height then
    return 1
  end
  local petbaseCfg = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  if not petbaseCfg then
    return 1
  end
  local height_low = petbaseCfg.height_low
  local height_high = petbaseCfg.height_high
  if height < height_low then
    height = height_low
  end
  if height_high < height then
    height = height_high
  end
  local height_ratio = 1
  local height_diff = height_high - height_low
  if height_diff >= 0.01 then
    height_ratio = (height - height_low) / height_diff
  end
  if not _height_low_scale_percent then
    _height_low_scale_percent = _G.DataConfigManager:GetPetGlobalConfig("height_low_scale_percent").num / 10000
  end
  if not _height_scale_space then
    _height_scale_space = _G.DataConfigManager:GetPetGlobalConfig("height_scale_space").num / 10000
  end
  local scale = _height_low_scale_percent + _height_scale_space * height_ratio
  if scale > 20 then
    Log.Error("zgx GetHeightModelScale \229\188\130\229\184\184\239\188\129\239\188\129\239\188\129", scale)
    return 20
  else
    return scale
  end
end

function PetMutationUtils.GetHeightModelScaleByPetData(petData)
  if not petData then
    return 1
  end
  local petbaseId = petData.base_conf_id
  local height = petData.height
  local heightModelScale = PetMutationUtils.GetHeightModelScale(petbaseId, height)
  return heightModelScale
end

function PetMutationUtils.NotifyMutationComplete(character)
  if not character then
    return
  end
  if character.sceneCharacter and character.sceneCharacter.SendEvent then
    character.sceneCharacter:SendEvent(NPCModuleEvent.OnNpcMutationComplete, character)
  else
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnNpcMutationComplete, character)
  end
end

function PetMutationUtils.GetDisplayMutationData(card, is_show_shining)
  is_show_shining = is_show_shining or false
  local mutationPetData = {
    mutation_type = card.petInfo.battle_common_pet_info.mutation_type,
    nature = card.petInfo.battle_common_pet_info.nature,
    glass_info = card.petInfo.battle_common_pet_info.glass_info,
    base_conf_id = card.petInfo.battle_common_pet_info.base_conf_id
  }
  if card.petState:GetNightmare() or card.petState:GetNightmareOne() then
    mutationPetData.mutation_type = mutationPetData.mutation_type & ~_G.Enum.MutationDiffType.MDT_CHAOS
    mutationPetData.mutation_type = mutationPetData.mutation_type & ~_G.Enum.MutationDiffType.MDT_CHAOS_TWO
    mutationPetData.mutation_type = mutationPetData.mutation_type & ~_G.Enum.MutationDiffType.MDT_CHAOS_THREE
    if not is_show_shining then
      mutationPetData.mutation_type = mutationPetData.mutation_type & ~_G.Enum.MutationDiffType.MDT_SHINING
    end
  end
  return mutationPetData
end

function PetMutationUtils.GetMutationValue(mutation_type, type)
  return (mutation_type or 0) & type > 0
end

function PetMutationUtils.DoMutation(character, petData)
  if not petData or not character then
    return
  end
  if not UE.UObject.IsValid(character) then
    return
  end
  local mutation_type = petData.mutation_type
  local nature = petData.nature
  local bAsyncLoaded = false
  if mutation_type then
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
      PetMutationUtils.SetColorDiffMutation(character)
      bAsyncLoaded = true
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      PetMutationUtils.SetGlassyDiffMutation(character, petData)
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS) then
      PetMutationUtils.SetNightmareFirstMutation(character)
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS_TWO) then
      PetMutationUtils.SetNightmareSecondMutation(character)
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS_THREE) then
      PetMutationUtils.SetNightmareByIDMask(character)
    end
  end
  if not bAsyncLoaded then
    PetMutationUtils.NotifyMutationComplete(character)
  end
  if nature then
    local finalNature = PetMutationUtils.GetFinalNature(nature, mutation_type)
    local Value = PetMutationUtils.GetOverrideExpression(finalNature)
    character.OverrideExpression = Value
    local Mesh = character.Mesh
    local MatComp = character.RocoMaterial
    if Mesh and MatComp then
      MatComp:SetOverrideNature(finalNature)
      MatComp:UpdateOverrideNature(Mesh, finalNature)
    end
  end
end

function PetMutationUtils.DoMutationForTest(character, MutationDiffType)
  if not MutationDiffType or not character then
    return
  end
  if MutationDiffType then
    if PetMutationUtils.GetMutationValue(MutationDiffType, _G.Enum.MutationDiffType.MDT_SHINING) then
      character:SetColorDiffMutation(UE.EPetMaterialDifferenceType.ColorDiff)
    end
    if PetMutationUtils.GetMutationValue(MutationDiffType, _G.Enum.MutationDiffType.MDT_GLASS) then
      character:SetGlassyDiffMutation()
    end
    if PetMutationUtils.GetMutationValue(MutationDiffType, _G.Enum.MutationDiffType.MDT_CHAOS) then
      character:SetNightmare1Mutation()
    end
    if PetMutationUtils.GetMutationValue(MutationDiffType, _G.Enum.MutationDiffType.MDT_CHAOS_TWO) then
      character:SetNightmare2Mutation()
    end
  end
end

function PetMutationUtils.DoMutationSpecific(character, diffType)
  if not character then
    return
  end
  diffType = diffType or UE.EPetMaterialDifferenceType.Default
  PetMutationUtils.SetColorDiffMutation(character, diffType)
end

function PetMutationUtils.GetFinalNature(nature, diff)
  if PetMutationUtils.GetMutationValue(diff, _G.Enum.MutationDiffType.MDT_CHAOS) or PetMutationUtils.GetMutationValue(diff, _G.Enum.MutationDiffType.MDT_CHAOS_TWO) or PetMutationUtils.GetMutationValue(diff, _G.Enum.MutationDiffType.MDT_CHAOS_THREE) then
    return ChaosExpressionNatureId
  end
  return nature
end

function PetMutationUtils.GetOverrideExpression(NatureID)
  if not NatureID or 0 == NatureID then
    return 100
  end
  local nature = _G.DataConfigManager:GetNatureConf(NatureID)
  if nature then
    return math.max(nature.relative_emotion, 100)
  end
  return 100
end

function PetMutationUtils.GetMatSuffix(object)
  local name = ""
  if type(object) == "string" then
    name = object
  else
    name = UE.UKismetSystemLibrary.GetObjectName(object)
  end
  local nameSet = string.split(name, "_")
  if #nameSet <= 0 then
    return nil
  end
  return nameSet[#nameSet]
end

function PetMutationUtils.GetMaterialsSuffixTable(character)
  local materialsSuffix = {}
  if not UE4.UObject.IsValid(character) then
    return materialsSuffix
  end
  local mesh = character.mesh
  if nil == mesh then
    return materialsSuffix
  end
  local materials
  if mesh.GetSoftSkeletalMeshMaterials then
    materials = mesh:GetSoftSkeletalMeshMaterials()
  else
    materials = mesh:GetMaterials()
  end
  for idx, mat in tpairs(materials) do
    local suffix = PetMutationUtils.GetMatSuffix(mat)
    if nil ~= suffix then
      materialsSuffix[idx] = suffix
    end
  end
  return materialsSuffix
end

function PetMutationUtils.PrepareMutationAssets(character, petData)
  if not petData or not character then
    return
  end
  local mutation_type = petData.mutation_type
  if mutation_type and PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    local MaterialMap = character.DiffMaterials
    local originMaterialsSuffix
    local defaultMaterialList = MaterialMap:Find(UE.EPetMaterialDifferenceType.Default)
    if defaultMaterialList and defaultMaterialList.Materials and defaultMaterialList.Materials:Num() > 0 then
      originMaterialsSuffix = {}
      for idx, softMaterial in tpairs(defaultMaterialList.Materials) do
        local materialPath = UE4.UNRCStatics.GetSoftObjPath(softMaterial)
        local suffix = PetMutationUtils.GetMatSuffix(materialPath)
        if nil ~= suffix then
          originMaterialsSuffix[idx] = suffix
        end
      end
    end
    local colorDiffMaterialList = MaterialMap:Find(UE.EPetMaterialDifferenceType.ColorDiff)
    if colorDiffMaterialList then
      if nil == originMaterialsSuffix then
        Log.Debug("PetMutationUtils.PrepareMutationAssets originMaterialsSuffix still nil", UE4.UKismetSystemLibrary.GetDisplayName(character))
        originMaterialsSuffix = PetMutationUtils.GetMaterialsSuffixTable(character)
      end
      local materialsPaths = UE4.TArray("")
      for _, _ in pairs(originMaterialsSuffix) do
        materialsPaths:Add("")
      end
      for _, softMaterial in tpairs(colorDiffMaterialList.Materials) do
        local materialPath = UE4.UNRCStatics.GetSoftObjPath(softMaterial)
        local materialSuffix = PetMutationUtils.GetMatSuffix(materialPath)
        for idx, suffix in pairs(originMaterialsSuffix) do
          if materialSuffix == suffix then
            materialsPaths[idx] = materialPath
            break
          end
        end
      end
      character.mesh:SetMaterialsToLoad(materialsPaths)
    end
    local fxListColorDiff = character.SelfFxListColorDiff
    if fxListColorDiff and fxListColorDiff:Num() > 0 then
      character.SelfFxList = fxListColorDiff
    end
  end
end

function PetMutationUtils.GetMaterialParamsAll(mesh, idx)
  if not UE4.UObject.IsValid(mesh) then
    return nil
  end
  local result = {}
  local mat = mesh:GetMaterial(idx)
  if not UE4.UObject.IsValid(mat) then
    return nil
  end
  result.SelfParam = PetMutationUtils.GetMaterialRecord(mat)
  result.AdditionalParam = {}
  for additionalIdx, additionalMaterial in tpairs(mat.AdditionalMaterials) do
    local record = PetMutationUtils.GetMaterialRecord(additionalMaterial)
    if nil ~= record then
      result.AdditionalParam[additionalIdx] = record
    end
  end
  return result
end

function PetMutationUtils.GetMaterialRecord(mat)
  if not mat then
    return nil
  end
  local record = {}
  if mat.DynamicSwitchParameters then
    record.SwitchParam = {}
    for _, param in tpairs(mat.DynamicSwitchParameters) do
      record.SwitchParam[param.ParameterInfo] = param.Value
    end
  end
  if mat.ScalarParameterValues then
    record.FloatParam = {}
    for _, param in tpairs(mat.ScalarParameterValues) do
      record.FloatParam[param.ParameterInfo] = param.ParameterValue
    end
  end
  if mat.VectorParameterValues then
    record.VectorParam = {}
    for _, param in tpairs(mat.VectorParameterValues) do
      record.VectorParam[param.ParameterInfo] = param.ParameterValue
    end
  end
  if mat.TextureParameterValues then
    record.TextureParam = {}
    for _, param in tpairs(mat.TextureParameterValues) do
      record.TextureParam[param.ParameterInfo] = param.ParameterValue
    end
  end
  return record
end

function PetMutationUtils.ApplyMaterialParamsAll(mesh, mat, params)
  if not params then
    return
  end
  PetMutationUtils.ApplyMaterialRecord(mesh, mat, params.SelfParam)
  if params.AdditionalParam then
    for idx, additionalMaterial in tpairs(mat.AdditionalMaterials) do
      local record = params.AdditionalParam[idx]
      if nil ~= record then
        PetMutationUtils.ApplyMaterialRecord(mesh, additionalMaterial, record)
      end
    end
  end
end

function PetMutationUtils.ApplyMaterialRecord(mesh, mat, record)
  if not mat or not record then
    return
  end
  if record.SwitchParam and mat.SetSwitchParameterValueByInfo then
    for info, val in pairs(record.SwitchParam) do
      mat:SetSwitchParameterValueByInfo(info, val, mesh, false)
    end
  end
  if record.FloatParam and mat.SetScalarParameterValueByInfo then
    for info, val in pairs(record.FloatParam) do
      mat:SetScalarParameterValueByInfo(info, val)
    end
  end
  if record.VectorParam and mat.SetVectorParameterValueByInfo then
    for info, val in pairs(record.VectorParam) do
      mat:SetVectorParameterValueByInfo(info, val)
    end
  end
  if record.TextureParam and mat.SetTextureParameterValueByInfo then
    for info, val in pairs(record.TextureParam) do
      mat:SetTextureParameterValueByInfo(info, val)
    end
  end
end

function PetMutationUtils.SetColorDiffMutation(character, diffType)
  if not UE4.UObject.IsValid(character) then
    return
  end
  if not character.RocoMaterial then
    Log.Warning("character.RocoMaterial is invalid", UE4.UKismetStringLibrary.Conv_ObjectToString(character))
    return
  end
  if character.mesh.GetMaterialResources then
    local colorDiffMaterials = character.mesh:GetMaterialResources()
    if colorDiffMaterials:Num() > 0 then
      PetMutationUtils.NotifyMutationComplete(character)
      return
    end
  end
  Log.Warning("PetMutationUtils.SetColorDiffMutation not prepare", character, diffType)
  local MaterialMap = character.DiffMaterials
  if nil == diffType then
    diffType = UE.EPetMaterialDifferenceType.ColorDiff
  end
  local mutationMaterials = MaterialMap:Find(diffType)
  if mutationMaterials then
    local totalMaterialNums = mutationMaterials.Materials:Num()
    local completedMaterialNum = 0
    
    local function onMaterialComplete()
      completedMaterialNum = completedMaterialNum + 1
      if completedMaterialNum >= totalMaterialNums then
        PetMutationUtils.NotifyMutationComplete(character)
      end
    end
    
    local originMaterialsSuffix = PetMutationUtils.GetMaterialsSuffixTable(character)
    
    local function onLoadMaterialSucceed(caller, req, asset)
      PetMutationUtils.ApplyColorDiffMaterial(character, originMaterialsSuffix, asset)
      onMaterialComplete()
    end
    
    local function onLoadMaterialFailed(caller, req, msg)
      Log.Warning("PetMutationUtils.SetColorDiffMutation onLoadMaterialFailed!", UE4.UKismetSystemLibrary.GetDisplayName(character), req.assetPath, msg)
      onMaterialComplete()
    end
    
    for _, softColorDiffMat in tpairs(mutationMaterials.Materials) do
      _G.NRCResourceManager:LoadResAsync(character, UE4.UNRCStatics.GetSoftObjPath(softColorDiffMat), PriorityEnum.Active_World_NPC_Mutation, 10, onLoadMaterialSucceed, onLoadMaterialFailed)
    end
  end
end

function PetMutationUtils.ApplyColorDiffMaterial(character, originMaterialsSuffix, colorDiffMat)
  if UE4.UObject.IsValid(colorDiffMat) then
    local colorDiffMatSuffix = PetMutationUtils.GetMatSuffix(colorDiffMat)
    for originIdx, originMatSuffix in pairs(originMaterialsSuffix) do
      if colorDiffMatSuffix == originMatSuffix then
        local realOriginIdx = originIdx - 1
        if character and UE4.UObject.IsValid(character) and character.RocoMaterial and UE4.UObject.IsValid(character.RocoMaterial) then
          local params = PetMutationUtils.GetMaterialParamsAll(character.mesh, realOriginIdx)
          local newMat = character.RocoMaterial:PermanentModifyMaterialByIndexSingleMesh(colorDiffMat, realOriginIdx, character.mesh)
          PetMutationUtils.ApplyMaterialParamsAll(character.mesh, newMat, params)
        end
        break
      end
    end
  end
end

function PetMutationUtils.SetGlassyDiffMutation(character, petData, isEgg)
  if not UE4.UObject.IsValid(character) then
    return
  end
  if not petData then
    return
  end
  local glass_info = petData.glass_info
  if petData.isNormalEgg then
    local bNotExplicitGlassyEgg = false
    if not glass_info then
      bNotExplicitGlassyEgg = true
    elseif glass_info.glass_type == _G.ProtoEnum.GlassType.GT_NULL and 0 == glass_info.glass_value then
      bNotExplicitGlassyEgg = true
    end
    if bNotExplicitGlassyEgg then
      PetMutationUtils.SetGlassyDiffMutationForNormalEgg(character, petData)
      return
    end
  end
  if not glass_info then
    Log.Debug("PetMutationUtils.SetGlassyDiffMutation no glass_info", petData.base_conf_id)
    return
  end
  if glass_info.glass_type == _G.ProtoEnum.GlassType.GT_NULL then
    Log.Debug("PetMutationUtils.SetGlassyDiffMutation no glass", glass_info.glass_value)
    return
  end
  
  local function processMaterial(mat, mesh, idx, colorA, colorB, strength, particle)
    if not isEgg then
      mat:SetSwitchParameterValue("GlassySwitch", true, mesh, false)
      if nil ~= colorA then
        mat:SetVectorParameterValue("RedChannel", colorA)
      end
      if nil ~= colorB then
        mat:SetVectorParameterValue("GreenChannel", colorB)
      end
      if nil ~= strength then
        mat:SetScalarParameterValue("StarIntensity", strength)
      end
      if nil ~= particle then
        mat:SetTextureParameterValue("StarStickTex", particle)
      end
      mat:SetVectorParameterValue("MutationRimColor", UE.FLinearColor(0.6, 0.6, 0.6, 1))
      mat:SetVectorParameterValue("MutationSpecularParams", UE.FLinearColor(0.8, 0.3, 200, 0.2))
    else
      local GlassInfo = UE4.FMaterialParameterInfo()
      GlassInfo.Name = ""
      GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
      GlassInfo.Index = 1
      if nil ~= colorA then
        GlassInfo.Name = "RedChannel"
        mat:SetVectorParameterValueByInfo(GlassInfo, colorA)
      end
      if nil ~= colorB then
        GlassInfo.Name = "GreenChannel"
        mat:SetVectorParameterValueByInfo(GlassInfo, colorB)
      end
      if nil ~= strength then
        GlassInfo.Name = "StarIntensity"
        mat:SetScalarParameterValueByInfo(GlassInfo, strength)
      end
      if nil ~= particle then
        GlassInfo.Name = "StarStickTex"
        mat:SetTextureParameterValueByInfo(GlassInfo, particle)
      end
    end
  end
  
  local function processAdditionalMaterial(additionalMat, mesh, idx, colorA, colorB)
    additionalMat:SetSwitchParameterValue("GlassySwitch", true, mesh, false)
    if nil ~= colorA then
      additionalMat:SetVectorParameterValue("RedChannel", colorA)
    end
    if nil ~= colorB then
      additionalMat:SetVectorParameterValue("GreenChannel", colorB)
    end
  end
  
  local materialFunc, additionalFunc
  if glass_info.glass_type == _G.ProtoEnum.GlassType.GT_HIDDEN then
    local conf = _G.DataConfigManager:GetHiddenGlassConf(glass_info.glass_value, true)
    if conf then
      local colorA = PetMutationUtils.GetShineColor(conf.glass_color_1)
      local colorB = PetMutationUtils.GetShineColor(conf.glass_color_2)
      local bSeasonButNotCustomPet = false
      if conf.type == _G.ProtoEnum.HiddenGlassType.HGT_SEASON then
        if petData.base_conf_id and petData.base_conf_id == conf.season_pet then
          if not isEgg then
            local seasonSwitchName = "MutationSwitch"
            local seasonSwitchLayer = UE4.EMaterialParameterAssociation.LayerParameter
            
            function materialFunc(mat, mesh, idx)
              if mat.DynamicSwitchParameters then
                for _, param in tpairs(mat.DynamicSwitchParameters) do
                  local paramInfo = param.ParameterInfo
                  if paramInfo and paramInfo.Name == seasonSwitchName and paramInfo.Association == seasonSwitchLayer then
                    mat:SetSwitchParameterValueByInfo(paramInfo, true, mesh, false)
                    break
                  end
                end
              end
            end
            
            function additionalFunc(additionalMat, mesh, idx)
              processAdditionalMaterial(additionalMat, mesh, idx, colorA, colorB)
            end
          end
        else
          bSeasonButNotCustomPet = true
        end
      end
      if bSeasonButNotCustomPet or conf.type == _G.ProtoEnum.HiddenGlassType.HGT_RESIDENT then
        local strength = conf.star_intensity
        local particle
        if conf.particle then
          particle = PetMutationUtils.GetShineParticle(PetMutationUtils.GetHiddenParticleKey(conf.id, "Star"))
        end
        local mainTex
        if conf.main_tex then
          mainTex = PetMutationUtils.GetShineParticle(PetMutationUtils.GetHiddenParticleKey(conf.id, "MainTex"))
        end
        local scalarParams = {}
        if conf.Effect_Amount then
          scalarParams.NormalEffectAmount = conf.Effect_Amount
        end
        if conf.global_refraction then
          scalarParams.GlobalRefraction = conf.global_refraction
        end
        if conf.tex_flow_speed_x then
          scalarParams.MainTexFlowSpeedX = conf.tex_flow_speed_x
        end
        if conf.tex_flow_speed_y then
          scalarParams.MainTexFlowSpeedY = conf.tex_flow_speed_y
        end
        if conf.global_depth then
          scalarParams.GlobalDepth = conf.global_depth
        end
        local vectorParams = {}
        if conf.particle_color_1 then
          vectorParams.StickRandomColor01 = PetMutationUtils.GetShineColor(conf.particle_color_1)
        end
        if conf.particle_color_2 then
          vectorParams.StickRandomColor02 = PetMutationUtils.GetShineColor(conf.particle_color_2)
        end
        if conf.particle_color_3 then
          vectorParams.StickRandomColor03 = PetMutationUtils.GetShineColor(conf.particle_color_3)
        end
        if conf.particle_color_4 then
          vectorParams.StickRandomColor04 = PetMutationUtils.GetShineColor(conf.particle_color_4)
        end
        
        function materialFunc(mat, mesh, idx)
          processMaterial(mat, mesh, idx, colorA, colorB, strength, particle)
          for name, value in pairs(scalarParams) do
            if value then
              if not isEgg then
                mat:SetScalarParameterValue(name, value)
              else
                local GlassInfo = UE4.FMaterialParameterInfo()
                GlassInfo.Name = name
                GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
                GlassInfo.Index = 1
                mat:SetScalarParameterValueByInfo(GlassInfo, value)
              end
            end
          end
          for name, color in pairs(vectorParams) do
            if color then
              if not isEgg then
                mat:SetVectorParameterValue(name, color)
              else
                local GlassInfo = UE4.FMaterialParameterInfo()
                GlassInfo.Name = name
                GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
                GlassInfo.Index = 1
                mat:SetVectorParameterValueByInfo(GlassInfo, color)
              end
            end
          end
          if nil ~= mainTex then
            if not isEgg then
              mat:SetTextureParameterValue("MainTex", mainTex)
            else
              local GlassInfo = UE4.FMaterialParameterInfo()
              GlassInfo.Name = "MainTex"
              GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
              GlassInfo.Index = 1
              mat:SetTextureParameterValueByInfo(GlassInfo, mainTex)
            end
          end
        end
        
        function additionalFunc(additionalMat, mesh, idx)
          processAdditionalMaterial(additionalMat, mesh, idx, colorA, colorB)
        end
      end
    else
      Log.Warning("PetMutationUtils.SetGlassyDiffMutation hidden glass config not existed", glass_info.glass_type, glass_info.glass_value)
    end
  elseif glass_info.glass_type == _G.ProtoEnum.GlassType.GT_COMMON then
    local glassInfoDetails = PetMutationUtils.DecodeShineColorId(glass_info)
    local colorA, colorB, strength, particle
    if glassInfoDetails and glassInfoDetails.glassType == ProtoEnum.GlassType.GT_COMMON and glassInfoDetails.colorInfo then
      local conf = _G.DataConfigManager:GetColorRandomConf(glassInfoDetails.colorInfo.colorId)
      if nil ~= conf then
        colorA = PetMutationUtils.GetShineColor(conf.mat_color_1)
        colorB = PetMutationUtils.GetShineColor(conf.mat_color_2)
        strength = conf.shine_strength
      end
      local particleId = glassInfoDetails.colorInfo.particle
      particle = PetMutationUtils.GetShineParticle(PetMutationUtils.GetGeneralParticleKey(particleId))
    end
    
    function materialFunc(mat, mesh, idx)
      processMaterial(mat, mesh, idx, colorA, colorB, strength, particle)
    end
    
    function additionalFunc(additionalMat, mesh, idx)
      processAdditionalMaterial(additionalMat, mesh, idx, colorA, colorB)
    end
  end
  if nil == materialFunc or nil == additionalFunc then
    Log.Debug("PetMutationUtils.SetGlassyDiffMutation materialFunc or additionalFunc is nil")
    return
  end
  local suffixes = {"by"}
  for idx = 0, 9 do
    table.insert(suffixes, string.format("by%d", idx))
  end
  if isEgg then
    suffixes = {
      "RandomEgg_003"
    }
  end
  local mesh = character.mesh
  local rocoMaterial = character.RocoMaterial
  if not rocoMaterial or not UE4.UObject.IsValid(rocoMaterial) then
    Log.Warning("PetMutationUtils.SetGlassyDiffMutation rocoMaterial is nil", UE4.UKismetSystemLibrary.GetDisplayName(character))
    return
  end
  local materials
  if not petData.isNormalEgg then
    materials = rocoMaterial:GetMaterialsBySuffixesAsMID(mesh, suffixes)
  else
    materials = rocoMaterial:GetCurrentMaterialsAsMID(mesh)
  end
  if not materials then
    return
  end
  for idx, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      materialFunc(mat, mesh, idx)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalFunc(additionalMat, mesh, idx)
        end
      end
    end
  end
end

function PetMutationUtils.SetGlassyDiffMutationForNormalEgg(character, petData)
  local mesh = character.mesh
  local rocoMaterial = character.RocoMaterial
  if not rocoMaterial or not UE4.UObject.IsValid(rocoMaterial) then
    Log.Warning("PetMutationUtils.SetGlassyDiffMutationForNormalEgg rocoMaterial is nil", UE4.UKismetSystemLibrary.GetDisplayName(character))
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMID(mesh)
  if not materials then
    return
  end
  Log.Debug("PetMutationUtils.SetGlassyDiffMutationForNormalEgg", UE4.UKismetSystemLibrary.GetDisplayName(character))
  for idx, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetSwitchParameterValue("GlassySwitch", true, mesh, false)
      mat:SetScalarParameterValue("GlassyMainColorOpacity", 1.0)
      mat:SetScalarParameterValue("StarStickTiling", 2.0)
      local starStickTex = PetMutationUtils.GetShineParticle(PetMutationUtils.GetNormalEggKeyStarStickTex())
      if starStickTex then
        mat:SetTextureParameterValue("StarStickTex", starStickTex)
      end
      local additionalMat = PetMutationUtils.GetShineParticle(PetMutationUtils.GetNormalEggKeyAdditionalMat())
      if additionalMat then
        local matInstance = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(character, additionalMat)
        if matInstance then
          mat.AdditionalMaterials:Clear()
          mat.AdditionalMaterials:Add(matInstance)
        end
      end
    end
  end
end

function PetMutationUtils.GetNightmareParameterInfo()
  local nightmareParameterInfo = UE4.FMaterialParameterInfo()
  nightmareParameterInfo.Name = "\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156"
  nightmareParameterInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
  nightmareParameterInfo.Index = 0
  return nightmareParameterInfo
end

function PetMutationUtils.SetNightmareFirstMutation(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMID(mesh)
  for _, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetVectorParameterValue("MainColor", UE4.UNRCStatics.HexToLinearColor("9E50C5FF"))
      mat:SetScalarParameterValue("MainBright", 0.6)
      mat:SetVectorParameterValue("Rim LightColor", UE4.UNRCStatics.HexToLinearColor("FF3AF4FF"))
      mat:SetVectorParameterValue("Rim DarkColor", UE4.UNRCStatics.HexToLinearColor("E01EE5FF"))
      mat:SetScalarParameterValue("Offset Percent", -1.0)
      mat:SetScalarParameterValue("Rim Power", 0.5)
      mat:SetScalarParameterValue("Rim Soft Edge", 1.0)
      mat:SetScalarParameterValue("Rim Intensity", 10.0)
      mat:SetScalarParameterValueByInfo(PetMutationUtils.GetNightmareParameterInfo(), 1.0)
      mat:SetScalarParameterValue("OpenBlackMagicByIDMask", 0)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", true, mesh, false)
        end
      end
    end
  end
end

function PetMutationUtils.SetNightmareByIDMask(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMID(mesh)
  for _, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", true, mesh, false)
      mat:SetScalarParameterValueByInfo(PetMutationUtils.GetNightmareParameterInfo(), 1.0)
      mat:SetScalarParameterValue("OpenBlackMagicByIDMask", 1)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", true, mesh, false)
          additionalMat:SetScalarParameterValue("OpenBlackMagicByIDMask", 1)
        end
      end
    end
  end
end

function PetMutationUtils.SetNightmareSecondMutation(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMIDWithClear(mesh)
  for _, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", true, mesh, false)
      mat:SetScalarParameterValueByInfo(PetMutationUtils.GetNightmareParameterInfo(), 1.0)
      mat:SetScalarParameterValue("OpenBlackMagicByIDMask", 0)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", true, mesh, false)
          additionalMat:SetScalarParameterValue("OutlineWidth", 0.2)
        end
      end
    end
  end
end

function PetMutationUtils.RemoveNightmareFirstMutation(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  rocoMaterial:ClearMaterials()
end

function PetMutationUtils.RemoveNightmareSecondMutation(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMIDWithClear(mesh)
  for _, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", false, mesh, false)
      mat:SetScalarParameterValueByInfo(PetMutationUtils.GetNightmareParameterInfo(), 0.0)
      mat:SetScalarParameterValue("OpenBlackMagicByIDMask", 0)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", false, mesh, false)
        end
      end
    end
  end
end

function PetMutationUtils.RemoveNightmareByIDMask(character)
  local rocoMaterial = character.RocoMaterial
  local mesh = character.mesh
  if not UE4.UObject.IsValid(rocoMaterial) or not UE4.UObject.IsValid(mesh) then
    return
  end
  local materials = rocoMaterial:GetCurrentMaterialsAsMID(mesh)
  for _, mat in tpairs(materials) do
    if UE4.UObject.IsValid(mat) then
      mat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", false, mesh, false)
      mat:SetScalarParameterValueByInfo(PetMutationUtils.GetNightmareParameterInfo(), 0.0)
      mat:SetScalarParameterValue("OpenBlackMagicByIDMask", 0)
      for _, additionalMat in tpairs(mat.AdditionalMaterials) do
        if UE4.UObject.IsValid(additionalMat) then
          additionalMat:SetSwitchParameterValue("\229\188\128\229\144\175\233\187\145\233\173\148\230\179\149\230\149\136\230\158\156", false, mesh, false)
          additionalMat:SetScalarParameterValue("OpenBlackMagicByIDMask", 0)
        end
      end
    end
  end
end

function PetMutationUtils.TryRemoveNightMareMutation(character, oldPetData, newPetData)
  if not oldPetData or not newPetData then
    return
  end
  if newPetData.blood_id ~= Enum.PetBloodType.PBT_NIGHTMARE then
    local mutation_type = oldPetData.mutation_type
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS) then
      PetMutationUtils.RemoveNightmareFirstMutation(character)
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS_TWO) then
      PetMutationUtils.RemoveNightmareSecondMutation(character)
    end
    if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS_THREE) then
      PetMutationUtils.RemoveNightmareByIDMask(character)
    end
  end
end

function PetMutationUtils.DoPetEggMutation(egg, eggData)
  if egg and eggData then
    local mutation_type = eggData.mutation_type
    local glass_info = eggData.glass_info
    local normalEgg = false
    if eggData.random_egg_conf then
      local randomEggConf = _G.DataConfigManager:GetPetRandomEggConf(eggData.random_egg_conf)
      if randomEggConf then
        local materials
        if randomEggConf.model_mutation_mat then
          egg:ChangeMaterial(randomEggConf.model_mutation_mat)
          normalEgg = not egg:IsGlassyEgg(randomEggConf.model_mutation_mat)
          if not normalEgg then
            local suffixes = {
              "RandomEgg_003"
            }
            materials = egg.RocoMaterial:GetMaterialsBySuffixesAsMID(egg.mesh, suffixes)
          end
        end
        if mutation_type and glass_info then
          if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
            PetMutationUtils.SetGlassyDiffMutation(egg, eggData, true)
          elseif PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_CHAOS_THREE) and egg then
            egg:ChangeMaterial(randomEggConf.model_mutation_mat)
            normalEgg = true
            PetMutationUtils.SetNightmareByIDMask(egg)
          end
        end
        local markTexPath = randomEggConf.model_mark_tex
        if markTexPath and "" ~= markTexPath then
          local function onLoadGlassyParticleSucceed(caller, req, asset)
            if asset then
              local material = egg.mesh:GetMaterial(0)
              
              if UE4.UObject.IsValid(material) and not normalEgg then
                local GlassInfo = UE4.FMaterialParameterInfo()
                GlassInfo.Name = "RampTex"
                GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
                GlassInfo.Index = 2
                material:SetTextureParameterValueByInfo(GlassInfo, asset)
              end
              if materials and not glass_info and not mutation_type then
                for _, mat in tpairs(materials) do
                  if UE4.UObject.IsValid(mat) then
                    for _, additionalMat in tpairs(mat.AdditionalMaterials) do
                      if UE4.UObject.IsValid(additionalMat) then
                        local GlassInfo = UE4.FMaterialParameterInfo()
                        GlassInfo.Name = "RampTex"
                        GlassInfo.Association = UE4.EMaterialParameterAssociation.LayerParameter
                        GlassInfo.Index = 1
                        additionalMat:SetTextureParameterValueByInfo(GlassInfo, asset)
                        GlassInfo.Name = "OpenFlowColor"
                        additionalMat:SetScalarParameterValueByInfo(GlassInfo, 1)
                      end
                    end
                  end
                end
              end
            end
          end
          
          _G.NRCResourceManager:LoadResAsync(egg, markTexPath, PriorityEnum.Active_World_NPC_Mutation, 10, onLoadGlassyParticleSucceed)
        end
      end
    elseif PetMutationUtils.CheckIsCustomGlassEgg(eggData) then
      eggData.isNormalEgg = true
      PetMutationUtils.SetGlassyDiffMutation(egg, eggData, false)
    elseif PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
      eggData.isNormalEgg = true
      PetMutationUtils.SetGlassyDiffMutation(egg, eggData, false)
    end
  end
end

function PetMutationUtils.CheckIsCustomGlassEgg(eggData)
  local isCustomGlassEgg = false
  if not eggData then
    return isCustomGlassEgg
  end
  if not eggData.conf_id then
    return isCustomGlassEgg
  end
  local PetEggConf = _G.DataConfigManager:GetPetEggConf(eggData.conf_id)
  if PetEggConf and PetEggConf.precious_egg_type == _G.Enum.PreciousEggType.PET_CUSTOM_GLASS then
    isCustomGlassEgg = true
  end
  return isCustomGlassEgg
end

return PetMutationUtils
