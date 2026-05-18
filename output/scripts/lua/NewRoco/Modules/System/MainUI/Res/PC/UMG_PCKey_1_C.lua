local UMG_PCKey_1_C = _G.NRCPanelBase:Extend("UMG_PCKey_1_C")

function UMG_PCKey_1_C:OnActive()
end

function UMG_PCKey_1_C:OnDeactive()
end

function UMG_PCKey_1_C:OnAddEventListener()
end

function UMG_PCKey_1_C:SetIAName(IAName)
  if not self:IsPCMode() or not IAName then
    return
  end
  local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, IAName)
  if "" ~= image then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:SetImageMode(image)
  elseif "" ~= text then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:SetText(text)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    Log.WarningFormat("UMG_PCKey_1_C:SetIAName IAName = %s is not found in table DEFAULT_BUTTON_CONF", tostring(IAName))
  end
end

function UMG_PCKey_1_C:SetText(text)
  if self.NRCWidgetLoader_1 then
    if self.NRCWidgetLoader_1:GetPanel() then
      local panel = self.NRCWidgetLoader_1:GetPanel()
      panel.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      panel.NRCSwitcher_0:SetActiveWidgetIndex(0)
      panel.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
      panel.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      panel:AdjustTextSize(text)
      panel.Text:SetText(text)
    elseif self:IsPCMode() then
      local Text = text
      local ImagePath
      local bSetMode = false
      self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bSetMode)
    end
  end
end

function UMG_PCKey_1_C:SetMode()
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.Select:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.Text:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text, ImagePath
    local bSetMode = true
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bSetMode)
  end
end

function UMG_PCKey_1_C:SetImageMode(imagePath)
  if self.NRCWidgetLoader_1:GetPanel() then
    local panel = self.NRCWidgetLoader_1:GetPanel()
    panel.TextPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    panel.NRCSwitcher_0:SetActiveWidgetIndex(1)
    panel.Image:SetPath(imagePath)
  elseif self:IsPCMode() and self.NRCWidgetLoader_1 then
    local Text
    local ImagePath = imagePath
    local bSetMode = false
    self.NRCWidgetLoader_1:LoadPanel(nil, true, Text, ImagePath, bSetMode)
  end
end

function UMG_PCKey_1_C:SetKeyVisibility(Visible)
  if self:IsPCMode() then
    if Visible then
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_PCKey_1_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_PCKey_1_C
