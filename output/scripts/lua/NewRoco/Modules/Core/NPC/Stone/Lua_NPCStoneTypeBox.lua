local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCStoneTypeBox = Base:Extend("Lua_NPCStoneTypeBox")

function Lua_NPCStoneTypeBox:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateState(true)
  end
end

function Lua_NPCStoneTypeBox:OnLogicStatusChange(ChangeInfo)
  if self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateState(false)
  end
end

function Lua_NPCStoneTypeBox:OnNpcOptionChange(option)
  if self.viewObj and self.viewObj.resourceLoaded then
    self.viewObj:UpdateType()
  end
end

return Lua_NPCStoneTypeBox
