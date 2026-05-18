local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TerritoryTrialSettlement_PointsItem_C = Base:Extend("UMG_TerritoryTrialSettlement_PointsItem_C")
local reachedItemTextColorString = "#BD5115FF"

function UMG_TerritoryTrialSettlement_PointsItem_C:OnConstruct()
end

function UMG_TerritoryTrialSettlement_PointsItem_C:OnDestruct()
end

function UMG_TerritoryTrialSettlement_PointsItem_C:OnItemUpdate(_data, datalist, index)
  local prevProps = self.props
  local nextProps = _data
  self.props = nextProps
  self:RenderWidget(prevProps, nextProps)
end

function UMG_TerritoryTrialSettlement_PointsItem_C:OnItemSelected(_bSelected)
end

function UMG_TerritoryTrialSettlement_PointsItem_C:OnDeactive()
end

function UMG_TerritoryTrialSettlement_PointsItem_C:RenderWidget(prevProps, nextProps)
  local reached = nextProps and nextProps.acquirementReached
  local text = nextProps and nextProps.awardText or ""
  local starIndex = reached and 1 or 0
  self.StarSwitcher:SetActiveWidgetIndex(starIndex)
  self.TextPoints:SetText(text)
  if reached then
    self.TextPoints:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(reachedItemTextColorString))
  end
end

return UMG_TerritoryTrialSettlement_PointsItem_C
