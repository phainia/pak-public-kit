local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_FruitTree = Base:Extend("Lua_FruitTree")

function Lua_FruitTree:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.bGrown = SceneUtils.IsLogicStatusUnlock(self.sceneCharacter)
end

function Lua_FruitTree:OnLogicStatusChange(ChangeInfo)
  Base.OnLogicStatusChange(self, ChangeInfo)
  local FruitTree = self.viewObj
  if not FruitTree then
    return
  end
  if ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED and SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) then
    self.bGrown = true
    FruitTree:UpdateState(true)
  end
end

return Lua_FruitTree
