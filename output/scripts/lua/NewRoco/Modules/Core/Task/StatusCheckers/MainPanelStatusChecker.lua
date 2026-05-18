local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local MainPanelStatusChecker = Base:Extend("MainPanelStatusChecker")

function MainPanelStatusChecker:Ctor()
  Base.Ctor(self)
end

function MainPanelStatusChecker:CheckPass()
  local Pass = false
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule then
    if MainUIModule:HasPanel("LobbyMain") then
      local panel = MainUIModule:GetPanel("LobbyMain")
      if panel and panel.enableView then
        Pass = true
      else
        self:Log("\228\184\187\231\149\140\233\157\162\228\184\141\229\173\152\229\156\168\230\136\150\232\128\133\228\184\141\229\143\175\232\167\129")
      end
    else
      self:Log("\228\184\187\231\149\140\233\157\162\228\184\141\229\173\152\229\156\168")
    end
  else
    self:Log("\228\184\187\231\149\140\233\157\162\230\168\161\229\157\151\228\184\141\229\173\152\229\156\168")
  end
  return Pass
end

function MainPanelStatusChecker:StartCheck()
  self:RegisterGlobalEvent(MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
end

function MainPanelStatusChecker:OnLobbyMainReady()
  self:FireCallback()
end

function MainPanelStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
end

return MainPanelStatusChecker
