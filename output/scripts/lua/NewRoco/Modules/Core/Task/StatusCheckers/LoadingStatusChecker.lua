local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local LoadingStatusChecker = Base:Extend("LoadingStatusChecker")

function LoadingStatusChecker:Ctor()
  Base.Ctor(self)
end

function LoadingStatusChecker:CheckPass()
  local Cleared = true
  Cleared = Cleared and self:CheckLayerCleared(Enum.UILayerType.UI_LAYER_LEVEL_LOADING)
  Cleared = Cleared and self:CheckLayerCleared(Enum.UILayerType.UI_LAYER_TOP_WAITTING)
  return Cleared
end

function LoadingStatusChecker:GetLayer(Layer)
  local LayerCenter = _G.NRCPanelManager.layerCenter
  return LayerCenter.layerCtrlDic[Layer]
end

function LoadingStatusChecker:CheckLayerCleared(Layer)
  local LayerControl = self:GetLayer(Layer)
  if not LayerControl then
    return true
  end
  local Windows = LayerControl:GetAllWindow()
  for _, Window in ipairs(Windows) do
    if Window and UE4.UObject.IsValid(Window) and Window.enableView then
      self:Log("\229\189\147\229\137\141\230\156\137Loading\231\149\140\233\157\162", Window:GetName())
      return false
    end
  end
  return true
end

function LoadingStatusChecker:StartCheck()
  self:RegisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
end

function LoadingStatusChecker:OnLoadingClosed()
  if self:CheckPass() then
    self:FireCallback()
  end
end

function LoadingStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
end

return LoadingStatusChecker
