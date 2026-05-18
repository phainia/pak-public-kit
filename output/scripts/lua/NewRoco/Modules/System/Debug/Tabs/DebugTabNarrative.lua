local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabNarrative = Base:Extend("DebugTabNarrative")

function DebugTabNarrative:Ctor()
  Base.Ctor(self)
end

return DebugTabNarrative
