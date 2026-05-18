local Base = require("NewRoco.Modules.System.Common.res.CommonAttrBase")
local UMG_Common_Attr3_C = Base:Extend("UMG_Common_Attr3_C")

function UMG_Common_Attr3_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo(self.data)
end

function UMG_Common_Attr3_C:SetInfo(_data)
  local data = _data
  if data then
    self.TypeName2_1:SetText(data.Name)
    self.BloodPulse:SetPath(data.Path)
  end
end

function UMG_Common_Attr3_C:OnItemSelected(_bSelected)
end

return UMG_Common_Attr3_C
