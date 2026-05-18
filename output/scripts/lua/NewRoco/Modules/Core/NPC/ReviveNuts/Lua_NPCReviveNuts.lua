local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCReviveNuts = Base:Extend("Lua_NPCReviveNuts")

function Lua_NPCReviveNuts:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self.sceneCharacter then
    self.IsActivate = SceneUtils.IsLogicStatusGrownup(self.sceneCharacter)
  else
    self.IsActivate = false
  end
end

function Lua_NPCReviveNuts:OnLogicStatusChange()
  if SceneUtils.IsLogicStatusGrownup(self.sceneCharacter) then
    self.IsActivate = true
  end
  local Nuts = self.viewObj
  if not Nuts then
    return nil
  end
  if SceneUtils.IsLogicStatusGrownup(self.sceneCharacter) then
    Nuts:StateChange()
  end
end

return Lua_NPCReviveNuts
