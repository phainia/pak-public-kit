local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCFarmLand = Base:Extend("Lua_NPCFarmLand")

function Lua_NPCFarmLand:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCFarmLand:UpdateData(npcInfo, isReconnect)
  if not (isReconnect and self.viewObj) or self.viewObj.resourceLoaded then
  end
end

function Lua_NPCFarmLand:TryRefreshByNewInfo(newData)
  if self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:TryRefreshByNewInfo(newData)
  end
end

return Lua_NPCFarmLand
