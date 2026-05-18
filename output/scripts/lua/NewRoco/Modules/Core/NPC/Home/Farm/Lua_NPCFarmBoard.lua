local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCFarmBoard = Base:Extend("Lua_NPCFarmBoard")

function Lua_NPCFarmBoard:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCFarmBoard:UpdateData(npcInfo, isReconnect)
  if not (isReconnect and self.viewObj) or self.viewObj.resourceLoaded then
  end
end

function Lua_NPCFarmBoard:OnLogicStatusChange(ChangeInfo)
  if self.viewObj then
    self.viewObj:OnLogicStatusChange(ChangeInfo)
  end
end

return Lua_NPCFarmBoard
