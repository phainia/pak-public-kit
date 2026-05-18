local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_HabitReminder_Item_C = Base:Extend("UMG_Handbook_HabitReminder_Item_C")

function UMG_Handbook_HabitReminder_Item_C:OnConstruct()
end

function UMG_Handbook_HabitReminder_Item_C:OnDestruct()
end

function UMG_Handbook_HabitReminder_Item_C:OnItemUpdate(_data, datalist, index)
  self.Description:SetText(_data)
  if index == #datalist then
    self.NRCImage_25:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NRCImage_25:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Handbook_HabitReminder_Item_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_HabitReminder_Item_C:OnDeactive()
end

return UMG_Handbook_HabitReminder_Item_C
