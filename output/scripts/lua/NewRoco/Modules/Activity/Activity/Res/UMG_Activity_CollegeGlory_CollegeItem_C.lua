local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_CollegeGlory_CollegeItem_C = Base:Extend("UMG_Activity_CollegeGlory_CollegeItem_C")

function UMG_Activity_CollegeGlory_CollegeItem_C:OnConstruct()
end

function UMG_Activity_CollegeGlory_CollegeItem_C:OnDestruct()
end

function UMG_Activity_CollegeGlory_CollegeItem_C:OnItemUpdate(_data, datalist, index)
  self.CollegeBadge:SetPath(_data.badge)
  self.CollegeName:SetText(_data.name)
  self.Completed:SetVisibility(_data.finished and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.CompletionTime:SetText(_data.finishedTime)
end

function UMG_Activity_CollegeGlory_CollegeItem_C:OnItemSelected(_bSelected)
end

return UMG_Activity_CollegeGlory_CollegeItem_C
