local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Bag_PartnerMarker_Item1_C = Base:Extend("UMG_Bag_PartnerMarker_Item1_C")

function UMG_Bag_PartnerMarker_Item1_C:OnConstruct()
end

function UMG_Bag_PartnerMarker_Item1_C:OnDestruct()
end

function UMG_Bag_PartnerMarker_Item1_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  self.clickToggle = false
  self.Text:SetText(_data.filter_desc)
end

function UMG_Bag_PartnerMarker_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self.clickToggle = not self.clickToggle
    _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.data.filter_type, _G.Enum[self.data.filter_enum_name][self.data.filter_enum_value], self.clickToggle)
    if self.clickToggle == true then
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      self:PlayAnimation(self.Press)
      if self.IsNotPlaySound then
        self.IsNotPlaySound = false
      else
        UE4.UNRCAudioManager.Get():PlaySound2DAuto(1288, "UMG_PetDropDownListltem1_C:OnItemSelected")
      end
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401015, "UMG_PetDropDownListltem1_C:OnItemSelected")
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      self:PlayAnimation(self.Cancel)
    end
  end
end

function UMG_Bag_PartnerMarker_Item1_C:OnNotPlaySound()
  self.IsNotPlaySound = true
end

function UMG_Bag_PartnerMarker_Item1_C:OnDeactive()
end

return UMG_Bag_PartnerMarker_Item1_C
