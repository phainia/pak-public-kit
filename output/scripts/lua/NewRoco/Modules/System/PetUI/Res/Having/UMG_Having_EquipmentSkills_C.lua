local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Having_EquipmentSkills_C = _G.NRCViewBase:Extend("UMG_Having_EquipmentSkills_C")

function UMG_Having_EquipmentSkills_C:OnConstruct()
  self:SetButtonInfo()
  self:OnAddEventListener()
  self.OldSubPanelIndex = 1
end

function UMG_Having_EquipmentSkills_C:OnDestruct()
end

function UMG_Having_EquipmentSkills_C:OnActive(_PanelInfo)
  self:SetPanelInfo()
end

function UMG_Having_EquipmentSkills_C:OnHavingChange(_data)
  self.data = _data
end

function UMG_Having_EquipmentSkills_C:OnDeactive()
end

function UMG_Having_EquipmentSkills_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_0.btnLevelUp, self.OnClickUpgradeBtn)
  self:AddButtonListener(self.Btn_2.btnLevelUp, self.OnClickReplaceBtn)
  self:AddButtonListener(self.backBtn.btnClose, self.OnClickDescend)
  self:AddButtonListener(self.Btn_Details.btnLevelUp, self.OnClickReplaceBtn)
end

function UMG_Having_EquipmentSkills_C:SetPanelInfo()
  local data = self.data
  if 0 ~= data.possessionItem.stage then
    self.Resonance:SetVisibility(UE4.ESlateVisibility.Visible)
    local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("Pet_carryon_resonance_string")
    self.Resonance:SetText(string.format("%s%s", LocalizationConf.msg, data.possessionItem.stage))
  else
    self.Resonance:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.NameTxt:SetText(data.bagItemConf.name)
  local Text = string.format("%d%s", data.possessionItem.level, LuaText.umg_having_equipmentskills_1)
  self.Name:SetText(Text)
  self.Describe:SetText(data.bagItemConf.description)
  self:SetProperty()
  self:SetSkillInfo()
  self:SetBtnState()
end

function UMG_Having_EquipmentSkills_C:SetBtnState()
  local data = self.data
  if data.possessionItem.level > 0 then
    self.State:SetActiveWidgetIndex(0)
  else
    self.State:SetActiveWidgetIndex(1)
  end
end

function UMG_Having_EquipmentSkills_C:SetProperty()
  local data = self.data
  local PropertyList = PetUtils.GetHavingPropertyByPossession(data.possessionItem)
  self.List:Clear()
  self.List:InitGridView(PropertyList)
end

function UMG_Having_EquipmentSkills_C:SetSkillInfo()
  local data = self.data
  local SkillInfo = PetUtils.GetHavingSkillPropertyByPossession(data.possessionItem)
  self.SkillIcon:SetPath(SkillInfo.SkillConf.icon)
  self.TxtSkillName:SetText(SkillInfo.SkillConf.name)
  self.TxtPnum:SetText(SkillInfo.SkillConf.energy_cost[1])
  self.TxtPower:SetText(SkillInfo.SkillConf.dam_para[1])
  local TypeDictionary = _G.DataConfigManager:GetTypeDictionary(SkillInfo.SkillConf.skill_dam_type)
  self.PetTypeIcon1:SetPath(TypeDictionary.tips_res)
  if SkillInfo.PetCarryonItem.carryon_skill_type == Enum.CarryonSkillTYpe.COST_ACTIVE then
    self.SkillType:SetText(LuaText.umg_having_equipmentskills_2)
  else
    self.SkillType:SetText(LuaText.umg_having_equipmentskills_3)
  end
end

function UMG_Having_EquipmentSkills_C:OnClickUpgradeBtn()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, 2, true, true)
end

function UMG_Having_EquipmentSkills_C:OnClickReplaceBtn()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, 3, true, false)
end

function UMG_Having_EquipmentSkills_C:OnClickDescend()
  if self.OldSubPanelIndex then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.OnClickSwitchPanelByIndex, self.data, self.OldSubPanelIndex, false, false)
  end
end

function UMG_Having_EquipmentSkills_C:SetButtonInfo()
  self.Btn_0:SetBtnText(LuaText.umg_having_equipmentskills_4)
  self.Btn_2:SetBtnText(LuaText.umg_having_equipmentskills_5)
  local Icon = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_tihuan1_png.img_tihuan1_png'"
  local Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_tihuan3_png.img_tihuan3_png'"
  local Icon_2 = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_tihuan2_png.img_tihuan2_png'"
  self.Btn_Details:SetPath(Icon, Icon_1, Icon_2)
end

return UMG_Having_EquipmentSkills_C
