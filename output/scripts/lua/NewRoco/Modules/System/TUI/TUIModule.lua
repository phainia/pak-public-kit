local TUIModule = NRCModuleBase:Extend("TUIModule")
local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")

function TUIModule:OnConstruct()
  _G.TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
  self.data = self:SetData("TUIModuleData", "NewRoco.Modules.System.TUI.TUIModuleData")
  self.IsShowTouchHotArea = false
  self.ChangeBackGroundWidgets = {}
  self.RootViewList = {}
  self.BlackBackgroundStack = {}
end

function TUIModule:OnOpenMainPanel(arg)
end

function TUIModule:OnActive()
  self:RegisterCmd(TUIModuleCmd.OpenMainPanel, self.OnCmdOpenMainPanel)
  self:RegisterCmd(TUIModuleCmd.ItemSelected, self.OnDropBoxItemSelected)
  self:RegisterCmd(TUIModuleCmd.ShowWorldViewUI, self.OnShowWorldViewUI)
  self:RegisterCmd(TUIModuleCmd.OpenPicturesListPanel, self.OnCmdOpenPicturesListPanel)
  self:RegisterCmd(TUIModuleCmd.OpenSubUMGPanel, self.OnCmdOpenSubUMGPanel)
  self:RegisterCmd(TUIModuleCmd.OpenNoSubUMGPanel, self.OnCmdOpenNoSubUMGPanel)
  self:RegisterCmd(TUIModuleCmd.OpenOrCloseTUIMediaPanel, self.OnCmdOpenOrCloseTUIMediaPanel)
  self:RegisterCmd(TUIModuleCmd.OpenTestPanelB, self.OnCmdOpenTestPanelB)
  self:RegisterCmd(TUIModuleCmd.ShowTestPanelB, self.OnCmdOpenTestPanelB)
  self:RegisterCmd(TUIModuleCmd.OpenTestPanelC, self.OnCmdOpenTestPanelC)
  self:RegisterCmd(TUIModuleCmd.CloseTestPanelC, self.OnCmdOpenTestPanelC)
  self:RegisterCmd(TUIModuleCmd.ShowTouchHotArea, self.OnCmdShowTouchHotArea)
  self:RegisterCmd(TUIModuleCmd.PushBlackBackgroundWidgets, self.PushBlackBackgroundWidgets)
  self:RegisterCmd(TUIModuleCmd.PopBlackBackgroundWidgets, self.PopBlackBackgroundWidgets)
  self:RegisterCmd(TUIModuleCmd.OpenPhotoPanel, self.OnCmdOpenPhotoPanel)
  self:RegisterCmd(TUIModuleCmd.OpenAppearanceMediaTestPanel, self.OnCmdOpenAppearanceMediaTestPanel)
  self:RegPanel("TUITEST", "UMG_TUI", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("WorldViewUI", "UMG_WorldViewUI", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("GotPicturesListPanel", "UMG_TUIGotPicturesListPanel", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("TUIBugTestB", "UMG_TUIBugTestB", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("TUIBugTestC", "UMG_TUIBugTestC", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:RegPanel("NoSubUMGTest", "UMG_NoSubUMG", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("SubUMGTest", "UMG_SubUMG", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("TUIMedia", "UMG_TUIMedia", _G.Enum.UILayerType.UI_LAYER_MAIN)
  self:RegPanel("Photo", "UMG_Photo", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:RegPanel("AppearanceMediaTest", "UMG_AppearanceMediaTest", _G.Enum.UILayerType.UI_LAYER_POPUP)
end

function TUIModule:OnRelogin()
end

function TUIModule:OnDeactive()
end

function TUIModule:OnDestruct()
end

function TUIModule:OnCmdOpenMainPanel()
  self:OpenPanel("TUITEST")
end

function TUIModule:OnDropBoxItemSelected(index)
  Log.Debug("TUIModule:OnDropBoxItemSelected", index)
  self:DispatchEvent(TUIModuleEvent.OnItemSelected, index)
end

function TUIModule:OnCmdOpenPicturesListPanel(_data)
  local RunAtlas = UE4.UNRCTUIStatics.GetRuntimeLoadAtlas():ToTable()
  self:OpenPanel("GotPicturesListPanel", RunAtlas)
end

function TUIModule:OnShowWorldViewUI(actor, cameraTransform)
  self:OpenPanel("WorldViewUI", actor, cameraTransform)
end

function TUIModule:OnCmdOpenSubUMGPanel(bOpen)
  if not bOpen then
    if self:HasPanel("SubUMGTest") then
      local panel = self:GetPanel("SubUMGTest")
      panel:DoClose()
    end
  else
    self:OpenPanelTest("SubUMGTest")
  end
end

function TUIModule:OnCmdOpenNoSubUMGPanel(bOpen)
  if not bOpen then
    if self:HasPanel("NoSubUMGTest") then
      local panel = self:GetPanel("NoSubUMGTest")
      panel:DoClose()
    end
  else
    self:OpenPanelTest("NoSubUMGTest")
  end
end

function TUIModule:OnCmdOpenTUIMediaPanel()
end

function TUIModule:OnCmdOpenOrCloseTUIMediaPanel(bOpen)
  if bOpen then
    if self:HasPanel("TUIMedia") then
      self:ClosePanel("TUIMedia")
    end
  else
    self:OpenPanel("TUIMedia")
  end
end

function TUIModule:RegPanel(name, path, layer, disablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/TUI/Res/%s", path)
  registerData.panelLayer = layer
  registerData.enablePcEsc = not disablePcEsc
  self:RegisterPanel(registerData)
end

function TUIModule:OnCmdOpenTestPanelB(bOpen)
  if bOpen then
    if self:HasPanel("TUIBugTestB") then
      self:DisablePanel("TUIBugTestB")
    end
  elseif self:HasPanel("TUIBugTestB") then
    self:EnablePanel("TUIBugTestB")
  else
    self:OpenPanel("TUIBugTestB")
  end
end

function TUIModule:OnCmdOpenTestPanelC(bOpen)
  if bOpen then
    if self:HasPanel("TUIBugTestC") then
      local panel = self:GetPanel("TUIBugTestC")
      panel:DoClose()
    end
  else
    self:OpenPanel("TUIBugTestC")
  end
end

function TUIModule:OnCmdOpenAppearanceMediaTestPanel()
  self:OpenPanel("AppearanceMediaTest")
end

function TUIModule:OnCmdShowTouchHotArea()
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCPanelEvent.ClosePanel, self.OnShowTouchHotArea)
  if _G.AppMain:HasDebug() then
    _G.NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
  end
end

function TUIModule:OnShowTouchHotArea(panelData)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnShowTouchHotArea)
  if self.IsShowTouchHotArea then
    self.IsShowTouchHotArea = false
    self:ClearHotArea()
  else
    self.IsShowTouchHotArea = true
    if panelData and panelData.panelName == "DebugPanel" then
      local topPanel = _G.NRCPanelManager:GetTopVisiblePanel()
      if topPanel then
        local widgetRoot = topPanel.WidgetTree.RootWidget
        if widgetRoot then
          self:ClearHotArea()
          local childWidgets = self:GetWidgetAllChildren(widgetRoot)
          self:ShowHotAreaByChangeBackGround(childWidgets)
        end
      end
    end
  end
end

function TUIModule:GetWidgetAllChildren(widget)
  local allChildWidgets = {}
  if widget and widget.GetChildrenCount and widget:GetChildrenCount() > 0 then
    local childrenCount = widget:GetChildrenCount()
    for i = 1, childrenCount do
      local childWidget = widget:GetChildAt(i - 1)
      if childWidget then
        if childWidget:IsA(UE.UUserWidget) then
          local rootWidget = childWidget.WidgetTree.RootWidget
          table.insert(self.RootViewList, {view = childWidget, widget = rootWidget})
          table.insert(allChildWidgets, rootWidget)
          local grandChildWidgets = self:GetWidgetAllChildren(rootWidget)
          for _, grandChild in ipairs(grandChildWidgets) do
            table.insert(allChildWidgets, grandChild)
          end
        else
          table.insert(allChildWidgets, childWidget)
          local grandChildWidgets = self:GetWidgetAllChildren(childWidget)
          for _, grandChild in ipairs(grandChildWidgets) do
            table.insert(allChildWidgets, grandChild)
          end
        end
      end
    end
  end
  return allChildWidgets
end

function TUIModule:ClearHotArea()
  for i = 1, #self.ChangeBackGroundWidgets do
    local widgetData = self.ChangeBackGroundWidgets[i]
    local widget = widgetData.widget
    local backgroundColor = widgetData.backgroundColor
    local normalColor = widgetData.normalColor
    local drawAs = widgetData.drawAs
    widget:SetBackgroundColor(backgroundColor)
    widget.WidgetStyle.Normal.TintColor.SpecifiedColor = normalColor
    widget.WidgetStyle.Normal.DrawAs = drawAs
    widget:SetStyle(widget.WidgetStyle)
  end
  self.ChangeBackGroundWidgets = {}
  self.RootViewList = {}
end

function TUIModule:ShowHotAreaByChangeBackGround(childWidgets)
  for _, widget in ipairs(childWidgets) do
    if widget:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and widget:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
      if widget:IsA(UE.UButton) then
        local backgroundColor = widget.BackgroundColor
        local normalColor = widget.WidgetStyle.Normal.TintColor.SpecifiedColor
        local drawAs = widget.WidgetStyle.Normal.DrawAs
        local widgetData = {
          widget = widget,
          backgroundColor = UE4.FLinearColor(backgroundColor.R, backgroundColor.G, backgroundColor.B, backgroundColor.A),
          normalColor = UE4.FLinearColor(normalColor.R, normalColor.G, normalColor.B, normalColor.A),
          drawAs = drawAs
        }
        table.insert(self.ChangeBackGroundWidgets, widgetData)
        local view = self:GetHotAreaParent(widget)
        if view and view.Slot and view.Slot and view.Slot.SetHorizontalAlignment and view.Slot.SetVerticalAlignment then
          view.Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Fill)
          view.Slot:SetVerticalAlignment(UE4.EVerticalAlignment.VAlign_Fill)
        end
        widget.WidgetStyle.Normal.TintColor.SpecifiedColor = UE4.FLinearColor(normalColor.R, normalColor.G, normalColor.B, 1)
        widget.WidgetStyle.Normal.DrawAs = UE4.ESlateBrushDrawType.Image
        widget:SetStyle(widget.WidgetStyle)
        widget:SetBackgroundColor(UE4.FLinearColor(1, 0, 0, 0.5))
      elseif widget:IsA(UE.UNRCGridView) then
        local count = widget:GetItemCount()
        for i = 1, count do
          local itemWidget = widget:GetItemByIndex(i - 1)
          local widgetRoot = itemWidget.WidgetTree.RootWidget
          if widgetRoot then
            local widgets = self:GetWidgetAllChildren(widgetRoot)
            self:ShowHotAreaByChangeBackGround(widgets)
          end
        end
      end
    end
  end
end

function TUIModule:GetHotAreaParent(widget)
  local parent = widget
  while parent:GetParent() do
    parent = parent:GetParent()
  end
  for _, widgetData in ipairs(self.RootViewList) do
    if widgetData.widget == parent then
      return widgetData.view
    end
  end
  return nil
end

function TUIModule:PushBlackBackgroundWidget(Widget)
  if #self.BlackBackgroundStack > 1 then
    self.BlackBackgroundStack[#self.BlackBackgroundStack - 1]:SetBackgroundVisible(false)
  end
  Widget:SetBackgroundVisible(true)
  table.insert(self.BlackBackgroundStack, Widget)
  Log.Debug("the black back ground widget=", Widget)
end

function TUIModule:PopBlackBackgroundWidget(Widget)
  local bSuccess = false
  for i = #self.BlackBackgroundStack, 1, -1 do
    if self.BlackBackgroundStack[i] == Widget then
      table.remove(self.BlackBackgroundStack, i)
      bSuccess = true
      break
    end
  end
  if not bSuccess then
    self:LogWarning("Cannot found back background widget in stack=", Widget)
  end
  if #self.BlackBackgroundStack > 1 then
    self.BlackBackgroundStack[#self.BlackBackgroundStack - 1]:SetBackgroundVisible(true)
  end
end

function TUIModule:PushBlackBackgroundWidgets(Widgets, EnableClickWidgets)
  local Proxy = {
    SetBackgroundVisible = function(_, bVisible)
      for k, Widget in pairs(Widgets) do
        if Widget and UE4.UObject.IsValid(Widget) then
          if bVisible then
            local bEnableClick = EnableClickWidgets and EnableClickWidgets[Widget]
            Widget:SetVisibility(not bEnableClick and UE.ESlateVisibility.HitTestInvisible or UE.ESlateVisibility.Visible)
          else
            Widget:SetVisibility(UE.ESlateVisibility.Collapsed)
          end
        end
      end
    end
  }
  self:PushBlackBackgroundWidget(Proxy)
  return Proxy
end

function TUIModule:PopBlackBackgroundWidgets(Proxy)
  if not Proxy then
    return
  end
  self:PopBlackBackgroundWidget(Proxy)
end

function TUIModule:OnCmdOpenPhotoPanel()
  self:OpenPanel("Photo")
end

return TUIModule
