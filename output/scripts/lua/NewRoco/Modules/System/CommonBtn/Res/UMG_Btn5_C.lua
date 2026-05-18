local UMG_BtnBase = require("NewRoco.Modules.System.CommonBtn.Res.UMG_BtnBase")
local UMG_Btn5_C = UMG_BtnBase:Extend("UMG_Btn5_C")

function UMG_Btn5_C:SetTitleTextAndIcon(_MoneyIcon, _QuantityText, _SystemIcon, ShowTime, TitleText, DescText, FormationIcon)
  local QuantitySizeBoxVisibility = UE4.ESlateVisibility.Collapsed
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
    QuantitySizeBoxVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    self.Quantity:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Quantity:SetText(_QuantityText)
  else
    self.Quantity:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _SystemIcon then
    self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SystemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SystemIcon:SetPath(_SystemIcon)
  else
    self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SystemIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
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
  if FormationIcon then
    self.Formation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.FormationIcon:SetPath(FormationIcon)
  else
    self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.QuantitySizeBox:SetVisibility(QuantitySizeBoxVisibility)
end

function UMG_Btn5_C:ResetButtonDiscountState()
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Btn5_C:SetDiscount(discountAmount)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Text1:SetText(string.format("-%s", discountAmount))
end

function UMG_Btn5_C:SetMoneyIconScale(scaleX, scaleY)
  self.MoneyIcon:SetRenderScale(UE4.FVector2D(scaleX, scaleY))
end

function UMG_Btn5_C:SetQuantityTextColor(color)
  self.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(color))
end

function UMG_Btn5_C:SetAppearanceButtonContext(moneyIcon, moneyCount, extraPikaPoint)
  if self.MoneyIcon and moneyIcon then
    self.MoneyIcon:SetPath(moneyIcon)
  end
  if self.Quantity and moneyCount then
    self.Quantity:SetText(moneyCount)
  end
  if extraPikaPoint and extraPikaPoint > 0 then
    self.PiKaCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_1:SetText("x" .. extraPikaPoint)
  else
    self.PiKaCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Btn5_C:SetupView_FirstVictory(bShowFirstVictory)
  local tipsText = bShowFirstVictory and LuaText.PVP_rank_character3 or nil
  self:SetTitleTextAndIcon(nil, nil, nil, nil, tipsText, nil, nil)
end

return UMG_Btn5_C
