local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Pet_PartnerMarker_Item2_C = Base:Extend("UMG_Pet_PartnerMarker_Item2_C")

function UMG_Pet_PartnerMarker_Item2_C:OnConstruct()
end

function UMG_Pet_PartnerMarker_Item2_C:OnDestruct()
end

function UMG_Pet_PartnerMarker_Item2_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Text:SetText(self.uiData.data.filter_desc)
end

function UMG_Pet_PartnerMarker_Item2_C:OnItemSelected(_bSelected)
  if self.uiData.InitSelect ~= _bSelected then
    self.uiData.InitSelect = _bSelected
    if _bSelected then
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      self:PlayAnimation(self.Press)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_PetDropDownListltem2_C:OnItemSelected")
    else
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401002, "UMG_PetDropDownListltem2_C:OnItemSelected")
      self:PlayAnimation(self.Cancel)
    end
    _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.AddOrRemoveFilterFromFilterList, self.uiData.InitSelect, self.uiData)
  end
end

function UMG_Pet_PartnerMarker_Item2_C:InitItemState(_bSelected)
  if _bSelected then
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFC660FF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#E9E1CFFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
end

function UMG_Pet_PartnerMarker_Item2_C:OnDeactive()
end

return UMG_Pet_PartnerMarker_Item2_C
