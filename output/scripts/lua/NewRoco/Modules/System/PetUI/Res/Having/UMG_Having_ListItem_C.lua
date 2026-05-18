local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Having_ListItem_C = Base:Extend("UMG_Having_ListItem_C")

function UMG_Having_ListItem_C:OnConstruct()
end

function UMG_Having_ListItem_C:OnDestruct()
end

function UMG_Having_ListItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
  self:OnAddEventListener()
end

function UMG_Having_ListItem_C:OnAddEventListener()
  self.QuestionMarkBtn.OnClicked:Add(self, self.OnMarkBtn)
end

function UMG_Having_ListItem_C:SetInfo()
  local data = self.data
  if data.SkillConf then
    self.NRC_NoChange:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State:SetActiveWidgetIndex(data.bagItemConf.item_quality - 1)
    local Text
    if data.PetCarryonItem.carryon_skill_type == Enum.CarryonSkillTYpe.COST_ACTIVE then
      Text = LuaText.umg_having_listitem_1
    else
      Text = LuaText.umg_having_listitem_2
    end
    self.NRC_NoChange_1:SetText(Text)
    self.Skills_Name:SetText(data.SkillConf.name)
  else
    self.NRC_NoChange:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Skills_Name:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.NRCIcon:SetPath(data.AttributeConf.attribute_icon)
    self.NRC_NoChange_1:SetText(data.AttributeConf.attribute_name)
    self.State:SetVisibility(UE4.ESlateVisibility.Hidden)
    local Text
    if 1 == data.AttributeConf.is_percent_attr then
      Text = string.format("%s%d%s", "+", data.PetCarryonUpgrade.attr_param * 0.01, "%")
    else
      Text = string.format("%s%d", "+", data.PetCarryonUpgrade.attr_param)
    end
    self.NRC_NoChange:SetText(Text)
  end
end

function UMG_Having_ListItem_C:OnMarkBtn()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
    skillData = self.data.SkillConf
  })
end

function UMG_Having_ListItem_C:OnItemSelected(_bSelected)
end

function UMG_Having_ListItem_C:OnDeactive()
end

return UMG_Having_ListItem_C
