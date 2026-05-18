local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCOre = Base:Extend("Lua_NPCOre")

function Lua_NPCOre:LetViewObjShow()
  if not UE4.UObject.IsValid(self.viewObj) then
    return
  end
  self.viewObj.isCreatedNPCDone = true
  Base.LetViewObjShow(self)
end

return Lua_NPCOre
