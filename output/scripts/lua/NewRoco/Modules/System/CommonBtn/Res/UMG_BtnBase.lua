local UMG_BtnBase = _G.NRCViewBase:Extend("UMG_BtnBase")

function UMG_BtnBase:Construct()
end

function UMG_BtnBase:Destruct()
end

function UMG_BtnBase:OnActive()
end

function UMG_BtnBase:OnDeactive()
end

function UMG_BtnBase:SetTitleIcon(UseLeftIcon, LeftIconPath, UseRightIcon, RightIconPath, TitleText)
end

function UMG_BtnBase:SetNumColor(IsAdequate)
end

function UMG_BtnBase:SetBtnText(_Text)
  if self.Title_1 then
    self.Title_1:SetText(_Text)
  end
  if self.Title_2 then
    self.Title_2:SetText(_Text)
  end
  if self.Title then
    self.Title:SetText(_Text)
  end
  if self.Text_1 then
    self.Text_1:SetText(_Text)
  end
end

function UMG_BtnBase:SetTitleIcon()
end

function UMG_BtnBase:SetRedDotKey(_Key)
  if self.RedDot then
    self.RedDot:SetupKey(_Key)
  end
end

function UMG_BtnBase:SetRedDotExtraKey(_Key, _ExtraKey)
  if self.RedDot then
    self.RedDot:SetupKey(_Key, _ExtraKey)
  end
end

function UMG_BtnBase:EraseRedPoint()
  if self.RedDot then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_BtnBase:OnAnimStarted(anim)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_BtnBase:SetClickAble(isclick, bChangeColor)
  if self.btnLevelUp then
    self.btnLevelUp:SetIsEnabled(isclick)
  end
  self.BG:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
end

function UMG_BtnBase:OnAnimFinished(anim)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_BtnBase:SetTitleTextColor(ColorString)
  if self.Tips then
    self.Tips:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
  end
end

function UMG_BtnBase:SetQuantityTextColor(ColorString)
  if self.Quantity then
    self.Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(ColorString))
  end
end

function UMG_BtnBase:SetShowOrHideTitleCanvas(show)
  if self.TitleCanvas then
    if show then
      self.TitleCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.TitleCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_BtnBase:SetShowOrHideSuo(Show)
  if self.img_suo then
    if Show then
      self.img_suo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_BtnBase:SetPath()
end

return UMG_BtnBase
