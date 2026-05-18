local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCRainMoai = Base:Extend("Lua_NPCRainMoai")

function Lua_NPCRainMoai:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  self:OnWeatherChange()
end

function Lua_NPCRainMoai:OnWeatherChange()
  if self.viewObj then
    self.viewObj:OnWeatherChange()
  end
end

return Lua_NPCRainMoai
