local Delegate = require("Utils.Delegate")
local WidgetLoaderPanelAdapter = Class("SettingPanelAdapter")

function WidgetLoaderPanelAdapter:Ctor(MainPanel, WidgetLoader)
  self.WidgetLoader = WidgetLoader
  self.MainPanel = MainPanel
  self.OnPanelOpened = Delegate()
  self.OnPanelClosed = Delegate()
end

function WidgetLoaderPanelAdapter:Reset()
  self.OnPanelClosed:Clear()
  self.OnPanelOpened:Clear()
end

function WidgetLoaderPanelAdapter:Open()
  if not self.WidgetLoader then
    return
  end
  if self.WidgetLoader:IsVisible() then
    return
  end
  self.WidgetLoader:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if not self.WidgetLoader:GetPanel() then
    self.WidgetLoader.OnLoadPanelCallbackDelegate:Clear()
    self.WidgetLoader.OnLoadPanelCallbackDelegate:Add(self, self.OnInternalPanelOpened)
    self.WidgetLoader:LoadPanel(self, function()
      return self:OnInternalPanelClosed()
    end)
  else
    self:OnInternalPanelOpened()
  end
end

function WidgetLoaderPanelAdapter:OnInternalPanelOpened()
  self.bOpened = true
  self.OnPanelOpened:Invoke()
end

function WidgetLoaderPanelAdapter:OnInternalPanelClosed()
  self.bOpened = false
  self.WidgetLoader:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.OnPanelClosed:Invoke()
end

function WidgetLoaderPanelAdapter:Close()
  if not self.WidgetLoader then
    return
  end
  if not self.bOpened then
    return
  end
  self:OnInternalPanelClosed()
end

function WidgetLoaderPanelAdapter:IsOpened()
  return self.bOpened
end

function WidgetLoaderPanelAdapter:GetPanel()
  return self.WidgetLoader:GetPanel()
end

return WidgetLoaderPanelAdapter
