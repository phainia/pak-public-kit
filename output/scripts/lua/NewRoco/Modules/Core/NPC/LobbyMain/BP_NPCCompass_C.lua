local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCCompass_C = Base:Extend("BP_NPCCompass_C")

function BP_NPCCompass_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCCompass_C:Init()
  Base.Init(self)
end

function BP_NPCCompass_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_NPCCompass_C
