local Class = _G.MakeSimpleClass
local UICommonLayerCtrl = require("Core.NRCPanelLayer.Base.UICommonLayerCtrl")
local UIBgLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UIBgLayerCtrl")
local UIDebugLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UIDebugLayerCtrl")
local UIFullscreenLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UIFullscreenLayerCtrl")
local UIMainLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UIMainLayerCtrl")
local UIPopupLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UIPopupLayerCtrl")
local UITopLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UITopLayerCtrl")
local UILoadingLayerCtrl = require("Core.NRCPanelLayer.Ctrl.UILoadingLayerCtrl")
local EventDispatcher = require("Common.EventDispatcher")
local UILayerCtrlCenter = Class("UILayerHelper")
UILayerCtrlCenter.ENUM_LAYER = {
  BG = 5000,
  MAIN = 10000,
  DIALOGUE = 15000,
  DIALOGUE_OVERLAY = 16000,
  FULLSCREEN = 20000,
  POPUP = 30000,
  TOP = 80000,
  GUIDANCE = 81000,
  GLOBAL_BLACK = 82000,
  TOP_LOADING = 85000,
  TOP_MSG = 90000,
  TOP_WAITTING = 95000,
  TOP_ONLY_FOR_NETWORK = 96000,
  SCREEN_CLICK_VFX = 99999,
  DEBUG = 100000,
  TOP_MARK = 105000
}

function UILayerCtrlCenter:Ctor(name)
  self.name = name or "UILayerCtrlCenter"
  self:Init()
end

function UILayerCtrlCenter:Init()
  EventDispatcher():Attach(self)
  self.layerCtrlDic = {}
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_BG] = UIBgLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_BG, UILayerCtrlCenter.ENUM_LAYER.BG)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_DEBUG] = UIDebugLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_DEBUG, UILayerCtrlCenter.ENUM_LAYER.DEBUG)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_FULLSCREEN] = UIFullscreenLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_FULLSCREEN, UILayerCtrlCenter.ENUM_LAYER.FULLSCREEN)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_MAIN] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_MAIN, UILayerCtrlCenter.ENUM_LAYER.MAIN)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_DIALOGUE] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_DIALOGUE, UILayerCtrlCenter.ENUM_LAYER.DIALOGUE)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_DIALOGUE_OVERLAY] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_DIALOGUE_OVERLAY, UILayerCtrlCenter.ENUM_LAYER.DIALOGUE_OVERLAY)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_POPUP] = UIPopupLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_POPUP, UILayerCtrlCenter.ENUM_LAYER.POPUP)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_TOP] = UITopLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_TOP, UILayerCtrlCenter.ENUM_LAYER.TOP)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_TOP_WAITTING] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_TOP_WAITTING, UILayerCtrlCenter.ENUM_LAYER.TOP_WAITTING)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_TOP_LOADING] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_TOP_LOADING, UILayerCtrlCenter.ENUM_LAYER.TOP_LOADING)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_TOP_MSG] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_TOP_MSG, UILayerCtrlCenter.ENUM_LAYER.TOP_MSG)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_LEVEL_LOADING] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_LEVEL_LOADING, UILayerCtrlCenter.ENUM_LAYER.TOP_LOADING)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_TOP_MARK] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_TOP_MARK, UILayerCtrlCenter.ENUM_LAYER.TOP_MARK)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_GLOBAL_BLACK] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_GLOBAL_BLACK, UILayerCtrlCenter.ENUM_LAYER.GLOBAL_BLACK)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_GUIDANCE] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_GUIDANCE, UILayerCtrlCenter.ENUM_LAYER.GUIDANCE)
  self.layerCtrlDic[_G.Enum.UILayerType.UI_LAYER_ONLY_FOR_NETWORK] = UICommonLayerCtrl(self, _G.Enum.UILayerType.UI_LAYER_ONLY_FOR_NETWORK, UILayerCtrlCenter.ENUM_LAYER.TOP_ONLY_FOR_NETWORK)
  if self.layerCtrlDic then
    for k, v in pairs(self.layerCtrlDic) do
      v:Init()
    end
  end
end

function UILayerCtrlCenter:Free()
  if self.layerCtrlDic then
    for k, v in pairs(self.layerCtrlDic) do
      v:Free()
    end
  end
end

function UILayerCtrlCenter:Tick(deltaTime)
  if self.layerCtrlDic then
    for k, v in pairs(self.layerCtrlDic) do
      v:Tick(deltaTime)
    end
  end
end

function UILayerCtrlCenter:CheckCanOpen(panelData)
  if panelData then
    local LayerCtrl = self:GetLayerCtrl(panelData.panelLayer)
    if LayerCtrl and LayerCtrl:CheckCanOpen(panelData.panelName) then
      return true
    end
  end
  return false
end

function UILayerCtrlCenter:GetLayerWindowCount(panelLayer)
  if panelLayer then
    local LayerCtrl = self:GetLayerCtrl(panelLayer)
    if LayerCtrl then
      return LayerCtrl:GetLayerWindowCount()
    end
  end
  return 0
end

function UILayerCtrlCenter:AddToLayerViewport(panel, module)
  if panel and panel.panelData then
    local panelData = panel.panelData
    local LayerCtrl = self:GetLayerCtrl(panelData.panelLayer)
    if LayerCtrl then
      LayerCtrl:AddToLayerViewport(panelData.panelName, panel, module)
    else
    end
  else
  end
end

function UILayerCtrlCenter:RemoveFromLayerViewport(panel)
  if panel and panel.panelData then
    local panelData = panel.panelData
    local LayerCtrl = self:GetLayerCtrl(panelData.panelLayer)
    if LayerCtrl then
      LayerCtrl:RemoveFromLayerViewport(panelData.panelName)
    else
    end
  else
  end
end

function UILayerCtrlCenter:RemoveFromLayerViewportByNameAndType(panelName, layerType)
  if layerType then
    local LayerCtrl = self:GetLayerCtrl(layerType)
    if LayerCtrl then
      LayerCtrl:RemoveFromLayerViewport(panelName)
    end
  end
end

function UILayerCtrlCenter:GetLayerCtrl(LayerType)
  if LayerType then
    return self.layerCtrlDic[LayerType]
  end
end

function UILayerCtrlCenter:GetDebugData()
  local UILayerTypeDic = {}
  for str, v in pairs(Enum.UILayerType) do
    UILayerTypeDic[v] = str
  end
  local debugData = {}
  for k, v in pairs(self.layerCtrlDic) do
    local data = v:GetDebugData()
    if data and next(data) then
      local layerTypeStr = UILayerTypeDic[k] or k
      table.insert(debugData, {
        layerType = layerTypeStr,
        depth = v.depth,
        showWins = data
      })
    end
  end
  table.sort(debugData, function(a, b)
    return a.depth < b.depth
  end)
  return debugData
end

return UILayerCtrlCenter
