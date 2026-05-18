local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBaseHandy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCFarmEntrance = Base:Extend("Lua_NPCFarmEntrance")

function Lua_NPCFarmEntrance:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCFarmEntrance:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self:RefreshUnlockState()
  end
end

function Lua_NPCFarmEntrance:RefreshUnlockState()
  local obj = self.viewObj
  if not obj then
    return nil
  end
  obj:RefreshUnlockState()
end

function Lua_NPCFarmEntrance:OnLogicStatusChange(ChangeInfo)
  Base.OnLogicStatusChange(self, ChangeInfo)
  if self.viewObj then
    if not ChangeInfo then
      self:RefreshUnlockState()
    elseif ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PLANT_UNLOCK_ENTRY_NPC and ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_ADD and self.viewObj and self.viewObj.StartSkill then
      self.viewObj:StartSkill()
    end
  end
end

return Lua_NPCFarmEntrance
