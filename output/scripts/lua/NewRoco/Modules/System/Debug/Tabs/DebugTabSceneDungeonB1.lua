local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabSceneDungeon")
local DebugTabSceneDungeonB1 = Base:Extend("DebugTabSceneDungeonB1")

function DebugTabSceneDungeonB1:Ctor(...)
  self.tabName = "B1"
  Base.Ctor(self, ...)
end

function DebugTabSceneDungeonB1:SetupTabs()
  Base.SetupTabs(self)
end

return DebugTabSceneDungeonB1
