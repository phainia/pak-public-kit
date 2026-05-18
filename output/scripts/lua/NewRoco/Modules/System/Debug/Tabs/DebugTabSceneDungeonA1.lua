local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabSceneDungeon")
local DebugTabSceneDungeonA1 = Base:Extend("DebugTabSceneDungeonA1")

function DebugTabSceneDungeonA1:Ctor(...)
  self.tabName = "A1"
  Base.Ctor(self, ...)
end

function DebugTabSceneDungeonA1:SetupTabs()
  Base.SetupTabs(self)
end

return DebugTabSceneDungeonA1
