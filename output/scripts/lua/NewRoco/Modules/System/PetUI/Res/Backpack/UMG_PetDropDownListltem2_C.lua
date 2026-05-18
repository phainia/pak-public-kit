local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetDropDownListltem2_C = Base:Extend("UMG_PetDropDownListltem2_C")

function UMG_PetDropDownListltem2_C:OnConstruct()
end

function UMG_PetDropDownListltem2_C:OnDestruct()
end

function UMG_PetDropDownListltem2_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  if self.uiData.InitSelect == true then
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FFC65FFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
  else
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E9E1CFFF"))
    self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
  end
  if self.uiData.data.filter_icon then
    self.imageAttriIcon:SetPath(self.uiData.data.filter_icon)
    self.Canvas_AttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Spacer_83:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Canvas_AttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 1 == self.uiData.type then
    self.Canvas_AttriIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Spacer_83:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Up:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Canvas_AttriIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Spacer_83:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Up:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Text:SetText(self.uiData.data.filter_desc)
end

function UMG_PetDropDownListltem2_C:OnItemSelected(_bSelected)
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

function UMG_PetDropDownListltem2_C:OnDeactive()
end

return UMG_PetDropDownListltem2_C
