local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SelectChangeItem_C = Base:Extend("UMG_SelectChangeItem_C")

function UMG_SelectChangeItem_C:OnConstruct()
end

function UMG_SelectChangeItem_C:OnDestruct()
end

function UMG_SelectChangeItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.check:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local petBloodConf = _G.DataConfigManager:GetPetBloodConf(self.data.BloodId)
  self.DepartmentIcon:SetPath(petBloodConf.icon)
  self.SortText:SetText(petBloodConf.blood_name)
  if self.data.IsCurrentBloodId then
    self.mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetClickable(false)
  else
    self.mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetClickable(true)
  end
end

function UMG_SelectChangeItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFC65FFF"))
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727"))
    self.check:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.SetPetBloodChangeItemSelect, self.data.BloodId)
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.ResetDescText)
  else
    self.check:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#E8E1D0FF"))
    self.SortText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#625F5DFF"))
  end
end

function UMG_SelectChangeItem_C:OnDeactive()
end

return UMG_SelectChangeItem_C
