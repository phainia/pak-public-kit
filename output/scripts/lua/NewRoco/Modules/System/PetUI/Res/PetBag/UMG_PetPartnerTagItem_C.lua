local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetPartnerTagItem_C = Base:Extend("UMG_PetPartnerTagItem_C")

function UMG_PetPartnerTagItem_C:OnConstruct()
end

function UMG_PetPartnerTagItem_C:OnDestruct()
end

function UMG_PetPartnerTagItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data then
    self.enum = _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value]
  else
  end
  self.ShiNeng:SetPath(self.data.filter_icon)
  self.Text:SetText(self.data.filter_desc)
  self:PlayAnimation(self.Press)
end

function UMG_PetPartnerTagItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PetPartnerTagItem_C:OnAnimationFinished(Animation)
  if Animation == self.Cancel and self.enum then
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterCondition, _G.Enum.FilterRule.FIL_PET_MARK, self.enum)
  end
end

function UMG_PetPartnerTagItem_C:OnDeactive()
end

return UMG_PetPartnerTagItem_C
