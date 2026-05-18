local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabStory = Base:Extend("DebugTabStory")

function DebugTabStory:Ctor()
  Base.Ctor(self)
end

return DebugTabStory
