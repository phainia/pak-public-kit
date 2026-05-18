local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MarkWarehouseItem_C = Base:Extend("UMG_MarkWarehouseItem_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_MarkWarehouseItem_C:OnConstruct()
end

function UMG_MarkWarehouseItem_C:OnDestruct()
end

function UMG_MarkWarehouseItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data and self.data.conf then
    self.mark_type = self.data.conf.mark_type
    self.Lock:SetVisibility(self.data.isUnlock and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
    self.Icon:SetPath(self.data.isUnlock and self.data.conf.mark_icon or self.data.conf.locked_mark_icon)
    if self.data.conf.mark_name then
      self.MarkText:SetText(self.data.conf.mark_name)
    end
  end
end

function UMG_MarkWarehouseItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MarkWarehouseItem_C:OnItemSelected")
    if self.data then
      NRCEventCenter:DispatchEvent(PetUIModuleEvent.OnSwitchPetBoxMark, self.mark_type, self.data.isUnlock)
    end
  else
    self:PlayAnimationReverse(self.Select_In)
  end
  self.selected = _bSelected
end

function UMG_MarkWarehouseItem_C:OnDeactive()
end

return UMG_MarkWarehouseItem_C
