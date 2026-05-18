local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCSuitcase_C = Base:Extend("BP_NPCSuitcase_C")

function BP_NPCSuitcase_C:Init()
  Base.Init(self)
end

function BP_NPCSuitcase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return BP_NPCSuitcase_C
