local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local Base = require("Core.NRCPanelLayer.Base.UILayerCtrl")
local UIMainLayerCtrl = Base:Extend("UIMainLayerCtrl")
UIMainLayerCtrl._enableLog = true

function UIMainLayerCtrl:Ctor(center, type, depth)
  Base.Ctor(self, center, type, depth)
  self._curWin = nil
end

function UIMainLayerCtrl:Free()
  self:CloseAll()
  self._curWin = nil
end

function UIMainLayerCtrl:GetWindow(windowId)
  if not windowId or "" == windowId then
    return self._curWin
  end
  if self:IsOpen(windowId) then
    return self._curWin
  end
  return nil
end

function UIMainLayerCtrl:GetAllWindow()
  return {
    self._curWin
  }
end

function UIMainLayerCtrl:IsOpen(windowID)
  if self._curWin and self:GetPanelName() == windowID then
    return true
  end
  return false
end

function UIMainLayerCtrl:GetLayerWindowCount()
  if self._curWin then
    return 1
  end
  return 0
end

function UIMainLayerCtrl:CheckCanOpen(windowID)
  if self:IsOpen(windowID) then
    return false
  end
  return true
end

function UIMainLayerCtrl:AddToLayerViewport(windowId, panel, module)
  if self:IsOpen(windowId) then
    return false
  end
  if self._curWin then
    self:DoCloseWindow(self._curWin)
  end
  self._curWin = panel
  panel.depth = self.depth
  self:DoAddToViewport(panel, self.depth, true)
  self:SendEvent(UILayerEvent.MAIN_LAYER_OPENWINDOW, panel)
end

function UIMainLayerCtrl:RemoveFromLayerViewport(panelOrWindowId)
  if not self._curWin then
    return false
  end
  if type(panelOrWindowId) == "string" then
    Log.Debug(tostring(self._curWin.panelName))
    Log.Debug(tostring(panelOrWindowId))
    if self:GetPanelName(self._curWin) ~= panelOrWindowId then
      return false
    end
  elseif self._curWin ~= panelOrWindowId then
    return false
  end
  local windowId = self:GetPanelName(self._curWin)
  self:DoRemoveFromViewport(self._curWin)
  self._curWin = nil
  self:SendEvent(UILayerEvent.MAIN_LAYER_CLOSEWINDOW, windowId)
  return true
end

function UIMainLayerCtrl:CloseAll()
  if self._curWin then
    self:DoCloseWindow(self._curWin)
  end
end

function UIMainLayerCtrl:ActiveAll()
  if self._curWin and not self:IsWindowActive(self._curWin) then
    self:DoActiveWindow(self._curWin)
  end
end

function UIMainLayerCtrl:DeactiveAll()
  if self._curWin and not self:IsWindowDeActive(self._curWin) then
    self:DoDeActiveWindow(self._curWin)
  end
end

function UIMainLayerCtrl:Tick(deltaTime)
end

return UIMainLayerCtrl
