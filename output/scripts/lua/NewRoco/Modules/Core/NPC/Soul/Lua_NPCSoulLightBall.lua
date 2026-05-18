local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCSoulLightBall = Base:Extend("Lua_NPCSoulLightBall")

function Lua_NPCSoulLightBall:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCSoulLightBall:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:OnReconnect()
  end
end

return Lua_NPCSoulLightBall
