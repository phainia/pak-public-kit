local Base = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local UITopLayerCtrl = Base:Extend("UITopLayerCtrl")
UITopLayerCtrl._enableLog = true
UITopLayerCtrl._windowDepthOffset = 50

function UITopLayerCtrl:OnAddToLayerViewport(windowData)
  self:SendEvent(UILayerEvent.TOP_LAYER_OPENWINDOW, windowData.windowId)
end

function UITopLayerCtrl:OnRemoveFromLayerViewport(windowData)
  self:SendEvent(UILayerEvent.TOP_LAYER_CLOSEWINDOW, windowData.windowId)
end

return UITopLayerCtrl
