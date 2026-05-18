local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCPetUnlockBridge = Base:Extend("Lua_NPCPetUnlockBridge")

function Lua_NPCPetUnlockBridge:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj.fakeActive = false
    self.viewObj:UpdateState(true)
  end
end

function Lua_NPCPetUnlockBridge:OnLogicStatusChange(ChangeInfo)
  if self.viewObj then
    self.viewObj:OnLogicStatusChanged()
  end
end

return Lua_NPCPetUnlockBridge
