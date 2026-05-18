local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_Subject_Item1_C = Base:Extend("UMG_Handbook_Subject_Item1_C")

function UMG_Handbook_Subject_Item1_C:OnConstruct()
end

function UMG_Handbook_Subject_Item1_C:OnDestruct()
end

function UMG_Handbook_Subject_Item1_C:OnItemUpdate(_data, datalist, index)
  self.Quantity:SetText(_data.num)
  if _data.showStar then
    self.AngleMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("D36C1DFF"))
  else
    self.AngleMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
  end
end

function UMG_Handbook_Subject_Item1_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_Subject_Item1_C:OnDeactive()
end

return UMG_Handbook_Subject_Item1_C
