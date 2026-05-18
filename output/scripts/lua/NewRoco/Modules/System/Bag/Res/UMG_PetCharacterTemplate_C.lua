local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local Enum = require("Data.Config.Enum")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_PetCharacterTemplate_C = Base:Extend("UMG_PetCharacterTemplate_C")

function UMG_PetCharacterTemplate_C:OnConstruct()
end

function UMG_PetCharacterTemplate_C:OnDestruct()
end

function UMG_PetCharacterTemplate_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self:SetData()
end

function UMG_PetCharacterTemplate_C:SetData()
  local petNatureConf = _G.DataConfigManager:GetNatureConf(self.data.nature)
  if petNatureConf then
    self.CharacterText:SetText(petNatureConf.name or "")
  else
    Log.Error("petNatureConf Not Found")
    return
  end
  local attributeCfg1, attributeCfg2
  if 0 ~= self.data.changed_nature_pos_attr_type then
    attributeCfg1 = self:GetChangeAttrReqEnum(self.data.changed_nature_pos_attr_type)
  else
    local natureEffect = self:GetNatureEffect(petNatureConf.positive_effect)
    if natureEffect then
      attributeCfg1 = natureEffect.attribute
    else
      Log.Error("UMG_PetCharacterTemplate_C:SetData, natureEffect is nil ")
    end
  end
  if 0 ~= self.data.changed_nature_neg_attr_type then
    attributeCfg2 = self:GetChangeAttrReqEnum(self.data.changed_nature_neg_attr_type)
  else
    attributeCfg2 = self:GetNatureEffect(petNatureConf.negative_effect).attribute
  end
  self:SetNatureIcon(self.attributeIcon, attributeCfg1)
  self:SetNatureIcon(self.attributeIcon_1, attributeCfg2)
  local PetGrowLevel, GrowOrder = PetUtils.GetResidueGrowCountAndGrowOrder(self.data)
  if PetGrowLevel >= 999 then
    GrowOrder = 6
  end
  local Number = string.format("%s%s%s", "-", petNatureConf.negative_effect_proportion // 100, "%")
  local Number_1 = (petNatureConf.positive_effect_proportion + petNatureConf.positive_effect_grow * (GrowOrder - 1)) // 100
  local Text = string.format("%s%s%s", "+", Number_1, "%")
  self.OwnedText:SetText(Text)
  self.OwnedText_1:SetText(Number)
  self.Num:SetText(self.data.level)
  self.Name:SetText(self.data.name)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      self.HeadIcon:SetIconPathAndMaterial(self.data.base_conf_id, self.data.mutation_type, self.data.glass_info)
    end
  end
end

function UMG_PetCharacterTemplate_C:GetChangeAttrReqEnum(attribute)
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

function UMG_PetCharacterTemplate_C:GetNatureEffect(_effect)
  local attribute = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ATTRIBUTE_CONF):GetAllDatas()
  for i, v in pairs(attribute) do
    if _effect == v.attribute then
      return v
    end
  end
end

function UMG_PetCharacterTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_PetCharacterTemplate_C:OnItemSelected")
    if self.canOpenTips then
      self:PlayAnimation(self.Select_In1)
      self:OpenTips()
    else
      self:PlayAnimation(self.Select_In)
      self.canOpenTips = true
    end
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetCharacterItemCanSelect, false)
  else
    self:PlayAnimation(self.Select_Out)
    self.canOpenTips = false
  end
end

function UMG_PetCharacterTemplate_C:OpenTips()
  local selectItem = self.Parent.GridView:GetSelectedItem()
  if selectItem and selectItem.index and selectItem.index == self.index then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.data, false)
  end
end

function UMG_PetCharacterTemplate_C:SetParent(_Parent)
  self.Parent = _Parent
end

function UMG_PetCharacterTemplate_C:SetNatureIcon(icon, attributeCfg)
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

function UMG_PetCharacterTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.Select_In or Animation == self.Select_In1 then
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetCharacterItemCanSelect, true, self.data)
  end
end

function UMG_PetCharacterTemplate_C:OnDeactive()
end

return UMG_PetCharacterTemplate_C
