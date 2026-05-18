local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDepartmentItem_C = Base:Extend("UMG_PetDepartmentItem_C")

function UMG_PetDepartmentItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data == nil then
    return
  end
  self.conf = _data.conf
  self.enum = _G.Enum[self.conf.filter_enum_name][self.conf.filter_enum_value]
  self.ShiNeng:SetPath(self.conf.filter_icon)
  self.Text:SetText(self.conf.filter_desc)
  self:PlayAnimation(self.Press)
end

function UMG_PetDepartmentItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PetDepartmentItem_C:OnAnimationFinished(Animation)
  if Animation == self.Cancel and self.data then
    local enumType = self.data.isDepartment and _G.Enum.FilterRule.FIL_SKILLDAM_TYPE or _G.Enum.FilterRule.FIL_SELF_ATTRIBUTE
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterCondition, enumType, self.enum)
  end
end

function UMG_PetDepartmentItem_C:OnDeactive()
end

return UMG_PetDepartmentItem_C
