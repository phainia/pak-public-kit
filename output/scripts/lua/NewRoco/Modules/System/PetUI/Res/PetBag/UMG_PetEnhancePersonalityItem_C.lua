local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetEnhancePersonalityItem_C = Base:Extend("UMG_PetEnhancePersonalityItem_C")

function UMG_PetEnhancePersonalityItem_C:OnConstruct()
end

function UMG_PetEnhancePersonalityItem_C:OnDestruct()
end

function UMG_PetEnhancePersonalityItem_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.clickToggle = false
  self.enum = _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value]
  if self.data.filter_icon then
    self.imageAttriIcon:SetPath(self.data.filter_icon)
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.imageAttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Text:SetText(self.data.filter_desc)
  self:PlayAnimation(self.Press)
end

function UMG_PetEnhancePersonalityItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PetEnhancePersonalityItem_C:OnAnimationFinished(Animation)
  if Animation == self.Cancel and self.enum then
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterCondition, _G.Enum.FilterRule.FIL_NATURE_POSITIVE_EFFECT, self.enum)
  end
end

function UMG_PetEnhancePersonalityItem_C:OnDeactive()
end

return UMG_PetEnhancePersonalityItem_C
