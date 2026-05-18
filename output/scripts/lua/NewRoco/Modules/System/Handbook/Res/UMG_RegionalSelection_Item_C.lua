local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local HandbookModuleEnum = reload("NewRoco.Modules.System.Handbook.HandbookModuleEnum")
local UMG_RegionalSelection_Item_C = Base:Extend("UMG_RegionalSelection_Item_C")

function UMG_RegionalSelection_Item_C:OnConstruct()
  self:AddButtonListener(self.BtnDisposition, self.OnBtnDisposition)
  self:AddButtonListener(self.BtnIndividualValue, self.OnBtnIndividualValue)
  self:AddButtonListener(self.BtnBloodPulse, self.OnBtnBloodPulse)
  self:AddButtonListener(self.BtnSkill, self.OnBtnSkill)
end

function UMG_RegionalSelection_Item_C:OnDestruct()
end

function UMG_RegionalSelection_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TextNumber:SetText(index)
  if index > 3 then
    self.TextNumber:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#f4eee1"))
  end
  self.TextPercentage:SetText(string.format("%.2f %%", self.data.ratio / 100))
  if self.data.type == HandbookModuleEnum.District.Nature then
    local id = self.data.data
    local natureConf = _G.DataConfigManager:GetNatureConf(id)
    if natureConf then
      local attrConf1 = self:GetAttributeConf(natureConf.positive_effect)
      local attrConf2 = self:GetAttributeConf(natureConf.negative_effect)
      self:UpdateAttrIcon(attrConf1, self.Icon)
      self:UpdateAttrIcon(attrConf2, self.Icon1)
      self.TextDescribe:SetText(natureConf.name)
    end
  elseif self.data.type == HandbookModuleEnum.District.Talent then
    local id = self.data.data
    local attrConf = _G.DataConfigManager:GetAttributeConf(id)
    if attrConf then
      self:UpdateAttrIcon(attrConf, self.valueIcon)
      self.TextDescribe:SetText(attrConf.attribute_name)
    end
  elseif self.data.type == HandbookModuleEnum.District.Blood then
    local id = self.data.data
    local boolConf = _G.DataConfigManager:GetPetBloodConf(id)
    if boolConf then
      local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(id)
      self.BloodPulseIcon:SetPath(PetBloodConf.icon)
      self.TextDescribe:SetText(boolConf.blood_name)
    end
  elseif self.data.type == HandbookModuleEnum.District.Skill then
    local id = self.data.data
    local skillConf = _G.DataConfigManager:GetSkillConf(id)
    if skillConf then
      self.SkillIcon:SetPath(skillConf.icon)
      self.TextDescribe:SetText(skillConf.name)
    end
  end
  self.Switcher:SetActiveWidgetIndex(self.data.type)
  self.CurrentPrompt:SetVisibility(self.data.markOwned and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_RegionalSelection_Item_C:GetAttributeConf(type)
  local attribute = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ATTRIBUTE_CONF):GetAllDatas()
  for _, v in pairs(attribute) do
    if type == v.attribute then
      return v
    end
  end
end

function UMG_RegionalSelection_Item_C:UpdateAttrIcon(attriconf, icon)
  if attriconf then
    local IconPath = attriconf.attribute_icon
    icon:SetPath(IconPath)
  end
end

function UMG_RegionalSelection_Item_C:OnBtnDisposition()
  _G.NRCAudioManager:PlaySound2DAuto(40008031, "UMG_RegionalSelection_Item_C:OnBtnDisposition")
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.OpendblockerTips, {
    natrueId = self.data.data,
    base_conf_id = self.data.petData.base_conf_id,
    mutation_type = self.data.petData.mutation_type,
    glass_info = self.data.petData.glass_info
  }, _G.Enum.GoodsType.GT_PET)
end

function UMG_RegionalSelection_Item_C:OnBtnIndividualValue()
  _G.NRCAudioManager:PlaySound2DAuto(40008031, "UMG_RegionalSelection_Item_C:OnBtnIndividualValue")
  local id = self.data.data
  local attrConf = _G.DataConfigManager:GetAttributeConf(id)
  _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.OpenTipsIndividualValu, attrConf.attribute_name)
end

function UMG_RegionalSelection_Item_C:OnBtnBloodPulse()
  _G.NRCAudioManager:PlaySound2DAuto(40008031, "UMG_RegionalSelection_Item_C:OnBtnBloodPulse")
  local id = self.data.data
  local boolConf = _G.DataConfigManager:GetPetBloodConf(id)
  local petData = self.data.petData
  if petData and petData.base_conf_id then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OpenPetBloodPulseStatistics, {
      isHandbook = true,
      blood_id = id,
      base_conf_id = petData.base_conf_id,
      bloodName = boolConf.name
    })
  end
end

function UMG_RegionalSelection_Item_C:OnBtnSkill()
  _G.NRCAudioManager:PlaySound2DAuto(40008031, "UMG_RegionalSelection_Item_C:OnBtnSkill")
  local petData = self.data.petData
  if petData and petData.base_conf_id then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenBagSKillTipsTop, self.data.data, false, nil, petData.base_conf_id, false, petData.gid)
  end
end

function UMG_RegionalSelection_Item_C:OnItemSelected(_bSelected)
end

function UMG_RegionalSelection_Item_C:OnDeactive()
end

function UMG_RegionalSelection_Item_C:OnClickBtnBloodPulse()
end

function UMG_RegionalSelection_Item_C:OnClickBtnDisposition()
end

function UMG_RegionalSelection_Item_C:OnClickBtnIndividualValue()
end

function UMG_RegionalSelection_Item_C:OnClickBtnSkill()
end

function UMG_RegionalSelection_Item_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_RegionalSelection_Item_C:OnAnimationFinished(anim)
end

return UMG_RegionalSelection_Item_C
