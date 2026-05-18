local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TaskPhoto_TrackGoalItem_C = Base:Extend("UMG_TaskPhoto_TrackGoalItem_C")

function UMG_TaskPhoto_TrackGoalItem_C:OnConstruct()
end

function UMG_TaskPhoto_TrackGoalItem_C:OnDestruct()
end

function UMG_TaskPhoto_TrackGoalItem_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
end

function UMG_TaskPhoto_TrackGoalItem_C:OnItemSelected(_bSelected)
end

function UMG_TaskPhoto_TrackGoalItem_C:OnDeactive()
end

function UMG_TaskPhoto_TrackGoalItem_C:SetCheckEnabled(bEnable, ...)
  local EnableDesc = self.Data.EnableDesc
  local DisableDesc = self.Data.DisableDesc
  if bEnable then
    self.GoalText:SetText(string.format(EnableDesc, ...))
    self.CheckIcon:SetActiveWidgetIndex(1)
  else
    self.GoalText:SetText(string.format(DisableDesc, ...))
    self.CheckIcon:SetActiveWidgetIndex(0)
  end
end

return UMG_TaskPhoto_TrackGoalItem_C
