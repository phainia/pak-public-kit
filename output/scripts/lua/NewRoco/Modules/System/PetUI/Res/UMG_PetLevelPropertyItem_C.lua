local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetLevelPropertyItem_C = Base:Extend("UMG_PetLevelPropertyItem_C")

function UMG_PetLevelPropertyItem_C:OnConstruct()
end

function UMG_PetLevelPropertyItem_C:OnDestruct()
end

function UMG_PetLevelPropertyItem_C:OnItemUpdate(_data, datalist, index)
  if index == #datalist then
    self.Line1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.index = index
  self.uiData = _data
  self:SetPetproperty()
  self:SetPropertyColor()
end

function UMG_PetLevelPropertyItem_C:SetPetproperty()
  self.NRCIcon:SetPath(self.uiData[1].icon)
  self.NRC_NoChange_1:SetText(self.uiData[1].attributevalue)
  self.NRC_NoChange:SetText(self.uiData[1].petbeforeproperty)
  self.NRC_Change:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRC_Change:SetText(self.uiData[1].petlaterproperty)
  self.NRCIcon_1:SetPath(self.uiData[2].icon)
  self.NRC_NoChange_3:SetText(self.uiData[2].attributevalue)
  self.NRC_NoChange_2:SetText(self.uiData[2].petbeforeproperty)
  self.NRC_Change_1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRC_Change_1:SetText(self.uiData[2].petlaterproperty)
end

function UMG_PetLevelPropertyItem_C:SetPropertyColor()
  if self.uiData[1].tempUpLevel > 0 then
    self.NRC_Change:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("70C800FF"))
  else
    self.NRC_Change:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("7e807fff"))
  end
  if self.uiData[2].tempUpLevel > 0 then
    self.NRC_Change_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("70C800FF"))
  else
    self.NRC_Change_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("7e807fff"))
  end
end

function UMG_PetLevelPropertyItem_C:OnItemSelected(_bSelected)
end

function UMG_PetLevelPropertyItem_C:OnDeactive()
end

return UMG_PetLevelPropertyItem_C
