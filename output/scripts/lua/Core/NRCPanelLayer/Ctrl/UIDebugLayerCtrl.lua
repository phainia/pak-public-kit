local Base = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local UIDebugLayerCtrl = Base:Extend("UIDebugLayerCtrl")
UIDebugLayerCtrl._enableLog = true
UIDebugLayerCtrl._windowDepthOffset = 50

function UIDebugLayerCtrl:OnAddToLayerViewport(windowData)
  self:SendEvent(UILayerEvent.DEBUG_LAYER_OPENWINDOW, windowData.windowId)
end

function UIDebugLayerCtrl:OnRemoveFromLayerViewport(windowData)
  self:SendEvent(UILayerEvent.DEBUG_LAYER_CLOSEWINDOW, windowData.windowId)
end

return UIDebugLayerCtrl
