local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabSceneDungeon")
local DebugTabSceneDungeonOther = Base:Extend("DebugTabSceneDungeonA1")

function DebugTabSceneDungeonOther:Ctor(...)
  self.tabName = "\229\133\182\229\174\131\229\137\175\230\156\172"
  Base.Ctor(self, ...)
end

function DebugTabSceneDungeonOther:SetupTabs()
  Base.SetupTabs(self)
end

return DebugTabSceneDungeonOther
