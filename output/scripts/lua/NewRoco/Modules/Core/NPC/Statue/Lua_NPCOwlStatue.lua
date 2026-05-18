local Lua_NPCBase = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Base = Lua_NPCBase
local Lua_NPCOwlStatue = Base:Extend("Lua_NPCOwlStatue")

function Lua_NPCOwlStatue:Ctor()
  Base.Ctor(self)
end

function Lua_NPCOwlStatue:SetCreateNPCTotalNum(num, operator_obj_id)
  Base.SetCreateNPCTotalNum(self, num, operator_obj_id)
  if self.sceneCharacter then
    self.sceneCharacter:SetNotDestroyFlag(false)
  end
end

return Lua_NPCOwlStatue
