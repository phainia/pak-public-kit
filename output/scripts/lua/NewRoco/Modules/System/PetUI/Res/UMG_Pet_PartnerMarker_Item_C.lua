local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Pet_PartnerMarker_Item_C = Base:Extend("UMG_Pet_PartnerMarker_Item_C")

function UMG_Pet_PartnerMarker_Item_C:OnConstruct()
end

function UMG_Pet_PartnerMarker_Item_C:OnDestruct()
end

function UMG_Pet_PartnerMarker_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.data = self.uiData.data
  if self.uiData.data and self.uiData.data.filter_enum_name and self.uiData.data.filter_enum_value and _G.Enum[self.uiData.data.filter_enum_name] and _G.Enum[self.uiData.data.filter_enum_name][self.uiData.data.filter_enum_value] and _G.Enum[self.uiData.data.filter_enum_name][self.uiData.data.filter_enum_value] == Enum.PetPartnerMarkType.PPMT_NONE then
    self.ShiNeng:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFFFFFFF"))
  else
    self.ShiNeng:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FAC563FF"))
  end
  self.ShiNeng:SetPath(self.uiData.filter_icon or self.uiData.data.filter_icon)
  self.Text:SetText(self.uiData.filter_desc or self.uiData.data.filter_desc)
  if self.uiData.InitSelect == true then
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FFC65FFF"))
    self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#272727FF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.NRCImage_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#E9E1CFFF"))
    self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#62605EFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  if self.uiData.isWhite then
    self.ShiNeng:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#FBF8F1FF"))
  end
end

function UMG_Pet_PartnerMarker_Item_C:OnNotPlaySound()
  self.SkipAudio = true
end

function UMG_Pet_PartnerMarker_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    if self.uiData.type then
      self.uiData.InitSelect = not self.uiData.InitSelect
      if self.uiData.InitSelect == true then
        self:PlayAnimation(self.Press)
        _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.uiData.data.filter_type, _G.Enum[self.uiData.data.filter_enum_name][self.uiData.data.filter_enum_value], true)
        if not self.uiData.isWhite then
          self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#272727FF"))
        end
        self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
        if self.SkipAudio then
          self.SkipAudio = false
        else
          _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_PetReportPetListItem_C:OnItemSelected")
        end
      else
        self:PlayAnimation(self.Cancel)
        _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnClickFilterItem, self.uiData.data.filter_type, _G.Enum[self.uiData.data.filter_enum_name][self.uiData.data.filter_enum_value], false)
        self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#62605EFF"))
        self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
        _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetReportPetListItem_C:OnItemSelected")
      end
      if not self.uiData.NoEvent then
        _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.AddOrRemoveFilterFromFilterList, self.uiData.InitSelect, self.uiData)
      end
    else
      self:PlayAnimation(self.Press)
      self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#272727FF"))
      self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.SelectPetCollectMarkType, _G.Enum[self.uiData.data.filter_enum_name][self.uiData.data.filter_enum_value], self.uiData.data.filter_desc)
    end
  elseif not self.uiData.type then
    self:StopAllAnimations()
    self:PlayAnimation(self.Cancel)
    self.Bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#62605EFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
end

function UMG_Pet_PartnerMarker_Item_C:OnDeactive()
end

return UMG_Pet_PartnerMarker_Item_C
