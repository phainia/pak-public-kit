local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCFarmSeeding = Base:Extend("Lua_NPCFarmSeeding")

function Lua_NPCFarmSeeding:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCFarmSeeding:UpdateData(npcInfo, isReconnect)
  if not (isReconnect and self.viewObj) or self.viewObj.resourceLoaded then
  end
end

return Lua_NPCFarmSeeding
