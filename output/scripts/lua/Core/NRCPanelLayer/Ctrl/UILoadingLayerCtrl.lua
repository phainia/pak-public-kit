local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local Base = require("Core.NRCPanelLayer.Base.UILayerCtrl")
local UILoadingLayerCtrl = Base:Extend("UILoadingLayerCtrl")
UILoadingLayerCtrl._enableLog = true

function UILoadingLayerCtrl:Ctor(center, type, depth)
  Base.Ctor(self, center, type, depth)
  self._curWin = nil
end

function UILoadingLayerCtrl:Free()
  self:CloseAll()
  self._curWin = nil
end

function UILoadingLayerCtrl:GetWindow(windowId)
  if not windowId or "" == windowId then
    return self._curWin
  end
  if self:IsOpen(windowId) then
    return self._curWin
  end
  return nil
end

function UILoadingLayerCtrl:GetAllWindow()
  return {
    self._curWin
  }
end

function UILoadingLayerCtrl:IsOpen(windowID)
  if self._curWin and self:GetPanelName() == windowID then
    return true
  end
  return false
end

function UILoadingLayerCtrl:GetLayerWindowCount()
  if self._curWin then
    return 1
  end
  return 0
end

function UILoadingLayerCtrl:CheckCanOpen(windowID)
  if self:IsOpen(windowID) then
    return false
  end
  return true
end

function UILoadingLayerCtrl:AddToLayerViewport(windowId, panel, module)
  if self:IsOpen(windowId) then
    return false
  end
  if self._curWin then
    self._curWin:Disable()
  end
  self._curWin = panel
  panel.depth = self.depth
  self:DoAddToViewport(panel, self.depth, true)
end

function UILoadingLayerCtrl:RemoveFromLayerViewport(panelOrWindowId)
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
  return true
end

function UILoadingLayerCtrl:OnPreLoadMap()
  Log.Debug("UILoadingLayerCtrl:OnPreLoadMap", self._curWin)
end

function UILoadingLayerCtrl:OnPostLoadMapWithWorld()
  Log.Debug("UILoadingLayerCtrl:OnPostLoadMapWithWorld", self._curWin)
end

function UILoadingLayerCtrl:CloseAll()
  if self._curWin then
    self:DoCloseWindow(self._curWin)
  end
end

function UILoadingLayerCtrl:ActiveAll()
  if self._curWin and not self:IsWindowActive(self._curWin) then
    self:DoActiveWindow(self._curWin)
  end
end

function UILoadingLayerCtrl:DeactiveAll()
  if self._curWin and not self:IsWindowDeActive(self._curWin) then
    self:DoDeActiveWindow(self._curWin)
  end
end

function UILoadingLayerCtrl:Tick(deltaTime)
end

return UILoadingLayerCtrl
