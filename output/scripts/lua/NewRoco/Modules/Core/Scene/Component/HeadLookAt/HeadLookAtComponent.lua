local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local HeadLookAtComponent = NRCClass("HeadLookAtComponent")

function HeadLookAtComponent:LuaIsPlayingSkill(Owner)
  local owner = Owner and Owner.sceneCharacter
  local SkillComp = owner and owner.WorldCombatSkillComponent
  return SkillComp and SkillComp.currentContext ~= nil
end

function HeadLookAtComponent:LuaStartTurn(Owner)
  local TurnComp = Owner and Owner.sceneCharacter and Owner.sceneCharacter.TurnComponent
  if TurnComp then
    self.LastTurnTarget = self.PlayerRotatorCache.Yaw + self.TargetBodyYaw
    TurnComp:StartTurn_S(self.LastTurnTarget, 0.5 / self.BodyYawSpeedScale, true)
  end
end

function HeadLookAtComponent:LuaStopTurn(Owner)
  local TurnComp = Owner and Owner.sceneCharacter and Owner.sceneCharacter.TurnComponent
  if TurnComp then
    TurnComp:StopTurn()
  end
end

function HeadLookAtComponent:LuaUpdateIsTurning(Owner)
  local TurnComp = Owner and Owner.sceneCharacter and Owner.sceneCharacter.TurnComponent
  if TurnComp then
    self.bIsTurning = TurnComp:IsTurning()
  end
end

function HeadLookAtComponent:OnReceiveLookAtData(action)
  if not action then
    Log.Debug("HeadLookAtComponent:OnReceiveLookAtData Action is nil")
    return
  end
  if action.enable then
    local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
    if not SceneModule then
      Log.Debug("HeadLookAtComponent:OnReceiveLookAtData Get SceneModule failed")
      return
    end
    local targetId = action.target_actor_id
    if not SceneModule:CheckIsPlayer(targetId) then
      Log.Debug("HeadLookAtComponent:OnReceiveLookAtData TargetId is not player")
    else
      local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, targetId)
      if player and player.isLocal then
        self:SetAutoLookAtParam(UE4.ELookAtParamType.Target, player.viewObj)
        self:ActiveAutoLookAt(false, nil, nil, true)
      end
    end
  else
    self:ResetAutoLookAt()
  end
end

return HeadLookAtComponent
