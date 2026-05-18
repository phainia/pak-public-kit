local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Lua_NPCDGGate = Base:Extend("Lua_NPCDGGate")

function Lua_NPCDGGate:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function Lua_NPCDGGate:OnSetViewObj()
  Base.OnSetViewObj(self)
  local obj = self.viewObj
  if not obj then
    return nil
  end
  obj:SetPhysicsSettings()
  self:RefreshUnlockState()
end

function Lua_NPCDGGate:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.viewObj and self.viewObj.resourceLoaded then
    self:RefreshUnlockState()
  end
end

function Lua_NPCDGGate:RefreshUnlockState()
  local obj = self.viewObj
  if not obj then
    return nil
  end
  obj.IsUnlock = SceneUtils.IsLogicStatusUnlock(self.sceneCharacter)
  if SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) == true then
    if not obj.IsPlaying then
      obj:PlayIdleEndEffect()
    end
  elseif SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) == false and not obj.IsPlaying then
    obj:PlayIdleStartEffect()
  end
end

function Lua_NPCDGGate:OnLogicStatusChange(ChangeInfo)
  Base.OnLogicStatusChange(self, ChangeInfo)
  if not self.sceneCharacter then
    return
  end
  if not ChangeInfo then
    self:RefreshUnlockState()
  elseif ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED and ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_REMOVE and self.viewObj and not self.viewObj.IsPlaying and self.viewObj.PlaySkill then
    self.viewObj:PlaySkill()
  end
end

return Lua_NPCDGGate
