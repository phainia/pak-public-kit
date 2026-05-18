local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_TeamBattle_PetTips_C = _G.NRCPanelBase:Extend("UMG_TeamBattle_PetTips_C")

function UMG_TeamBattle_PetTips_C:OnActive(petData, isDisableDesc)
  self.isDisableDesc = isDisableDesc
  self:SetPetInfo(petData)
end

function UMG_TeamBattle_PetTips_C:OnDeactive()
end

function UMG_TeamBattle_PetTips_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnCloseBtnClicked)
end

function UMG_TeamBattle_PetTips_C:OnRemoveEventListener()
end

function UMG_TeamBattle_PetTips_C:OnConstruct()
  self:OnAddEventListener()
  self.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self.isDisableDesc = nil
end

function UMG_TeamBattle_PetTips_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_TeamBattle_PetTips_C:SetPetInfo(petData, hasPetGid)
  self.petData = petData
  self.CanvasPanel_130:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Line1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Line_1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CurIcon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.LVCanvas:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if self:IsAnimationPlaying(self.reload_A) or not self:IsAnimationPlaying(self.reload_B) then
  end
  local petGid = 0
  if hasPetGid then
    petGid = hasPetGid
    self.HPBar:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AttrList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if petData then
      petGid = petData.gid
    end
    self.HPBar:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AttrList:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if petData then
    local curHP = 0
    local maxHP = 0
    if petData.attribute_new_info then
      local type = _G.ProtoEnum.AttributeType
      local addi_attr = petData.attribute_new_info.addi_attr_data
      if addi_attr then
        curHP = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_HPCUR)
        maxHP = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_HPMAX)
        self:SetHP(curHP / maxHP)
        self.hpText:SetText(string.format("%d/%d", curHP, maxHP))
      end
    end
    self.CurIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:updatePetGender(petData.gender)
    self.NameTxt:SetText(petData.name)
    self.LvTxt:SetText(petData.level)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    local skillId, lock = self:GetPetFeatrueSkillId(petBaseConf)
    if lock then
      self.Lock:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
    self:SetBloodPulseIcon(petData)
    local PetLevel = PetUtils.GetCatchHardInfo(petData)
    self.CatchHardLv:InitGridView(PetLevel)
    self.TxtNeng:SetText(string.format("%d/%d", petData.energy, petBaseConf.max_energy))
    self:SetTypes(BattleUtils.GetPetDefaultTypes(petData.base_conf_id))
    self:InitFeatures(skillId, lock)
    self:InitSkillList()
    local attrList = {}
    local attrInfo = petData.attribute_info
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_HPMAX,
      arrowType = _G.Enum.AttributeType.AT_HPMAX_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_HPMAX),
      attrInfo = attrInfo.hp,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_1
    })
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_SPEED,
      arrowType = _G.Enum.AttributeType.AT_SPEED_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEED),
      attrInfo = attrInfo.speed,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_2
    })
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_PHYATK,
      arrowType = _G.Enum.AttributeType.AT_PHYATK_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_PHYATK),
      attrInfo = attrInfo.attack,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_3
    })
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_SPEATK,
      arrowType = _G.Enum.AttributeType.AT_SPEATK_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEATK),
      attrInfo = attrInfo.special_attack,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_4
    })
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_PHYDEF,
      arrowType = _G.Enum.AttributeType.AT_PHYDEF_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_PHYDEF),
      attrInfo = attrInfo.defense,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_5
    })
    table.insert(attrList, {
      attrType = _G.Enum.AttributeType.AT_SPEDEF,
      arrowType = _G.Enum.AttributeType.AT_SPEDEF_PERCENT,
      addiAttrInfo = PetUtils.GetPetAdditionalByType(petData, Enum.AttributeType.AT_SPEDEF),
      attrInfo = attrInfo.special_defense,
      petConfId = petData.base_conf_id,
      petNature = petData.nature,
      name = LuaText.umg_teambattle_pettips_6
    })
    self:InitAttrList(attrList)
  end
end

function UMG_TeamBattle_PetTips_C:SetHP(percent)
  if percent < 0.2 then
    self.HpBarPink:SetPercent(percent)
    self.HpBarYellow:SetPercent(0)
    self.HpBarGreen:SetPercent(0)
  elseif percent < 0.5 then
    self.HpBarPink:SetPercent(0)
    self.HpBarYellow:SetPercent(percent)
    self.HpBarGreen:SetPercent(0)
  else
    self.HpBarPink:SetPercent(0)
    self.HpBarYellow:SetPercent(0)
    self.HpBarGreen:SetPercent(percent)
  end
end

function UMG_TeamBattle_PetTips_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_TeamBattle_PetTips_C:GetPetFeatrueSkillId(baseConf)
  local skillId = baseConf.pet_feature
  if 0 ~= skillId then
    return skillId, false
  else
    local evolution_pet_id = baseConf.evolution_pet_id[1]
    if nil == evolution_pet_id then
      return
    end
    local evoPetbaseCfg = _G.DataConfigManager:GetPetbaseConf(evolution_pet_id)
    if evolution_pet_id then
      skillId = evoPetbaseCfg.pet_feature
      if 0 ~= skillId then
        return skillId, true
      end
    end
  end
  return 0
end

function UMG_TeamBattle_PetTips_C:SetBloodPulseIcon(_petData)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(_petData.blood_id)
  if PetBloodConf then
    self.icon_1:SetPath(PetBloodConf.icon)
  end
end

function UMG_TeamBattle_PetTips_C:SetTypes(Types)
  local attr1 = Types[1]
  local attr2 = Types[2]
  local attr3 = Types[3]
  local petTypes = {
    attr1,
    attr2,
    attr3
  }
  Log.Debug("petTypes: ", table.tostring(petTypes))
  if petTypes then
    for i = 1, 3 do
      local petType = petTypes[i]
      if petType and petType > 0 then
        local conf = _G.DataConfigManager:GetTypeDictionary(petType)
        if i <= #petTypes and petType > 1 and conf then
          self["PetTypePanel" .. i]:SetVisibility(UE4.ESlateVisibility.Visible)
          self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Visible)
          local iconPath = conf.type_icon
          self["Attr" .. i]:SetPath(iconPath)
        else
          Log.Warning("petType\233\133\141\231\189\174\230\137\190\228\184\141\229\136\176, \229\142\187\231\156\139\231\156\139\233\133\141\231\189\174\232\161\168\229\144\167 ", petTypes)
        end
      else
        self["PetTypePanel" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_TeamBattle_PetTips_C:InitFeatures(skillId, lock)
  if 0 == skillId or nil == skillId then
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local skillCfg = _G.DataConfigManager:GetSkillConf(skillId)
  if skillCfg then
    if skillCfg.icon then
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skillCfg.icon, _G.UIIconPath.SkillIconPath))
    else
      self.SkillIconBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.SkillNameTxt:SetText(skillCfg.name)
    local des = ""
    if lock then
      des = LuaText.umg_teambattle_pettips_7
    else
      des = skillCfg.desc
    end
    if self.isDisableDesc then
      if lock then
        self.NRCTextDes:SetText(des)
      else
        self.NRCTextDes:SetText(UE4.UNRCStatics.ExtractDescIdKeywords(des))
      end
    else
      self.NRCTextDes:SetText(des)
    end
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.SizeBox_67:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TeamBattle_PetTips_C:InitSkillList()
  if not self.petData then
    return
  end
  local petEquipSkillList = self:GetPetEquipSkills(self.petData)
  self.SkillList:InitGridView(petEquipSkillList)
end

function UMG_TeamBattle_PetTips_C:GetPetEquipSkills(petData)
  local petEquipSkills = {}
  if petData then
    for i, skillData in ipairs(petData.skill.skill_data) do
      if skillData.is_equipped and 1 == skillData.type and skillData.pos > 0 and skillData.pos <= 4 then
        petEquipSkills[skillData.pos] = skillData
      end
    end
  end
  return petEquipSkills
end

function UMG_TeamBattle_PetTips_C:InitAttrList(AttrList)
  self.AttrList:InitGridView(AttrList)
end

function UMG_TeamBattle_PetTips_C:OnCloseBtnClicked()
  self:OnClose()
end

function UMG_TeamBattle_PetTips_C:OnAnimFinished(anim)
  if anim == self.PanelOut then
  end
end

return UMG_TeamBattle_PetTips_C
