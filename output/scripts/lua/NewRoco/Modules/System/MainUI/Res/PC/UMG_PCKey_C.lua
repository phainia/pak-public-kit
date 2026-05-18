local UMG_PCKey_C = _G.NRCPanelBase:Extend("UMG_PCKey_C")

function UMG_PCKey_C:OnActive()
end

function UMG_PCKey_C:OnDeactive()
end

function UMG_PCKey_C:OnAddEventListener()
end

function UMG_PCKey_C:SetText(text)
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.MousePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.NRCSwitcher_0:SetActiveWidgetIndex(0)
    panel.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel:AdjustTextSize(text)
    panel.Text:SetText(text)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text = text
    local ImagePath
    local bScrollMode = false
    local bLeftClickMode = false
    local bRightClickMode = false
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  end
end

function UMG_PCKey_C:SetImageMode(imagePath)
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.MousePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.NRCSwitcher_0:SetActiveWidgetIndex(1)
    panel.Image:SetPath(imagePath)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text
    local ImagePath = imagePath
    local bScrollMode = false
    local bLeftClickMode = false
    local bRightClickMode = false
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  end
end

function UMG_PCKey_C:SetScrollMode()
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.ArrowUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.ArrowDown:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.Slide:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.CircleFillImage_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text, ImagePath
    local bScrollMode = true
    local bLeftClickMode = false
    local bRightClickMode = false
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  end
end

function UMG_PCKey_C:SetLeftClickMode(Math)
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.CircleFillImage_77:SetFillAmount(0.25)
    panel.CircleFillImage_77:SetFillStartPercent(0.5)
    panel.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text, ImagePath
    local bScrollMode = false
    local bLeftClickMode = true
    local bRightClickMode = false
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  end
end

function UMG_PCKey_C:SetRightClickMode()
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.MousePanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.CircleFillImage_77:SetFillAmount(0.25)
    panel.CircleFillImage_77:SetFillStartPercent(0.5)
    panel.CircleFillImage_77:SetClockWise(true)
    panel.ArrowUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.ArrowDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    panel.Slide:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text, ImagePath
    local bScrollMode = false
    local bLeftClickMode = false
    local bRightClickMode = true
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bScrollMode, bLeftClickMode, bRightClickMode)
  end
end

function UMG_PCKey_C:SetKeyVisibility(Visible)
  if self:IsPCMode() then
    if Visible then
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PCKey_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_PCKey_C
