local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabReflection = Base:Extend("DebugTabReflection")

function DebugTabReflection:Ctor()
  Base.Ctor(self)
end

function DebugTabReflection:SetupTabs()
end

function DebugTabReflection:Close()
end

function DebugTabReflection:Open()
end

return DebugTabReflection
