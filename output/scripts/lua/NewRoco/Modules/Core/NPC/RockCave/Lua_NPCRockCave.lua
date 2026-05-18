local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCRockCave = Base:Extend("Lua_NPCRockCave")

function Lua_NPCRockCave:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCRockCave:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateState()
  end
end

function Lua_NPCRockCave:OnLogicStatusChange()
  if self.viewObj then
    self.viewObj:OnLogicStatusChanged()
  end
end

return Lua_NPCRockCave
