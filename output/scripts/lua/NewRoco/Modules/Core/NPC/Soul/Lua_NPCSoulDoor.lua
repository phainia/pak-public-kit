local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCSoulDoor = Base:Extend("Lua_NPCSoulDoor")

function Lua_NPCSoulDoor:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCSoulDoor:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:OnReconnect()
  end
end

return Lua_NPCSoulDoor
