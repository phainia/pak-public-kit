local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local TipsStatusChecker = Base:Extend("TipsStatusChecker")

function TipsStatusChecker:Ctor()
  Base.Ctor(self)
end

return TipsStatusChecker
