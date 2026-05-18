local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BookClass_C = Base:Extend("UMG_BookClass_C")

function UMG_BookClass_C:OnConstruct()
end

function UMG_BookClass_C:OnDestruct()
end

function UMG_BookClass_C:OnActive(_data)
  self.data = _data
  self.NRCSwitcher_0:SetActiveWidgetIndex(2 == self.data.state and 1 or 0)
end

function UMG_BookClass_C:SetLine(index, distance, isMaxCount)
  local size = self.NRCImage_59.Slot:GetSize()
  self.NRCImage_59.Slot:SetSize(UE4.FVector2D(distance, size.y))
  if 2 ~= self.data.state then
    self.NRCImage.Slot:SetSize(UE4.FVector2D(distance, size.y))
  else
    self.NRCImage.Slot:SetSize(UE4.FVector2D(0, size.y))
  end
  if 1 == index then
    self.NRCImage.Slot:SetSize(UE4.FVector2D(0, size.y))
  end
  if isMaxCount then
    self.NRCImage_59.Slot:SetSize(UE4.FVector2D(0, size.y))
  end
  if 1 == index % 2 then
    self.NRCImage_59:SetRenderTransformAngle(-14)
    self.NRCImage:SetRenderTransformAngle(194)
  else
    self.NRCImage_59:SetRenderTransformAngle(14)
    self.NRCImage:SetRenderTransformAngle(166)
  end
end

function UMG_BookClass_C:SetInfo()
  self.Star:SetPath(self.data.icon)
end

function UMG_BookClass_C:OnItemSelected(_bSelected)
end

function UMG_BookClass_C:OnDeactive()
end

return UMG_BookClass_C
