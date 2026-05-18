local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local FastLoadingStatusChecker = Base:Extend("FastLoadingStatusChecker")

function FastLoadingStatusChecker:Ctor()
  Base.Ctor(self)
end

function FastLoadingStatusChecker:CheckPass()
  local Module = _G.NRCModuleManager:GetModule("LoadingUIModule")
  if not Module then
    return true
  end
  local HasPanel = Module:HasPanel("UMG_FastLoadingUI")
  if not HasPanel then
    return true
  end
  local Panel = Module:GetPanel("UMG_FastLoadingUI")
  if not Panel then
    return true
  end
  if not Panel.enableView then
    return true
  end
  if Panel:CheckFxPlayedFlag() then
    return true
  end
  return false
end

function FastLoadingStatusChecker:StartCheck()
  self:RegisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  self:RegisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_PRECLOSED, self.OnLoadingClosed)
end

function FastLoadingStatusChecker:OnLoadingClosed()
  if self:CheckPass() then
    self:FireCallback()
  end
end

function FastLoadingStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  self:UnregisterGlobalEvent(LoadingUIModuleEvent.LOADING_UI_PRECLOSED, self.OnLoadingClosed)
end

return FastLoadingStatusChecker
