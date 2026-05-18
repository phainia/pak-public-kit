local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCStaticTree = Base:Extend("Lua_NPCStaticTree")

function Lua_NPCStaticTree:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.fruits = {}
end

function Lua_NPCStaticTree:SetCreateNPC(fruit)
  if self.viewObj then
    self.viewObj:SetCreateNPC(fruit)
  else
    table.insert(self.fruits, fruit)
  end
end

function Lua_NPCStaticTree:OnSetViewObj()
  Base.OnSetViewObj(self)
  for _, fruit in pairs(self.fruits) do
    self.viewObj:SetCreateNPC(fruit)
  end
  self.fruits = {}
end

return Lua_NPCStaticTree
