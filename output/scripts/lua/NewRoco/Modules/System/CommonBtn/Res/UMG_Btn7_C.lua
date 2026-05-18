local UMG_BtnBase = require("NewRoco.Modules.System.CommonBtn.Res.UMG_BtnBase")
local UMG_Btn7_C = UMG_BtnBase:Extend("UMG_Btn7_C")

function UMG_Btn7_C:SetTitleTextAndIcon(_MoneyIcon, _QuantityText, _SystemIcon, ShowTime, TitleText, DescText, _MoneyIcon1, Color)
  if _MoneyIcon or _QuantityText or _SystemIcon or ShowTime or TitleText or DescText then
    self.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _MoneyIcon then
    self.MoneyIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyIcon:SetPath(_MoneyIcon)
  else
    self.MoneyIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _QuantityText then
    self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Quantity:SetText(_QuantityText)
    if Color then
      self.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(Color))
    end
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _SystemIcon then
    self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SystemIcon:SetPath(_SystemIcon)
  else
    self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if TitleText then
    self.Tips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Tips:SetText(TitleText)
  else
    self.Tips:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if DescText then
    self.DescNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DescNum:SetText(DescText)
  else
    self.DescNum:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _MoneyIcon1 then
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyIcon_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyIcon_2:SetPath(_MoneyIcon1)
  else
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MoneyIcon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Btn7_C
