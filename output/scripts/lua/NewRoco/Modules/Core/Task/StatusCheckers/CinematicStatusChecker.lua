local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local CinematicModuleCmd = require("NewRoco.Modules.Core.Cinematic.CinematicModuleCmd")
local CinematicModuleEvent = reload("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")
local Base = StatusCheckerBase
local CinematicStatusChecker = Base:Extend("CinematicStatusChecker")

function CinematicStatusChecker:Ctor()
  Base.Ctor(self)
end

function CinematicStatusChecker:CheckPass()
  local IsCinematicPlaying = _G.NRCModuleManager:DoCmd(CinematicModuleCmd.IsPlaying)
  if IsCinematicPlaying then
    self:Log("\229\189\147\229\137\141\230\156\137\230\173\163\229\156\168\230\146\173\230\148\190\231\154\132Sequence")
    return false
  else
    return true
  end
end

function CinematicStatusChecker:StartCheck()
  self:RegisterGlobalEvent(CinematicModuleEvent.Ended, self.OnCinematicEnded)
end

function CinematicStatusChecker:OnCinematicEnded()
  self:FireCallback()
end

function CinematicStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(CinematicModuleEvent.Ended, self.OnCinematicEnded)
end

return CinematicStatusChecker
