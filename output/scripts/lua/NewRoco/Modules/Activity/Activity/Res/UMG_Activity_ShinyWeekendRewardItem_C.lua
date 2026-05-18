local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_ShinyWeekendRewardItem_C = Base:Extend("UMG_Activity_ShinyWeekendRewardItem_C")

function UMG_Activity_ShinyWeekendRewardItem_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_Activity_ShinyWeekendRewardItem_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_ShinyWeekendRewardItem_C:SetImage(path)
  self.HeadIcon:SetPath(path)
end

function UMG_Activity_ShinyWeekendRewardItem_C:SetCompleteStatus(completed)
  self.completed:SetVisibility(completed and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.AlreadyReceived:SetVisibility(completed and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Activity_ShinyWeekendRewardItem_C:SetRedPoint(key, extraKey)
  self.RedDot:SetupKey(key, extraKey)
end

return UMG_Activity_ShinyWeekendRewardItem_C
