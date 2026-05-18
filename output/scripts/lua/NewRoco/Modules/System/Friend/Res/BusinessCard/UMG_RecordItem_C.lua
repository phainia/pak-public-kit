local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RecordItem_C = Base:Extend("UMG_RecordItem_C")

function UMG_RecordItem_C:OnConstruct()
end

function UMG_RecordItem_C:OnDestruct()
end

function UMG_RecordItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data.isNil and 0 == self.data.isNil then
    self:SetRenderOpacity(1)
    self.Icon:SetPath(self.data.conf.icon)
    self.Time_Enrollment_4:SetText(self.data.conf.text)
    self.Time:SetText(self.data.context)
  else
    self:SetRenderOpacity(0)
  end
end

function UMG_RecordItem_C:OnItemSelected(_bSelected)
end

function UMG_RecordItem_C:OnDeactive()
end

return UMG_RecordItem_C
