local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabJourneyQuest = Base:Extend("DebugTabJourneyQuest")

function DebugTabJourneyQuest:Ctor()
  Base.Ctor(self)
end

return DebugTabJourneyQuest
