local UMG_PCKey_1_Loader_C = _G.NRCPanelBase:Extend("UMG_PCKey_1_Loader_C")

function UMG_PCKey_1_Loader_C:OnActive(bLoad, text, imagePath, bSetMode)
  if bLoad then
    if text then
      self:SetText(text)
    elseif imagePath then
      self:SetImageMode(imagePath)
    elseif bSetMode then
      self:SetMode()
    end
  end
end

function UMG_PCKey_1_Loader_C:OnDeactive()
end

function UMG_PCKey_1_Loader_C:OnAddEventListener()
end

function UMG_PCKey_1_Loader_C:SetText(text)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:AdjustTextSize(text)
  self.Text:SetText(text)
end

function UMG_PCKey_1_Loader_C:AdjustTextSize(inputText)
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

function UMG_PCKey_1_Loader_C:SetMode()
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Select:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_PCKey_1_Loader_C:SetImageMode(imagePath)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  self.Image:SetPath(imagePath)
end

return UMG_PCKey_1_Loader_C
