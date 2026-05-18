local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCFarmExit = Base:Extend("Lua_NPCFarmExit")

function Lua_NPCFarmExit:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

return Lua_NPCFarmExit
