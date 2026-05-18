local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCStarGlow = Base:Extend("Lua_NPCStarGlow")

function Lua_NPCStarGlow:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCStarGlow:UpdateData(npcInfo, isReconnect)
  if not (isReconnect and self.viewObj) or self.viewObj.resourceLoaded then
  end
end

return Lua_NPCStarGlow
