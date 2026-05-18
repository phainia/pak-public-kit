local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChooseAlternativeItem_C = Base:Extend("UMG_ChooseAlternativeItem_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_ChooseAlternativeItem_C:OnConstruct()
  self.NRCTextDes.OnRichTextClick:Add(self, self.OnDescTextClicked)
end

function UMG_ChooseAlternativeItem_C:OnDestruct()
  self.NRCTextDes.OnRichTextClick:Remove(self, self.OnDescTextClicked)
end

function UMG_ChooseAlternativeItem_C:OnItemUpdate(_data, datalist, index)
  self.parent = _data.parent
  self.index = index
  self.type = _data.type
  self.descText = ""
  self.NRCSwitcher_0:SetActiveWidgetIndex(self.type - 1)
  if 1 == self.type then
    self.id = _data.id
    if 1 == self.index and _data.petGid then
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data.petGid)
      local petBaseID = petData.base_conf_id
      local itemDosageInfoList, _, _, skillUnLockInfoList = NRCModuleManager:DoCmd(PetUIModuleCmd.CalcuSkillLearningNeedItems, self.id, petBaseID, _data.petGid)
      if itemDosageInfoList and skillUnLockInfoList then
        local skillSourceType = skillUnLockInfoList[1].type
        self.Acquisition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if skillSourceType == Enum.PetNewSkillSrc.PNSS_PET_LEVEL_UP then
          self.Title:SetText(LuaText.lineup_code_learn_skill_level)
        elseif skillSourceType == Enum.PetNewSkillSrc.PNSS_SKILL_BOOK then
          self.Title:SetText(LuaText.lineup_code_learn_skill_stone)
        elseif skillSourceType == Enum.PetNewSkillSrc.PNSS_PET_BLOOD then
          self.Title:SetText(LuaText.lineup_code_learn_skill_blood)
        end
        self:UpdatePetTeamSkillCost(itemDosageInfoList)
      end
      self.ExclamationMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self:UpdateUI()
  elseif 2 == self.type then
    self.MagicData = _data.MagicData
    self:UpdateUI2()
  end
end

function UMG_ChooseAlternativeItem_C:OnDescTextClicked(id)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = self.descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_ChooseAlternativeItem_C:UpdateUI()
  local skillConf = _G.DataConfigManager:GetSkillConf(self.id)
  self.NumericalValue_1:SetText(skillConf.energy_cost[1])
  self.Department:SetPath(self:GetSkillTypePath(skillConf.Skill_Type, skillConf.damage_type))
  local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
  if typeDic then
    self.SkillShuIcon:SetPath(typeDic.tips_base_icon)
  end
  if 1 ~= skillConf.damage_type then
    self.NumericalValue:SetText(tostring(skillConf.dam_para[1]))
  else
    self.NumericalValue:SetText("-")
  end
  local skillDesc = skillConf.desc
  self.descText = skillDesc
  self.NRCTextDes:SetText(skillDesc)
  self.SkillIcon:SetPath(skillConf.icon)
  self.SkillNameTxt:SetText(skillConf.name)
end

function UMG_ChooseAlternativeItem_C:UpdateUI2()
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.MagicData.id)
  self.SkillIcon_2:SetPath(BagItemConf.big_icon)
  self.SkillNameTxt_2:SetText(BagItemConf.name)
  self.NRCTextDes_1:SetText(BagItemConf.description)
  self.Consumption_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.MagicData.petDataList then
    self.PetIcon:InitGridView(self.MagicData.petDataList)
  else
    self.PetSwitcher:SetActiveWidgetIndex(1)
  end
end

function UMG_ChooseAlternativeItem_C:GetSkillTypePath(type, damage_type)
  if type == Enum.SkillType.ST_DAMAGE then
    if damage_type == Enum.DamageType.DT_SPC then
      return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_04_png.ui_pet_attribute_04_png'"
    else
      return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/ui_pet_attribute_02_png.ui_pet_attribute_02_png'"
    end
  elseif type == Enum.SkillType.ST_DEFEND then
    return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/AT_DEFENSE_png.AT_DEFENSE_png'"
  else
    return "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/AT_CLASSIFICATION_png.AT_CLASSIFICATION_png'"
  end
end

function UMG_ChooseAlternativeItem_C:OnItemSelected(_bSelected)
  if true == _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ChooseAlternativeItem_C:OnItemSelected")
    self:PlayAnimation(self.Select_In)
    self.selected = true
    self.parent:ChangeSelectIndex(self.index)
  elseif true == self.selected then
    self:PlayAnimation(self.Select_out)
    self.selected = false
  end
end

function UMG_ChooseAlternativeItem_C:OnDeactive()
end

function UMG_ChooseAlternativeItem_C:UpdateCostUI(skillID, petGid)
  local costItems, data, itemSynthesisInfos = NRCModuleManager:DoCmd(PetUIModuleCmd.GetSkillCostByPetIDAndSkillID, skillID, petGid)
  self.Consumption:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ListIcon:InitGridView(costItems)
  self.parent:SetConsumeItem(costItems, data, itemSynthesisInfos)
end

function UMG_ChooseAlternativeItem_C:UpdatePetTeamSkillCost(itemDosageInfoList)
  if itemDosageInfoList then
    self.showItemList = itemDosageInfoList
    local showItemList = {}
    for i, v in ipairs(itemDosageInfoList) do
      local itemIconData = _G.NRCCommonItemIconData()
      itemIconData.itemType = v.itemType or _G.Enum.GoodsType.GT_BAGITEM
      itemIconData.itemId = v.itemId
      itemIconData.BagNum = v.itemNum
      itemIconData.itemNum = v.needNum
      itemIconData.bShowNum = true
      itemIconData.bShowTip = false
      itemIconData.checkIsEnough = true
      table.insert(showItemList, itemIconData)
    end
    self.Consumption:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ListIcon:InitGridView(showItemList)
  end
end

return UMG_ChooseAlternativeItem_C
