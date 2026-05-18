local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HavinggainTemplate1_C = Base:Extend("UMG_HavinggainTemplate1_C")

function UMG_HavinggainTemplate1_C:OnConstruct()
end

function UMG_HavinggainTemplate1_C:OnDestruct()
end

function UMG_HavinggainTemplate1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
  self:OnAddEventListener()
end

function UMG_HavinggainTemplate1_C:OnAddEventListener()
  self.QuestionMarkBtn.OnClicked:Add(self, self.OnMarkBtn)
end

function UMG_HavinggainTemplate1_C:OnMarkBtn()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
    skillData = self.data.SkillConf
  })
end

function UMG_HavinggainTemplate1_C:SetInfo()
  local data = self.data
  local Text
  if data.bagItemConf then
    self.State1:SetActiveWidgetIndex(0)
    self.State:SetActiveWidgetIndex(data.bagItemConf.item_quality - 1)
    if data.SkillConf then
      self.SkillTitle:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Visible)
      if data.PetCarryonItem.carryon_skill_type == Enum.CarryonSkillTYpe.COST_ACTIVE then
        Text = LuaText.umg_havinggaintemplate1_1
      else
        Text = LuaText.umg_havinggaintemplate1_2
      end
      self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Visible)
      self.GainWayDesc:SetText(Text)
      self.Skills_Name:SetText(data.SkillConf.name)
    else
      self.SkillTitle:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
      if 1 == data.AttributeConf.is_percent_attr then
        Text = string.format("%d%s", data.PetCarryonUpgrade.attr_param * 0.01, "%")
      else
        Text = string.format("%s%s", "+", data.PetCarryonUpgrade.attr_param)
      end
      self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.SkillTitle:SetText(Text)
      self.GainWayDesc:SetText(data.AttributeConf.attribute_name)
    end
  else
    self.State1:SetActiveWidgetIndex(1)
  end
end

function UMG_HavinggainTemplate1_C:OnItemSelected(_bSelected)
end

function UMG_HavinggainTemplate1_C:OnDeactive()
end

return UMG_HavinggainTemplate1_C
