local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local TeleportStatusChecker = Base:Extend("TeleportStatusChecker")

function TeleportStatusChecker:Ctor()
  Base.Ctor(self)
end

function TeleportStatusChecker:CheckPass()
  local Player = self:GetPlayer()
  if not Player then
    return true
  end
  if Player.isTeleporting then
    self:Log("\231\142\169\229\174\182\230\173\163\229\156\168\228\188\160\233\128\129\228\184\173...")
    return false
  else
    return true
  end
end

function TeleportStatusChecker:StartCheck()
  self:RegisterGlobalEvent(SceneEvent.PlayerTeleportFinish, self.OnTeleported)
end

function TeleportStatusChecker:OnTeleported()
  self:FireCallback()
end

function TeleportStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(SceneEvent.PlayerTeleportFinish, self.OnTeleported)
end

function TeleportStatusChecker:GetPlayer()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

return TeleportStatusChecker
