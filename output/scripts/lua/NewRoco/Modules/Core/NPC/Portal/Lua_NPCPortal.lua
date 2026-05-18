local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCPortal = Base:Extend("Lua_NPCPortal")

function Lua_NPCPortal:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateState()
  end
end

function Lua_NPCPortal:OnLogicStatusChange()
  if SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) and self.viewObj and not self.viewObj.opened and UE.UObject.IsValid(self.viewObj) then
    self.viewObj:Opening()
    self.viewObj.opened = true
  end
end

return Lua_NPCPortal
