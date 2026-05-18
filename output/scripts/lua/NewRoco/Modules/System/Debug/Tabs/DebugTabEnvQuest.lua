local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabEnvQuest = Base:Extend("DebugTabEnvQuest")

function DebugTabEnvQuest:Ctor()
  Base.Ctor(self)
end

return DebugTabEnvQuest
