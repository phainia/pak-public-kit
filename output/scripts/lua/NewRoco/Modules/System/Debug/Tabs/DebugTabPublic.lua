local JsonUtils = require("Common.JsonUtils")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabPublic = Base:Extend("DebugTabPublic")

function DebugTabPublic:Ctor()
  Base.Ctor(self)
end

function DebugTabPublic:SetupTabs()
end

function DebugTabPublic:SaveBtnInfo(name, Path)
end

return DebugTabPublic
