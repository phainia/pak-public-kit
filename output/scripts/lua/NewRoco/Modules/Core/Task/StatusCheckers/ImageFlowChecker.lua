local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local TaskModuleCmd = require("NewRoco.Modules.Core.Task.TaskModuleCmd")
local TaskModuleEvent = reload("NewRoco.Modules.Core.Task.TaskModuleEvent")
local Base = StatusCheckerBase
local ImageFlowChecker = Base:Extend("ImageFlowChecker")

function ImageFlowChecker:Ctor()
  Base.Ctor(self)
end

function ImageFlowChecker:CheckPass()
  local IsImageFlow = TaskModuleCmd and NRCModeManager:DoCmd(TaskModuleCmd.IsImageFlowPlaying)
  if IsImageFlow then
    self:Log("\229\189\147\229\137\141\230\173\163\229\156\168\230\146\173\230\148\190\231\154\132\229\155\190\231\137\135\230\181\129\231\168\139")
    return false
  end
  return true
end

function ImageFlowChecker:StartCheck()
end

function ImageFlowChecker:EndCheck()
end

function ImageFlowChecker:OnImageFlowEnded()
end

return ImageFlowChecker
