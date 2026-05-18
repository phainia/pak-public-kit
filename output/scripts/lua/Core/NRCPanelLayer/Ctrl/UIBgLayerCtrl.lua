local Base = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local UIBgLayerCtrl = Base:Extend("UIBgLayerCtrl")
UIBgLayerCtrl._enableLog = true
UIBgLayerCtrl._windowDepthOffset = 50

function UIBgLayerCtrl:OnAddToLayerViewport(windowData)
  self:SendEvent(UILayerEvent.BG_LAYER_OPENWINDOW, windowData.windowId)
end

function UIBgLayerCtrl:OnRemoveFromLayerViewport(windowData)
  self:SendEvent(UILayerEvent.BG_LAYER_CLOSEWINDOW, windowData.windowId)
end

return UIBgLayerCtrl
