local UMG_BtnBase = require("NewRoco.Modules.System.CommonBtn.Res.UMG_BtnBase")
local UMG_Btn3_C = UMG_BtnBase:Extend("UMG_Btn3_C")

function UMG_Btn3_C:SetShowLockIcon(_bShow)
  if _bShow then
    self.img_suo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Btn3_C:SetTitleTextAndIcon(_MoneyIcon, _QuantityText, _SystemIcon, ShowTime, TitleText, DescText, Color)
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
    self.SystemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SystemIcon:SetPath(_SystemIcon)
  else
    self.SystemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if ShowTime then
    self.Time_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Time_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
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
end

function UMG_Btn3_C:SetMoneyIconScale(scaleX, scaleY)
  self.MoneyIcon:SetRenderScale(UE4.FVector2D(scaleX, scaleY))
end

function UMG_Btn3_C:SetOnlyShowTipText(_QuantityText)
  if self.HorizontalBox_33 then
    self.HorizontalBox_33:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Quantity_1 then
    self.Quantity_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Quantity_1:SetText(_QuantityText)
  end
end

return UMG_Btn3_C
