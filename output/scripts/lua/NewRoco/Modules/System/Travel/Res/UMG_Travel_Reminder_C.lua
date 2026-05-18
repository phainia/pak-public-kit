local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Travel_Reminder_C = Base:Extend("UMG_Travel_Reminder_C")

function UMG_Travel_Reminder_C:OnConstruct()
end

function UMG_Travel_Reminder_C:OnDestruct()
end

function UMG_Travel_Reminder_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  local des = _data
  self.describe:SetText(des)
end

function UMG_Travel_Reminder_C:OnItemSelected(_bSelected)
end

function UMG_Travel_Reminder_C:OnDeactive()
end

return UMG_Travel_Reminder_C
