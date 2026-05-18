local Lua_NPCBase = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local LuaNPCFactory = {}
LuaNPCFactory.Registry = {}

function LuaNPCFactory:Get(url)
  local LuaNPCClass = LuaNPCFactory.Registry[url]
  if LuaNPCClass then
    return LuaNPCClass()
  else
    return Lua_NPCBase()
  end
end

return LuaNPCFactory
