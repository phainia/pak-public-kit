local UMG_PCKey_Loader_C = _G.NRCPanelBase:Extend("UMG_PCKey_Loader_C")

function UMG_PCKey_Loader_C:OnActive(bLoad, text, imagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  if bLoad then
    if text then
      self:SetText(text)
    elseif imagePath then
      self:SetImageMode(imagePath)
    elseif bScrollMode then
      self:SetScrollMode()
    elseif bLeftClickMode then
      self:SetLeftClickMode()
    elseif bRightClickMode then
      self:SetRightClickMode()
    end
  end
end

function UMG_PCKey_Loader_C:OnDeactive()
end

function UMG_PCKey_Loader_C:OnAddEventListener()
end

function UMG_PCKey_Loader_C:SetText(text)
  self.MousePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AdjustTextSize(text)
  self.Text:SetText(text)
end

function UMG_PCKey_Loader_C:AdjustTextSize(inputText)
  local text = inputText
  local textStr = tostring(text)
  local length = string.len(textStr)
  local Font = self.Text.Font
  if length <= 7 then
    Font.Size = 16
    self.Text:SetFont(Font)
  elseif length > 7 then
    Font.Size = 11
    self.Text:SetFont(Font)
  end
end

function UMG_PCKey_Loader_C:SetImageMode(imagePath)
  self.MousePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  self.Image:SetPath(imagePath)
end

function UMG_PCKey_Loader_C:SetScrollMode()
  self.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Slide:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.CircleFillImage_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PCKey_Loader_C:SetLeftClickMode(Math)
  self.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CircleFillImage_77:SetFillAmount(0.25)
  self.CircleFillImage_77:SetFillStartPercent(0.5)
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PCKey_Loader_C:SetRightClickMode()
  self.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CircleFillImage_77:SetFillAmount(0.25)
  self.CircleFillImage_77:SetFillStartPercent(0.5)
  self.CircleFillImage_77:SetClockWise(true)
  self.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

return UMG_PCKey_Loader_C
