local FunctionBanModuleEvent = require("NewRoco.Modules.System.FunctionBan.FunctionBanModuleEvent")
local FunctionBanUIController = {}
FunctionBanUIController.__index = FunctionBanUIController
setmetatable(FunctionBanUIController, {
  __call = function(cls)
    local instance = {}
    setmetatable(instance, FunctionBanUIController)
    instance:_new()
    return instance
  end
})

function FunctionBanUIController:_new()
  self.entranceWidgets = {}
  self.customCallbacks = {}
end

function FunctionBanUIController:RegisterWidget(funcId, widget)
  if not funcId or not widget then
    return
  end
  local existsWidgets = self.entranceWidgets[funcId]
  if existsWidgets then
    if not table.contains(existsWidgets, widget) then
      table.insert(existsWidgets, widget)
    end
  else
    self.entranceWidgets[funcId] = _G.MakeWeakTable({widget}, "v")
  end
end

function FunctionBanUIController:RegisterCustomCallback(funcId, callback, callbackSelf, ...)
  if not funcId or not callback then
    return
  end
  local functor = _G.MakeWeakFunctor(callbackSelf, callback, ...)
  local existsCallbacks = self.customCallbacks[funcId]
  if existsCallbacks then
    if not table.contains(existsCallbacks, functor) then
      table.insert(existsCallbacks, functor)
    end
  else
    self.customCallbacks[funcId] = {functor}
  end
end

function FunctionBanUIController:UnregisterWidget(funcId, widget)
  if not funcId or not widget then
    return
  end
  local existsWidgets = self.entranceWidgets[funcId]
  if existsWidgets then
    table.removeValue(existsWidgets, widget)
    if 0 == #existsWidgets then
      self.entranceWidgets[funcId] = nil
    end
  end
end

function FunctionBanUIController:UnregisterCustomCallback(funcId, callback, callbackSelf)
  if not funcId or not callback then
    return
  end
  local functor = _G.MakeWeakFunctor(callbackSelf, callback)
  local existsCallbacks = self.customCallbacks[funcId]
  if existsCallbacks then
    table.removeValue(existsCallbacks, functor)
    if 0 == #existsCallbacks then
      self.customCallbacks[funcId] = nil
    end
  end
end

function FunctionBanUIController:Activate()
  _G.NRCEventCenter:RegisterEvent("FunctionBanUIController", self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.OnUIFuncVisibilityChangeHandler)
  for funcId, _ in pairs(self.entranceWidgets) do
    local bHide = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, funcId)
    self:OnUIFuncVisibilityChangeHandler(funcId, bHide)
  end
end

function FunctionBanUIController:Deactivate()
  _G.NRCEventCenter:UnRegisterEvent(self, FunctionBanModuleEvent.OnUIFuncVisibilityChange, self.OnUIFuncVisibilityChangeHandler)
end

function FunctionBanUIController:OnUIFuncVisibilityChangeHandler(funcId, bHide)
  local existsWidgets = self.entranceWidgets[funcId]
  if existsWidgets then
    for _, widget in ipairs(existsWidgets) do
      if widget and UE4.UObject.IsValid(widget) then
        widget:SetVisibility(bHide and UE4.ESlateVisibility.Collapsed or UE.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
  local existsCallbacks = self.customCallbacks[funcId]
  if existsCallbacks then
    for _, functor in ipairs(existsCallbacks) do
      functor(funcId, bHide)
    end
  end
end

return FunctionBanUIController
