local Array = require("Utils.Array")
local Base = require("Core.NRCPanelLayer.Base.UILayerCtrl")
local NRCPanelEnum = require("Core.NRCPanel.NRCPanelEnum")
local UICommonLayerCtrl = Base:Extend("UICommonLayerCtrl")
UICommonLayerCtrl._enableLog = true
UICommonLayerCtrl._windowDepthOffset = 50

function UICommonLayerCtrl:Ctor(center, type, depth)
  Base.Ctor(self, center, type, depth)
  self._showWins = Array()
end

function UICommonLayerCtrl:Free()
  self:CloseAll()
  self._showWins:Clear()
end

function UICommonLayerCtrl:CalcWindowDepth()
  local depth = self.depth
  local topWindowData = self._showWins:Last()
  if topWindowData then
    depth = (topWindowData.depth or 0) + (self._windowDepthOffset or 50)
  else
    depth = depth + (self._windowDepthOffset or 50)
  end
  return depth
end

function UICommonLayerCtrl:AddWindowData(windowId, module, dependentPanelName)
  local windowData = {}
  windowData.windowId = windowId
  windowData.module = module
  windowData.depth = self:CalcWindowDepth(dependentPanelName)
  self._showWins:Add(windowData)
  return windowData
end

function UICommonLayerCtrl:RemoveWindowData(windowId)
  for i, winData in ipairs(self._showWins:Items()) do
    if winData.windowId == windowId then
      self._showWins:RemoveAt(i)
      return winData
    end
  end
end

function UICommonLayerCtrl:GetWindowData(windowId)
  for _, winData in ipairs(self._showWins:Items()) do
    if winData.windowId == windowId then
      return winData
    end
  end
end

function UICommonLayerCtrl:OnAddToLayerViewport(windowData)
end

function UICommonLayerCtrl:OnRemoveFromLayerViewport(windowData)
end

function UICommonLayerCtrl:GetWindow(windowId)
  local winData = self:GetWindowData(windowId)
  if winData then
    return winData.panel
  end
end

function UICommonLayerCtrl:GetAllWindow()
  local ret = {}
  for _, winData in ipairs(self._showWins:Items()) do
    if winData and winData.panel then
      table.insert(ret, winData.panel)
    end
  end
  return ret
end

function UICommonLayerCtrl:GetWindowDepth(windowId)
  local winData = self:GetWindowData(windowId)
  if winData then
    return winData.depth
  end
end

function UICommonLayerCtrl:IsOpen(windowId)
  return self:GetWindowData(windowId) ~= nil
end

function UICommonLayerCtrl:GetLayerWindowCount()
  return self._showWins:Size()
end

function UICommonLayerCtrl:GetDebugData()
  local ret = {}
  for _, winData in ipairs(self._showWins:Items()) do
    table.insert(ret, winData)
  end
  return ret
end

function UICommonLayerCtrl:AddToLayerViewport(windowId, panel, module)
  local windowData = self:GetWindowData(windowId)
  windowData = windowData or self:AddWindowData(windowId, module)
  windowData.panel = panel
  panel.depth = windowData.depth
  self:DoAddToViewport(panel, windowData.depth, true)
  self:OnAddToLayerViewport(windowData)
  return true
end

function UICommonLayerCtrl:RemoveFromLayerViewport(panelOrWindowId)
  local windowId = self:CastToWindowId(panelOrWindowId)
  local windowData = self:RemoveWindowData(windowId)
  local window = windowData and windowData.panel
  if not window then
    return false
  end
  self:DoRemoveFromViewport(window)
  self:OnRemoveFromLayerViewport(windowData)
  return true
end

function UICommonLayerCtrl:SetPanelReadyToOpen(windowId, module, dependentPanelName)
  local windowData = self:PreAssignedPanelDepth(windowId, module, dependentPanelName)
  if windowData then
    windowData.isPreAssigned = nil
  end
end

function UICommonLayerCtrl:SetPanelAlreadyClosed(windowId)
  self:RemoveWindowData(windowId)
end

function UICommonLayerCtrl:PreAssignedPanelDepth(windowId, module, dependentPanelName)
  local windowData = self:GetWindowData(windowId)
  windowData = windowData or self:AddWindowData(windowId, module, dependentPanelName)
  if windowData then
    windowData.isPreAssigned = true
  end
  return windowData
end

function UICommonLayerCtrl:UndoPreAssignedPanelDepth(windowId)
  local windowData = self:GetWindowData(windowId)
  if windowData and windowData.isPreAssigned then
    self:RemoveWindowData(windowId)
  end
end

function UICommonLayerCtrl:CloseWindowByData(windowData)
  if not windowData then
    return
  end
  if windowData.panel then
    self:DoCloseWindow(windowData.panel)
  elseif windowData.module then
    windowData.module:ClosePanel(windowData.windowId)
  end
end

function UICommonLayerCtrl:ShowOrHideWindowByData(windowData, enable)
  if not windowData then
    return
  end
  local module = windowData.module
  if module then
    if enable then
      module:EnablePanel(windowData.windowId, NRCPanelEnum.PanelDisableReason.LayerCtrl)
    else
      module:DisablePanel(windowData.windowId, NRCPanelEnum.PanelDisableReason.LayerCtrl)
    end
  end
end

function UICommonLayerCtrl:CloseAll()
  local processWins = self._showWins:Clone()
  local size = processWins:Size()
  for i = size, 1, -1 do
    local windowData = processWins:Get(i)
    self:CloseWindowByData(windowData)
  end
end

function UICommonLayerCtrl:ActiveAll()
  local processWins = self._showWins:Clone()
  local size = processWins:Size()
  for i = 1, size do
    local windowData = processWins:Get(i)
    self:ShowOrHideWindowByData(windowData, true)
  end
end

function UICommonLayerCtrl:DeactiveAll()
  local processWins = self._showWins:Clone()
  local size = processWins:Size()
  for i = 1, size do
    local windowData = processWins:Get(i)
    self:ShowOrHideWindowByData(windowData, false)
  end
end

function UICommonLayerCtrl:Tick(deltaTime)
end

return UICommonLayerCtrl
