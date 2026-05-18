local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_ElementInteract_General = Base:Extend("Lua_ElementInteract_General")

function Lua_ElementInteract_General:UpdateData(npcInfo, isReconnect)
  if self.viewObj then
    self:OnLogicStatusChange()
  end
end

function Lua_ElementInteract_General:OnLogicStatusChange()
  Log.Debug("Lua_ElementInteract_General:OnLogicStatusChange", self:GetDebugInfo())
  local ElementInteract = self.viewObj
  if not ElementInteract then
    return nil
  end
  ElementInteract:UpdateBurningState()
end

return Lua_ElementInteract_General
