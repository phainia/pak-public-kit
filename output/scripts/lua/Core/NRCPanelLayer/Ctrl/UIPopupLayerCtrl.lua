local Base = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local UIPopupLayerCtrl = Base:Extend("UIPopupLayerCtrl")
UIPopupLayerCtrl._windowDepthOffset = 50

function UIPopupLayerCtrl:Ctor(center, type, depth)
  Base.Ctor(self, center, type, depth)
end

function UIPopupLayerCtrl:CalcWindowDepth(dependentPanelName)
  local fullScreenCtrl = self.center and self.center:GetLayerCtrl(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  if fullScreenCtrl then
    if nil ~= dependentPanelName then
      local TargetWinDepth = fullScreenCtrl:GetTargetWinDepth(dependentPanelName)
      if TargetWinDepth then
        return TargetWinDepth + self._windowDepthOffset
      end
    end
    local topDepth = fullScreenCtrl:GetTopPopWinDepth()
    if topDepth then
      return topDepth + self._windowDepthOffset
    end
  end
  return Base.CalcWindowDepth(self)
end

function UIPopupLayerCtrl:AddWindowData(windowId, module, dependentPanelName)
  local windowData = Base.AddWindowData(self, windowId, module, dependentPanelName)
  local fullScreenCtrl = self.center and self.center:GetLayerCtrl(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  if fullScreenCtrl then
    windowData.parentId = fullScreenCtrl:AddPopWin(windowData, dependentPanelName)
  end
  return windowData
end

function UIPopupLayerCtrl:RemoveWindowData(windowId)
  local windowData = Base.RemoveWindowData(self, windowId)
  local fullScreenCtrl = self.center and self.center:GetLayerCtrl(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  if fullScreenCtrl then
    fullScreenCtrl:RemovePopWin(windowData)
  end
  return windowData
end

function UIPopupLayerCtrl:OnAddToLayerViewport(windowData)
  self:SendEvent(UILayerEvent.POPUP_LAYER_OPENWINDOW, windowData.windowId)
end

function UIPopupLayerCtrl:OnRemoveFromLayerViewport(windowData)
  self:SendEvent(UILayerEvent.POPUP_LAYER_CLOSEWINDOW, windowData.windowId)
end

function UIPopupLayerCtrl:CloseAll()
  local fullScreenCtrl = self.center and self.center:GetLayerCtrl(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  if fullScreenCtrl then
    local size = self._showWins:Size()
    for i = size, 1, -1 do
      local windowData = self._showWins:Get(i)
      fullScreenCtrl:RemovePopWin(windowData)
    end
  end
  Base.CloseAll(self)
end

return UIPopupLayerCtrl
