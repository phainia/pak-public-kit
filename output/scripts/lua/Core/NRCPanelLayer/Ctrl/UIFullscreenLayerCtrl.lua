local Array = require("Utils.Array")
local Base = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local FAKE_FULLSCREEN = "fake_fullscreen"
local UIFullscreenLayerCtrl = Base:Extend("UIFullscreenLayerCtrl")
UIFullscreenLayerCtrl._windowDepthOffset = 1000

function UIFullscreenLayerCtrl:Ctor(center, type, depth)
  Base.Ctor(self, center, type, depth)
  self._relatePopWinsDic = {}
end

function UIFullscreenLayerCtrl:Init()
  Base.Init(self)
  self:AddWindowData(FAKE_FULLSCREEN)
end

function UIFullscreenLayerCtrl:OnAddToLayerViewport(windowData)
  self:FoldOtherPanelAndPopupInAdvance()
  self:SendEvent(UILayerEvent.FULLSCREEN_LAYER_OPENWINDOW, windowData.panel)
end

function UIFullscreenLayerCtrl:OnRemoveFromLayerViewport(windowData)
  self:SendEvent(UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, windowData.panel)
end

function UIFullscreenLayerCtrl:IsFakePanel(windowData)
  return windowData and windowData.windowId == FAKE_FULLSCREEN
end

function UIFullscreenLayerCtrl:GetLayerWindowCount()
  local windowCount = Base.GetLayerWindowCount(self)
  if windowCount > 0 and self:IsFakePanel(self._showWins:First()) then
    windowCount = windowCount - 1
  end
  return windowCount
end

function UIFullscreenLayerCtrl:GetDebugData()
  local ret = {}
  for _, winData in ipairs(self._showWins:Items()) do
    local debugDataItem = table.copy(winData)
    table.insert(ret, debugDataItem)
    local popWins = self._relatePopWinsDic[winData.windowId]
    if popWins and not popWins:IsEmpty() then
      debugDataItem.popWins = {}
      for _, popWinData in ipairs(popWins:Items()) do
        table.insert(debugDataItem.popWins, popWinData)
      end
    end
  end
  return ret
end

function UIFullscreenLayerCtrl:RemoveFromLayerViewport(panelOrWindowId)
  local windowId = self:CastToWindowId(panelOrWindowId)
  if self._relatePopWinsDic[windowId] and self._relatePopWinsDic[windowId]:Size() > 0 then
    local relatePopWinsDicClone = self._relatePopWinsDic[windowId]:Clone()
    local size = relatePopWinsDicClone:Size()
    for i = size, 1, -1 do
      local popWinData = relatePopWinsDicClone:Get(i)
      self:CloseWindowByData(popWinData)
    end
    self._relatePopWinsDic[windowId]:Clear()
  end
  self:SetPanelReadyToClosed(windowId)
  return Base.RemoveFromLayerViewport(self, windowId)
end

function UIFullscreenLayerCtrl:AddPopWin(windowData, dependentPanelName)
  if not windowData then
    return
  end
  if nil ~= dependentPanelName then
    local TargetWin = self:GetTargetWinData(dependentPanelName)
    if TargetWin then
      local windowId = TargetWin.windowId
      if nil == self._relatePopWinsDic[windowId] then
        self._relatePopWinsDic[windowId] = Array()
      end
      self._relatePopWinsDic[windowId]:Add(windowData)
      return windowId
    end
  end
  local topWin = self._showWins:Last()
  if topWin then
    local windowId = topWin.windowId
    if nil == self._relatePopWinsDic[windowId] then
      self._relatePopWinsDic[windowId] = Array()
    end
    self._relatePopWinsDic[windowId]:Add(windowData)
    return windowId
  end
end

function UIFullscreenLayerCtrl:RemovePopWin(windowData)
  if not windowData or not windowData.parentId then
    return
  end
  local popWins = self._relatePopWinsDic[windowData.parentId]
  if popWins then
    local size = popWins:Size()
    for i = size, 1, -1 do
      local popWinData = popWins:Get(i)
      if popWinData.windowId == windowData.windowId then
        popWins:RemoveAt(i)
        break
      end
    end
  end
end

function UIFullscreenLayerCtrl:GetLayerOpaqueWindowCount()
  local count = 0
  local size = self._showWins:Size()
  for i = 1, size do
    local windowData = self._showWins:Get(i)
    local window = windowData.panel
    if window and window.panelData and not window.panelData.translucent then
      count = count + 1
    end
  end
end

function UIFullscreenLayerCtrl:GetTargetWinDepth(inWindowId)
  local size = self._showWins:Size()
  for i = 1, size do
    local windowData = self._showWins:Get(i)
    if windowData.windowId == inWindowId then
      return windowData.depth
    end
  end
  return nil
end

function UIFullscreenLayerCtrl:GetTargetWinData(inWindowId)
  local size = self._showWins:Size()
  for i = 1, size do
    local windowData = self._showWins:Get(i)
    if windowData.windowId == inWindowId then
      return windowData
    end
  end
  return nil
end

function UIFullscreenLayerCtrl:GetTopPopWinDepth()
  local topFullWinData = self._showWins:Last()
  if topFullWinData then
    local popWins = self._relatePopWinsDic[topFullWinData.windowId]
    local topPopWinData = popWins and popWins:Last()
    if topPopWinData then
      return topPopWinData.depth
    else
      return topFullWinData.depth
    end
  end
end

function UIFullscreenLayerCtrl:CheckWindowBeOverlay(inWindowId)
  local size = self._showWins:Size()
  for i = 1, size do
    local windowData = self._showWins:Get(i)
    if windowData.windowId == inWindowId then
      return i ~= size
    end
  end
  return false
end

function UIFullscreenLayerCtrl:SetPanelAlreadyVisible(windowId, panel)
  if _G.GlobalConfig.EnableFullScreenPanelCollapsed == true and not self.delayCollapsed then
    self.delayCollapsed = _G.DelayManager:DelayFrames(1, self.CollapsedOtherPanelAndPopup, self)
  end
end

function UIFullscreenLayerCtrl:SetPanelReadyToClosed(frontWindowId)
  if _G.GlobalConfig.EnableFullScreenPanelCollapsed == true then
    local size = self._showWins:Size()
    if size > 1 then
      local frontWindowData = self._showWins:Get(size)
      if frontWindowData.windowId == frontWindowId then
        self:ShowLastPanelAndPopup()
      end
    end
  end
end

function UIFullscreenLayerCtrl:DoFoldSpecifiedWindow(windowData)
  if not windowData then
    return false
  end
  if windowData._visibilityBeforeFold then
    return true
  end
  local curVisibility = -1
  local panel = windowData.panel
  if panel then
    curVisibility = panel:GetVisibility()
    panel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if panel.OnFoldCollapsed then
      local ok, msg = pcall(panel.OnFoldCollapsed, panel)
      if not ok then
        Log.Error(msg)
      end
    end
  else
    self:ShowOrHideWindowByData(windowData, false)
  end
  windowData._visibilityBeforeFold = curVisibility
  return true
end

function UIFullscreenLayerCtrl:UnDoFoldSpecifiedWindow(windowData)
  if not windowData then
    return false
  end
  local visibilityBeforeFold = windowData._visibilityBeforeFold
  windowData._visibilityBeforeFold = nil
  if -1 == visibilityBeforeFold then
    self:ShowOrHideWindowByData(windowData, true)
  end
  local panel = windowData.panel
  if visibilityBeforeFold and -1 ~= visibilityBeforeFold and panel then
    if panel.OnUnDoFoldCollapsed then
      local ok, msg = pcall(panel.OnUnDoFoldCollapsed, panel)
      if not ok then
        Log.Error(msg)
      end
    end
    if self:IsWindowActive(panel) and panel:GetVisibility() == UE4.ESlateVisibility.Collapsed then
      panel:SetVisibility(visibilityBeforeFold)
      return true
    end
  end
  if panel then
    return panel:GetVisibility() ~= UE4.ESlateVisibility.Collapsed
  else
    return false
  end
end

function UIFullscreenLayerCtrl:FoldOtherPanelAndPopupInAdvance()
  local size = self._showWins:Size()
  if size > 1 then
    for i = 1, size - 1 do
      local windowData = self._showWins:Get(i)
      self:ShowPopWinsByWindowId(false, windowData.windowId)
    end
  end
end

function UIFullscreenLayerCtrl:CollapsedOtherPanelAndPopup()
  self.delayCollapsed = nil
  local size = self._showWins:Size()
  if size > 1 then
    local frontWindowData = self._showWins:Get(size)
    local frontWindow = frontWindowData.panel
    if frontWindow and frontWindow:GetVisibility() == UE4.ESlateVisibility.Collapsed then
      self.delayCollapsed = _G.DelayManager:DelayFrames(1, self.CollapsedOtherPanelAndPopup, self)
      return
    end
    for i = 1, size - 1 do
      local windowData = self._showWins:Get(i)
      self:ShowPopWinsByWindowId(false, windowData.windowId)
      self:DoFoldSpecifiedWindow(windowData)
    end
  end
end

function UIFullscreenLayerCtrl:ShowLastPanelAndPopup()
  local size = self._showWins:Size()
  if size > 1 then
    for i = size - 1, 1, -1 do
      local topWinData = self._showWins:Get(i)
      local success = false
      success = self:UnDoFoldSpecifiedWindow(topWinData)
      success = self:ShowPopWinsByWindowId(true, topWinData.windowId) or success
      if success then
        break
      end
    end
  end
end

function UIFullscreenLayerCtrl:ShowPopWinsByWindowId(bShow, windowId)
  local ret = false
  local popWins = self._relatePopWinsDic[windowId]
  if popWins then
    local size = popWins:Size()
    for j = 1, size do
      local popWinData = popWins:Get(j)
      local success = false
      if bShow then
        success = self:UnDoFoldSpecifiedWindow(popWinData)
      else
        success = self:DoFoldSpecifiedWindow(popWinData)
      end
      ret = ret or success
    end
  end
  return ret
end

return UIFullscreenLayerCtrl
