local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCStonePile = Base:Extend("Lua_NPCStonePile")

function Lua_NPCStonePile:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateState()
  end
end

return Lua_NPCStonePile
