local JsonUtils = require("Common.JsonUtils")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabGlobalSearch = Base:Extend("DebugTabGlobalSearch")

function DebugTabGlobalSearch:Ctor()
  Base.Ctor(self)
end

function DebugTabGlobalSearch:SetupTabs()
end

return DebugTabGlobalSearch
