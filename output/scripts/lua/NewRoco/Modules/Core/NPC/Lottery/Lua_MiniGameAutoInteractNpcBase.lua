local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_MiniGameAutoInteractNpcBase = Base:Extend("Lua_MiniGameAutoInteractNpcBase")

function Lua_MiniGameAutoInteractNpcBase:InitActStatus(optionInfo)
  Base.InitActStatus(self, optionInfo)
end

function Lua_MiniGameAutoInteractNpcBase:UpdateActStatus(optionInfo)
  Base.UpdateActStatus(self, optionInfo)
end

return Lua_MiniGameAutoInteractNpcBase
