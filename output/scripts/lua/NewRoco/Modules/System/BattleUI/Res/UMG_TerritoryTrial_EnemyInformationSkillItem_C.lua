local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TerritoryTrial_EnemyInformationSkillItem_C = Base:Extend("UMG_TerritoryTrial_EnemyInformationSkillItem_C")

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:OnConstruct()
  self.props = {}
  self:RenderWidget(self.props, self.props)
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:OnDestruct()
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:OnItemUpdate(_data, datalist, index)
  local nextProps = _data
  self:SetProps(nextProps)
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:OnItemSelected(_bSelected)
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:OnDeactive()
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:SetProps(nextProps)
  local prevProps = self.props
  self.props = nextProps
  self:RenderWidget(prevProps, nextProps)
end

function UMG_TerritoryTrial_EnemyInformationSkillItem_C:RenderWidget(prevProps, nextProps)
  local label = nextProps and nextProps.label
  local content = nextProps and nextProps.content
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.Name1:SetText(label)
  self.ContentDetails1:SetText(content)
end

return UMG_TerritoryTrial_EnemyInformationSkillItem_C
