local UMG_PhotoSharing_C = _G.NRCViewBase:Extend("UMG_PhotoSharing_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_PhotoSharing_C:OnConstruct()
  self:SetChildViews(self.PetRadarInfo, self.UMG_PetRate, self.UMG_PetImage3D)
  self.uiItem = {}
  self.uiItem.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self.uiItem.skillIcons = {
    self.skillIcon1,
    self.skillIcon2,
    self.skillIcon3,
    self.skillIcon4
  }
  self.PetRadarInfo.detailedBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_PetImage3D:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PhotoSharing_C:OnActive()
end

function UMG_PhotoSharing_C:OnDeactive()
end

function UMG_PhotoSharing_C:OnAddEventListener()
end

function UMG_PhotoSharing_C:Show(petData)
  self.petData = petData
  self:ShowPetInfo()
  self:ShowPlayerInfo()
  self.PetRadarInfo:PlayAnimationIn()
end

function UMG_PhotoSharing_C:ShowPetInfo()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  self:updatePetNature(self.petData.nature)
  self:updatePetGender(self.petData.gender)
  self:updatePetTypeIcon(petBaseConf.unit_type)
  if self.PetRadarInfo and self.PetRadarInfo.updatePetInfo then
    self.PetRadarInfo:SetIsShowChangeValue(true)
    self.PetRadarInfo:updatePetInfo(self.petData, petBaseConf)
  else
    Log.Error("self.PetRadarInfo or self.PetRadarInfo.updatePetInfo Not Found")
  end
  if utf8.len(self.petData.name) ~= nil and utf8.len(self.petData.name) > _G.DataConfigManager:GetPetGlobalConfig("pet_name_num_max").num then
    self.petData.name = string.sub(self.petData.name, 1, string.len(self.petData.name) - 3)
  end
  if self.petData.name ~= "" then
    if self.petData.name ~= nil then
      self.textPetName:SetText(self.petData.name)
    else
      self.textPetName:SetText(petBaseConf.name)
    end
  else
    self.textPetName:SetText(petBaseConf.name)
  end
  local BallId = self.petData.ball_id
  if 0 == BallId then
    BallId = 100002
  end
  local CurIconPath = _G.DataConfigManager:GetBallConf(BallId).ball_tips_icon
  self.UMG_PetEvoTip.CurIcon:SetPath(CurIconPath)
  self.UMG_PetEvoTip.Image_evo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local specialityId = self.petData and self.petData.speciality_id
  if specialityId then
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(specialityId)
    if PetTalentConf then
      self.textPetNature_1:SetText(PetTalentConf.name)
    end
  end
  self:SetTalentRank()
  self:SetWeightAndStature()
  self:SetSpecialSign()
  self:ShowMedalIcon()
  self:ShowPetFeatureSkill()
  self:ShowNormalSkill()
  self:ShowPetModel()
  self:ShowPetLevel()
end

function UMG_PhotoSharing_C:updatePetNature(_nature)
  local petNatureConf = _G.DataConfigManager:GetNatureConf(_nature)
  if petNatureConf then
    self.textPetNature:SetText(petNatureConf.name or "")
  end
end

function UMG_PhotoSharing_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.uiItem.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PhotoSharing_C:updatePetTypeIcon(_dicTypes)
  local typeList = {}
  local BloodTypeList = {}
  for i, Type in ipairs(_dicTypes) do
    table.insert(typeList, Type)
  end
  self.Attr1:InitGridView(typeList)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.petData.blood_id)
  if PetBloodConf then
    table.insert(BloodTypeList, {
      Name = PetBloodConf.blood_name,
      Path = PetBloodConf.icon
    })
  end
  self.Attr:InitGridView(BloodTypeList)
end

function UMG_PhotoSharing_C:SetTalentRank()
  self.UMG_PetRate:SetText(self.petData)
end

function UMG_PhotoSharing_C:SetWeightAndStature()
  if not self.petData.weight or not self.petData.height then
    return
  end
  local WeightData = self.petData.weight * 0.001
  local num = self:GetPreciseDecimal(WeightData, 2)
  self.TextWeight:SetText(num)
  self.TextStature:SetText(string.format("%.2f", self.petData.height * 0.01))
end

function UMG_PhotoSharing_C:GetPreciseDecimal(num, n)
  if type(num) ~= "number" then
    return num
  end
  n = n or 0
  n = math.floor(n)
  if n < 0 then
    n = 0
  end
  local decimal = 10 ^ n
  local temp = math.floor(num * decimal)
  return temp / decimal
end

function UMG_PhotoSharing_C:SetSpecialSign()
  self.State_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if PetUtils.CheckIsShiningChaos(self.petData.mutation_type) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(6)
  elseif PetUtils.CheckIsCHAOS(self.petData.mutation_type) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(2)
  elseif PetUtils.CheckIsHiddenShiningGlass(self.petData.mutation_type, self.petData.glass_info) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(5)
    local path = self:GetHiddenGlassIcon(true)
    if "" ~= path then
      self.Nightmare_3:SetPath(path)
    end
  elseif PetUtils.CheckIsShiningGlass(self.petData.mutation_type) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(3)
  elseif PetMutationUtils.GetMutationValue(self.petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(1)
  elseif PetUtils.CheckIsHiddenGlass(self.petData.mutation_type, self.petData.glass_info) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(4)
    local path = self:GetHiddenGlassIcon(false)
    if "" ~= path then
      self.Nightmare_2:SetPath(path)
    end
  elseif PetMutationUtils.GetMutationValue(self.petData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State_1:SetActiveWidgetIndex(0)
  end
end

function UMG_PhotoSharing_C:ShowMedalIcon()
  local _, WearMedal = _G.DataModelMgr.PlayerDataModel:GetMedalListAndWearMedalByPetGid(self.petData.gid)
  if WearMedal then
    local medalConf = _G.DataConfigManager:GetMedalConf(WearMedal.conf_id)
    self.MedaIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MedaIcon:SetPath(medalConf.big_icon)
  else
    self.MedaIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PhotoSharing_C:ShowPetFeatureSkill()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  local skillId = petBaseConf.pet_feature
  if 0 == skillId then
    local evolution_pet_id = petBaseConf.evolution_pet_id[1]
    local evoPetbaseCfg = _G.DataConfigManager:GetPetbaseConf(evolution_pet_id)
    if evolution_pet_id then
      skillId = evoPetbaseCfg.pet_feature
    end
  end
  if 0 == skillId then
    return
  end
  local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
  self.SkillIcon:SetPath(skillCfg.icon)
  self.SkillNameTxt:SetText(skillCfg.name)
end

function UMG_PhotoSharing_C:ShowNormalSkill()
  local skillList = {}
  local equipSkills = PetUtils.GetPetEquipSkills(self.petData)
  for i = 1, #equipSkills do
    if equipSkills[i] then
      table.insert(skillList, equipSkills[i])
    end
  end
  self.Skill:InitGridView(skillList)
end

function UMG_PhotoSharing_C:ShowPlayerInfo()
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  self.Grade:SetText(playerInfo.name)
  self.Grade_1:SetText("UID:" .. playerInfo.uin)
  local cardInfo = playerInfo.additional_data.card_brief_info
  if cardInfo then
    local cardIconConf = _G.DataConfigManager:GetCardIconConf(cardInfo.card_icon_selected)
    if cardIconConf then
      local avatarPath = cardIconConf.icon_resource_path
      avatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", avatarPath, avatarPath)
      self.HeadPortrait:SetPath(avatarPath)
    end
  end
end

function UMG_PhotoSharing_C:ShowPetModel()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  self.UMG_PetImage3D:OnActive(petBaseConf, "PetInfoMain")
  local scale, offset, rotate
  local scaleConf = _G.DataConfigManager:GetGlobalConfig("share_image_zoom")
  if scaleConf and scaleConf.str then
    scale = tonumber(scaleConf.str)
  end
  local offsetConf = _G.DataConfigManager:GetGlobalConfig("share_image_move")
  if offsetConf and offsetConf.numList then
    offset = UE4.FVector(offsetConf.numList[1], offsetConf.numList[2], offsetConf.numList[3])
  end
  local rotateConf = _G.DataConfigManager:GetGlobalConfig("share_image_rotation")
  if rotateConf and rotateConf.numList then
    rotate = UE4.FRotator(rotateConf.numList[1], rotateConf.numList[2], rotateConf.numList[3])
  end
  self.UMG_PetImage3D:InitPetShareData(scale, offset, rotate)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  if modelConf then
    self.UMG_PetImage3D.PetBaseConf = petBaseConf
    self.UMG_PetImage3D:SetPath(modelConf.path, nil, nil, self.petData, false)
    self.UMG_PetImage3D.isEgg = false
  end
end

function UMG_PhotoSharing_C:ShowPetLevel()
  self.Level:SetText(self.petData.level)
end

function UMG_PhotoSharing_C:GetHiddenGlassIcon(bShiningGlass)
  if self.petData and self.petData.glass_info then
    local HiddenGlassID = self.petData.glass_info.glass_value
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

return UMG_PhotoSharing_C
