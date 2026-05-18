local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_HavinggainTemplate2_C = Base:Extend("UMG_HavinggainTemplate2_C")

function UMG_HavinggainTemplate2_C:OnConstruct()
end

function UMG_HavinggainTemplate2_C:OnDestruct()
end

function UMG_HavinggainTemplate2_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
  self:OnAddEventListener()
end

function UMG_HavinggainTemplate2_C:OnAddEventListener()
  self.QuestionMarkBtn.OnClicked:Add(self, self.OnMarkBtn)
end

function UMG_HavinggainTemplate2_C:OnMarkBtn()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
    skillData = self.data.SkillConf
  })
end

function UMG_HavinggainTemplate2_C:SetInfo()
  local data = self.data
  if data.IsFullLevle == true then
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SkillTitle:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    if data.CurrentLevel then
      self.State:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.GainWayDesc:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.CurrentLevelText:SetText(data.name)
      self.NRC_Change:SetText(data.CurrentLevel)
    elseif data.CurrentAttributeConf then
      self.State:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CurrentLevelText:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.State:SetActiveWidgetIndex(data.bagItemConf.item_quality - 1)
      self.GainWayDesc:SetText(data.CurrentAttributeConf.attribute_name)
      self:SetPropertyData(self.NRC_Change, data.CurrentAttributeConf, data.CurrentPetCarryonUpgrade.attr_param)
    end
  elseif data.IsFullLevle == false then
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SkillTitle:SetVisibility(UE4.ESlateVisibility.Visible)
    if data.CurrentLevel then
      self.State:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.GainWayDesc:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.CurrentLevelText:SetText(data.name)
      self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.SkillTitle:SetText(data.CurrentLevel)
      self.NRC_Change:SetText(data.NewLevel)
    elseif data.CurrentAttributeConf then
      self.State:SetVisibility(UE4.ESlateVisibility.Visible)
      self.CurrentLevelText:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.State:SetActiveWidgetIndex(data.bagItemConf.item_quality - 1)
      self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.GainWayDesc:SetText(data.CurrentAttributeConf.attribute_name)
      self:SetPropertyData(self.SkillTitle, data.CurrentAttributeConf, data.CurrentPetCarryonUpgrade.attr_param)
      self:SetPropertyData(self.NRC_Change, data.CurrentAttributeConf, data.NewPetCarryonUpgrade.attr_param)
    end
  else
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCArrows:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SkillTitle:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CurrentLevelText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.State:SetActiveWidgetIndex(data.bagItemConf.item_quality - 1)
    local Text
    if data.PetCarryonItem.carryon_skill_type == Enum.CarryonSkillTYpe.COST_ACTIVE then
      Text = LuaText.umg_havinggaintemplate2_1
    else
      Text = LuaText.umg_havinggaintemplate2_2
    end
    self.GainWayDesc:SetText(Text)
    self.Skills_Name:SetText(data.SkillConf.name)
  end
end

function UMG_HavinggainTemplate2_C:SetPropertyData(Text, CurrentAttributeConf, attr_param)
  local TextData
  if 1 == CurrentAttributeConf.is_percent_attr then
    TextData = string.format("%s%d%s", "+", attr_param * 0.01, "%")
  else
    TextData = string.format("%s%d", "+", attr_param)
  end
  Text:SetText(TextData)
end

function UMG_HavinggainTemplate2_C:OnItemSelected(_bSelected)
end

function UMG_HavinggainTemplate2_C:OnDeactive()
end

return UMG_HavinggainTemplate2_C
