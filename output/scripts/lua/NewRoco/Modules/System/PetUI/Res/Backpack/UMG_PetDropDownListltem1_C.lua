local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDropDownListltem1_C = Base:Extend("UMG_PetDropDownListltem1_C")

function UMG_PetDropDownListltem1_C:OnConstruct()
end

function UMG_PetDropDownListltem1_C:OnDestruct()
end

function UMG_PetDropDownListltem1_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  if self.uiData.InitSelect == true then
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FFC65FFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E9E1CFFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  if self.uiData.data.filter_icon then
    self.ShiNeng:SetPath(self.uiData.data.filter_icon)
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text:SetText(self.uiData.data.filter_desc)
end

function UMG_PetDropDownListltem1_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.uiData.InitSelect = not self.uiData.InitSelect
    if self.uiData.InitSelect == true then
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      self:PlayAnimation(self.Press)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_PetDropDownListltem1_C:OnItemSelected")
    else
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_PetDropDownListltem1_C:OnItemSelected")
      self:PlayAnimation(self.Cancel)
    end
    _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.AddOrRemoveFilterFromFilterList, self.uiData.InitSelect, self.uiData)
  end
end

function UMG_PetDropDownListltem1_C:OnAnimationFinished(anim)
end

function UMG_PetDropDownListltem1_C:OnDeactive()
end

return UMG_PetDropDownListltem1_C
