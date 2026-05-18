local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCSaplingBase = Base:Extend("Lua_NPCSaplingBase")

function Lua_NPCSaplingBase:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.fruits = {}
  if self.sceneCharacter then
    self.Grownup = SceneUtils.IsLogicStatusGrownup(self.sceneCharacter)
  else
    self.Grownup = false
  end
end

function Lua_NPCSaplingBase:SetCreateNPC(fruit)
  local Sapling = self.viewObj
  if Sapling then
    if not Sapling.bIsSeeding then
      Sapling:SetCreatedNPC(fruit)
    else
      Sapling:CacheCreatedNPC(fruit)
    end
  else
    table.insert(self.fruits, fruit)
  end
end

function Lua_NPCSaplingBase:OnSetViewObj()
  Base.OnSetViewObj(self)
  local Sapling = self.viewObj
  Sapling.bIsSeeding = not self.Grownup
  Sapling:SetSaplingStatus()
  for _, fruit in pairs(self.fruits) do
    Sapling:SetCreatedNPC(fruit)
  end
end

return Lua_NPCSaplingBase
