local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_ChooseAlternativePetItem_C = Base:Extend("UMG_ChooseAlternativePetItem_C")

function UMG_ChooseAlternativePetItem_C:OnConstruct()
end

function UMG_ChooseAlternativePetItem_C:OnDestruct()
end

function UMG_ChooseAlternativePetItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  if _data.empty then
    self:UpdateEmptyUI()
  elseif self.data.gid and 0 ~= self.data.gid then
    self.type = 2
    self.petGID = self.data.gid
    self:UpdateUI2()
  else
    self.type = 1
    self.petID = self.data.base_conf_id
    self:UpdateUI()
  end
end

function UMG_ChooseAlternativePetItem_C:UpdateEmptyUI()
  self.CanvasPanel_198:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Empty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_ChooseAlternativePetItem_C:UpdateUI()
  self.petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petID)
  local petNatureConf = _G.DataConfigManager:GetNatureConf(self.data.nature)
  self.Name:SetText(self.petBaseConf.name)
  self.HeadIcon:SetIconPathAndMaterial(self.petID)
  self:updatePetTypeIcon(self.petBaseConf.unit_type)
  local texingID = self.petBaseConf.pet_feature
  local texingCfg = _G.DataConfigManager:GetSkillConf(texingID)
  if texingCfg then
    self.SkillIcon_1:SetPath(texingCfg.icon)
    self.SkillNameTxt_1:SetText(texingCfg.name)
  end
  self.PersonalityIndividualValue1:InitGridView(self.data.NatureDataList)
  local NatureDataList1 = {}
  local SharePetNatureConf = _G.DataConfigManager:GetNatureConf(self.data.nature)
  if not SharePetNatureConf then
    Log.Error("ShaerPetNatureConf is nil")
    return
  end
  local share_pos_effect = SharePetNatureConf.positive_effect
  local share_neg_effect = SharePetNatureConf.negative_effect
  if self.data.changed_nature_pos_attr_type and self.data.changed_nature_pos_attr_type > 0 then
    share_pos_effect = self:GetChangeAttrReqEnum(self.data.changed_nature_pos_attr_type)
  end
  if self.data.changed_nature_neg_attr_type and self.data.changed_nature_neg_attr_type > 0 then
    share_neg_effect = self:GetChangeAttrReqEnum(self.data.changed_nature_neg_attr_type)
  end
  table.insert(NatureDataList1, {
    share_pos_effect = share_pos_effect,
    share_neg_effect = share_neg_effect,
    natureName = SharePetNatureConf.name,
    type = 0
  })
  self.PersonalityIndividualValue:InitGridView(NatureDataList1)
  self.SkillList_1:InitGridView(self.data.skills)
end

function UMG_ChooseAlternativePetItem_C:GetChangeAttrReqEnum(attribute)
  if not attribute then
    return nil
  end
  if attribute == Enum.AttributeType.AT_HPMAX then
    return Enum.AttributeType.AT_HPMAX_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYATK then
    return Enum.AttributeType.AT_PHYATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEATK then
    return Enum.AttributeType.AT_SPEATK_PERCENT
  elseif attribute == Enum.AttributeType.AT_PHYDEF then
    return Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEDEF then
    return Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif attribute == Enum.AttributeType.AT_SPEED then
    return Enum.AttributeType.AT_SPEED_PERCENT
  end
end

function UMG_ChooseAlternativePetItem_C:GetNatureEffect(_effect)
  local attribute = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ATTRIBUTE_CONF):GetAllDatas()
  for i, v in ipairs(attribute) do
    if _effect == v.attribute then
      return v
    end
  end
end

function UMG_ChooseAlternativePetItem_C:updatePetTypeIcon(_dicTypes)
  local typeList = {}
  for i, Type in ipairs(_dicTypes) do
    table.insert(typeList, Type)
  end
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(self.data.blood_id or self.petDataInfo.blood_id)
  if PetBloodConf then
    table.insert(typeList, PetBloodConf.icon)
  end
  self.Attr:InitGridView(typeList)
end

function UMG_ChooseAlternativePetItem_C:OnItemSelected(_bSelected)
  if 2 == self.type then
    if _bSelected then
      _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ChooseAlternativePetItem_C:OnItemSelected")
      _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.ChangeChoosePetIndex, self.index)
      self:PlayAnimation(self.Select_in)
    else
      self:PlayAnimation(self.Select_out)
    end
  end
end

function UMG_ChooseAlternativePetItem_C:OnDeactive()
end

function UMG_ChooseAlternativePetItem_C:SetNatureIcon(icon, attributeCfg)
  if attributeCfg == Enum.AttributeType.AT_HPMAX_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED_PERCENT then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_ChooseAlternativePetItem_C:UpdateUI2()
  self.petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGID)
  if not self.petDataInfo then
    Log.Error("\231\188\186\229\176\145petDataInfo\230\149\176\230\141\174\239\188\140\232\175\183\229\145\138\231\159\165jobhuang\230\152\175\230\128\142\228\185\136\229\135\186\231\142\176\231\154\132")
    self:UpdateEmptyUI()
    return
  end
  self.PetLevel:SetText(self.petDataInfo.level)
  self.PetLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petDataInfo.base_conf_id)
  self.Name:SetText(self.petBaseConf.name)
  self.HeadIcon:SetIconPathAndMaterial(self.petDataInfo.base_conf_id, self.petDataInfo.mutation_type, self.petDataInfo.glass_info)
  self:updatePetTypeIcon(self.petBaseConf.unit_type)
  local texingID = self.petBaseConf.pet_feature
  local texingCfg = _G.DataConfigManager:GetSkillConf(texingID)
  if texingCfg then
    self.SkillIcon_1:SetPath(texingCfg.icon)
    self.SkillNameTxt_1:SetText(texingCfg.name)
  end
  local NatureDataList = {}
  if self.petDataInfo.attribute_info.attack.talent and 0 ~= self.petDataInfo.attribute_info.attack.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_PHYATK_PERCENT
    })
  end
  if self.petDataInfo.attribute_info.defense.talent and 0 ~= self.petDataInfo.attribute_info.defense.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_PHYDEF_PERCENT
    })
  end
  if self.petDataInfo.attribute_info.hp.talent and 0 ~= self.petDataInfo.attribute_info.hp.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_HPMAX_PERCENT
    })
  end
  if self.petDataInfo.attribute_info.special_attack.talent and 0 ~= self.petDataInfo.attribute_info.special_attack.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_SPEATK_PERCENT
    })
  end
  if self.petDataInfo.attribute_info.special_defense.talent and 0 ~= self.petDataInfo.attribute_info.special_defense.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_SPEDEF_PERCENT
    })
  end
  if self.petDataInfo.attribute_info.speed.talent and 0 ~= self.petDataInfo.attribute_info.speed.talent then
    table.insert(NatureDataList, {
      type = 1,
      attribute = Enum.AttributeType.AT_SPEED_PERCENT
    })
  end
  self.PersonalityIndividualValue1:InitGridView(NatureDataList)
  local NatureDataList1 = {}
  local SharePetNatureConf = _G.DataConfigManager:GetNatureConf(self.petDataInfo.nature)
  local share_pos_effect = SharePetNatureConf.positive_effect
  local share_neg_effect = SharePetNatureConf.negative_effect
  if self.petDataInfo.changed_nature_pos_attr_type and self.petDataInfo.changed_nature_pos_attr_type > 0 then
    share_pos_effect = self:GetChangeAttrReqEnum(self.petDataInfo.changed_nature_pos_attr_type)
  end
  if self.petDataInfo.changed_nature_neg_attr_type and self.petDataInfo.changed_nature_neg_attr_type > 0 then
    share_neg_effect = self:GetChangeAttrReqEnum(self.petDataInfo.changed_nature_neg_attr_type)
  end
  table.insert(NatureDataList1, {
    share_pos_effect = share_pos_effect,
    share_neg_effect = share_neg_effect,
    natureName = SharePetNatureConf.name,
    type = 0
  })
  self.PersonalityIndividualValue:InitGridView(NatureDataList1)
  self.SkillList_1:InitGridView(self.data.skills)
end

return UMG_ChooseAlternativePetItem_C
