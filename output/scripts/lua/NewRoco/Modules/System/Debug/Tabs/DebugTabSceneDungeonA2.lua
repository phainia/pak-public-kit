local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabSceneDungeon")
local DebugTabSceneDungeonA2 = Base:Extend("DebugTabSceneDungeonA2")

function DebugTabSceneDungeonA2:Ctor(...)
  self.tabName = "A2"
  Base.Ctor(self, ...)
end

function DebugTabSceneDungeonA2:SetupTabs()
  Base.SetupTabs(self)
end

return DebugTabSceneDungeonA2
