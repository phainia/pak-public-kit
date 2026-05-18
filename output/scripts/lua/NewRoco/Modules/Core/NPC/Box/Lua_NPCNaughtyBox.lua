local Base = require("NewRoco.Modules.Core.NPC.Box.Lua_NPCBox")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NaughtBoxStateEnum = {}
NaughtBoxStateEnum.InteractType = {
  NORMAL = 0,
  FEAR = 1,
  HAPPY = 2,
  STUN = 3
}
local Lua_NPCNaughtyBox = Base:Extend("Lua_NPCNaughtyBox")

function Lua_NPCNaughtyBox:OnChestFearLogicChanged()
end

function Lua_NPCNaughtyBox:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self.viewObj then
    self.viewObj:SwitchBoxState()
  end
end

function Lua_NPCNaughtyBox:OnLogicStatusChange()
  Base.OnLogicStatusChange(self)
  if self.viewObj then
    self.viewObj:SwitchBoxState()
  end
end

function Lua_NPCNaughtyBox:UpdateData(npcInfo, isReconnect)
  if isReconnect then
    local box = self.viewObj
    if box then
      box:SetBoxOpen(false)
    end
  end
end

return Lua_NPCNaughtyBox
