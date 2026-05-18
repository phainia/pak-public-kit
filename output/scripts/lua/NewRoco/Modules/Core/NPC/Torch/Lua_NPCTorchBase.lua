local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCTorchBase = Base:Extend("Lua_NPCTorchBase")

function Lua_NPCTorchBase:UpdateData(npcInfo, isReconnect)
  if self.viewObj then
    self:OnLogicStatusChange()
  end
end

function Lua_NPCTorchBase:OnLogicStatusChange()
  Log.Debug("Lua_NPCBase:OnLogicStatusChange", self:GetDebugInfo())
  local Torch = self.viewObj
  if not Torch then
    return nil
  end
  Torch:UpdateBurningState()
end

return Lua_NPCTorchBase
