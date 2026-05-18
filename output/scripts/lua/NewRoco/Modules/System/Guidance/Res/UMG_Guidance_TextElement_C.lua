local UMG_Guidance_TextElement_C = _G.NRCPanelBase:Extend("UMG_Guidance_TextElement_C")

function UMG_Guidance_TextElement_C:Init(text, keyAction)
  local widgetIndex = 0
  if keyAction then
    local keyText, keyImage = _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetMappingKeyUIName, keyAction)
    if "" ~= keyImage then
      widgetIndex = 3
      self.KeyBg:SetPath(keyImage)
    elseif "LeftMouseButton" == keyText then
      widgetIndex = 2
      self:SetLeftClickMode()
    elseif "RightMouseButton" == keyText then
      widgetIndex = 2
      self:SetRightClickMode()
    elseif "MouseScrollDown" == keyText then
      widgetIndex = 2
      self:SetScrollDownMode()
    elseif "MouseScrollUp" == keyText then
      widgetIndex = 2
      self:SetScrollUpMode()
    else
      widgetIndex = 1
      if "" ~= keyText then
        self.Text_Hint_Button:SetText(keyText)
      else
        self.Text_Hint_Button:SetText(keyAction)
      end
    end
  elseif text then
    self.Text_Hint:SetText(text)
  end
  self.Switcher:SetActiveWidgetIndex(widgetIndex)
end

function UMG_Guidance_TextElement_C:SetScrollUpMode()
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Guidance_TextElement_C:SetScrollDownMode()
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Guidance_TextElement_C:SetSlideMode()
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_Guidance_TextElement_C:SetLeftClickMode()
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CircleFillImage_77:SetFillAmount(0.25)
  self.CircleFillImage_77:SetFillStartPercent(0.5)
end

function UMG_Guidance_TextElement_C:SetRightClickMode()
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CircleFillImage_77:SetFillAmount(0.25)
  self.CircleFillImage_77:SetFillStartPercent(0.5)
  self.CircleFillImage_77:SetClockWise(true)
end

return UMG_Guidance_TextElement_C
