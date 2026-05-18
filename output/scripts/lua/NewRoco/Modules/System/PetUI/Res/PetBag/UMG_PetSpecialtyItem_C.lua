local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetSpecialtyItem_C = Base:Extend("UMG_PetSpecialtyItem_C")

function UMG_PetSpecialtyItem_C:OnConstruct()
end

function UMG_PetSpecialtyItem_C:OnDestruct()
end

function UMG_PetSpecialtyItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local conf = self.data.conf
  self.Text:SetText(conf.filter_desc)
  self.enum = _G.Enum[conf.filter_enum_name][conf.filter_enum_value]
  if not self.data.isToggle then
    self:PlayAnimation(self.DefaultAim)
    self.Reduction:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Reduction:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetSpecialtyItem_C:OnItemSelected(_bSelected)
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_PetSpecialtyItem_C:OnItemSelected")
  if _bSelected then
    if self.data.isToggle then
      if self.curSelected then
        self.curSelected = false
        self:PlayAnimation(self.Cancel)
        _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterToggle, _G.Enum.FilterRule.FIL_CATCH_TIME, self.enum, false)
        return
      end
      self:PlayAnimation(self.Press)
      _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterToggle, _G.Enum.FilterRule.FIL_CATCH_TIME, self.enum, _bSelected)
    else
      self:PlayAnimation(self.Cancel)
    end
  elseif self.data.isToggle then
    if self.curSelected ~= false then
      self:PlayAnimation(self.Cancel)
    end
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterToggle, _G.Enum.FilterRule.FIL_CATCH_TIME, self.enum, _bSelected)
  end
  self.curSelected = _bSelected
end

function UMG_PetSpecialtyItem_C:OnSelect()
  if self.data.isToggle then
    self:PlayAnimation(self.Press)
  end
end

function UMG_PetSpecialtyItem_C:OnUnSelect()
  if self.data.isToggle and self.curSelected then
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PetSpecialtyItem_C:OnAnimationFinished(Animation)
  if Animation == self.Cancel and not self.data.isToggle and self.enum then
    _G.NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnChangePetBagFilterCondition, _G.Enum.FilterRule.FIL_PET_TALENT, self.enum)
  end
end

function UMG_PetSpecialtyItem_C:OnDeactive()
end

return UMG_PetSpecialtyItem_C
