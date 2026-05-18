local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_Fx_Ripple_C = Base:Extend("BP_Fx_Ripple_C")

function BP_Fx_Ripple_C:Init()
  Base.Init(self)
end

function BP_Fx_Ripple_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_Fx_Ripple_C
