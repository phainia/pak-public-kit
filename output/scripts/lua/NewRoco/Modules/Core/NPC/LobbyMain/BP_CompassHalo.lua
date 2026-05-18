local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_CompassHalo_C = Base:Extend("BP_CompassHalo_C")

function BP_CompassHalo_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_CompassHalo_C:Init()
  Base.Init(self)
end

function BP_CompassHalo_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_CompassHalo_C
