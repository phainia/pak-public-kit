local OnlineState = require("Core.Service.NetManager.OnlineState")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local OnlineStatusChecker = Base:Extend("OnlineStatusChecker")

function OnlineStatusChecker:Ctor()
  Base.Ctor(self)
end

function OnlineStatusChecker:CheckPass()
  local State = _G.ZoneServer:GetOnlineState()
  if State ~= OnlineState.EnteredCell then
    self:Log("Online State\228\184\141\229\175\185", table.getKeyName(OnlineState, State))
    return false
  else
    return true
  end
end

function OnlineStatusChecker:StartCheck()
  self:RegisterGlobalEvent(_G.NRCGlobalEvent.OnOnlineStateChanged, self.OnOnlineStateChanged)
end

function OnlineStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(_G.NRCGlobalEvent.OnOnlineStateChanged, self.OnOnlineStateChanged)
end

function OnlineStatusChecker:OnOnlineStateChanged(OldState, NewState, DisState)
  Log.Debug("OnlineStatusChecker:OnOnlineStateChanged", OldState, NewState)
  if NewState ~= OnlineState.EnteredCell then
    return
  end
  self:FireCallback()
end

return OnlineStatusChecker
