require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local BP_NPCMagicStone_C = Base:Extend("BP_NPCMagicStone_C")

function BP_NPCMagicStone_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCMagicStone_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_NPCMagicStone_C
