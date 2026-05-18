local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Leve_ScheduleItem_C = Base:Extend("UMG_Leve_ScheduleItem_C")

function UMG_Leve_ScheduleItem_C:OnConstruct()
end

function UMG_Leve_ScheduleItem_C:OnDestruct()
end

function UMG_Leve_ScheduleItem_C:OnItemUpdate(_data, datalist, index)
  if _data.is_finish then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Leve_ScheduleItem_C:SetWidgetIndex(Index)
  self.Switcher:SetActiveWidgetIndex(Index)
end

function UMG_Leve_ScheduleItem_C:OnItemSelected(_bSelected)
end

function UMG_Leve_ScheduleItem_C:OnDeactive()
end

return UMG_Leve_ScheduleItem_C
