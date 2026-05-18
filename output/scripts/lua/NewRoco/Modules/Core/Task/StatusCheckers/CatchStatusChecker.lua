local PlayerModuleCmd = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleCmd")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local CatchStatusChecker = Base:Extend("CatchStatusChecker")

function CatchStatusChecker:Ctor()
  Base.Ctor(self)
end

function CatchStatusChecker:CheckPass()
  local Player = self:GetPlayer()
  if not Player then
    return false
  end
  local IsCatching = Player.ThrowManagementComponent:IsCatching()
  if IsCatching then
    self:Log("\229\189\147\229\137\141\230\173\163\229\156\168\230\141\149\230\141\137\228\184\173...")
    return false
  else
    return true
  end
end

function CatchStatusChecker:StartCheck()
  self:RegisterGlobalEvent(NPCModuleEvent.CatchEnd, self.OnCatchEnd)
end

function CatchStatusChecker:OnCatchEnd()
  self:FireCallback()
end

function CatchStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(NPCModuleEvent.CatchEnd, self.OnCatchEnd)
end

function CatchStatusChecker:GetPlayer()
  local Player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player
end

return CatchStatusChecker
