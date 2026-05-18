local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local OverlapAwareVisibilityComponent = require("NewRoco.Modules.Core.Scene.Component.Visibility.OverlapAwareVisibilityComponent")
local Base = WorldCombatActionBase
local WorldCombatActionPosDirLerp = Base:Extend("WorldCombatActionPosDirLerp")

function WorldCombatActionPosDirLerp:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionPosDirLerp:PreExecute()
  Base.PreExecute(self)
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  self.type = self.ServerInfo.type
  self.targetPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.cast_point.pos)
  local moveComp = self.Runner.viewObj.GetMovementComponent and self.Runner.viewObj:GetMovementComponent() or nil
  if moveComp then
    if moveComp:IsHovering() or moveComp:IsFlying() or moveComp:IsSwimming() or moveComp:IsFalling() then
      self.targetPos = self.targetPos + UE.FVector(0, 0, self.Runner:GetScaledHalfHeight())
      Log.Debug("WorldCombatActionPosDirLerp:PreExecute Lerp boss pos and dir In Air", self.Runner:DebugNPCNameAndID(), moveComp.MovementMode, self.targetPos, self.Runner:GetActorLocation(), self.targetDir, self.Runner:GetForwardVector(), self.ServerInfo.skill_id)
    else
      self.targetPos = self.targetPos + UE.FVector(0, 0, self.Runner:GetScaledHalfHeight())
      if self.Runner.config.genre ~= Enum.ClientNpcType.CNT_BOSS_SKILL_ITEM then
        self.targetPos = SceneUtils.WorldCombatGetPosInLand(self.targetPos, self.Runner, nil, nil, nil, nil, true) or self.targetPos + UE.FVector(0, 0, self.Runner:GetScaledHalfHeight())
      end
      Log.Debug("WorldCombatActionPosDirLerp:PreExecute Lerp boss pos and dir Not In Air", self.Runner:DebugNPCNameAndID(), moveComp.MovementMode, self.targetPos, self.Runner:GetActorLocation(), self.targetDir, self.Runner:GetForwardVector(), self.ServerInfo.skill_id)
    end
  end
  self.targetDir = SceneUtils.ServerPos2ClientRotator(self.ServerInfo.cast_point.dir):ToVector()
  self.posLerpThreshold = self.ServerInfo.pos_threshold
  self.dirLerpThreshold = self.ServerInfo.dir_threshold
  self.lerpDuration = self.ServerInfo.lerp_duration
  self.lerpAnimation = self.ServerInfo.lerp_animation_name
  self.nodeIndex = self.ServerInfo.node_index
  self.skillId = self.ServerInfo.skill_id
  self.GUID = self.ServerInfo.guid
  self.lerpDone = false
  self.finishControlBySelf = true
  self.actionType = WorldCombatActionBase.EActionType.duration
  self.actionDuration = self.lerpDuration
  self.forceFinshWithSkillEnd = false
  if not self.Runner or not self.Runner.viewObj then
    return
  end
  self.Runner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
  self.animComp = self.Runner.viewObj.RocoAnim
end

function WorldCombatActionPosDirLerp:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.Runner.viewObj and self.ServerInfo) or not self.ServerInfo.skill_id then
    self:Finish()
    return
  end
  if not self:CheckBossPosDirNeedLerp() or self.lerpDone then
    local posDirLerpLerpSyncReq = _G.ProtoMessage:newZoneSceneWorldCombatSkillPosLerpSyncReq()
    posDirLerpLerpSyncReq.allow_wait = false
    posDirLerpLerpSyncReq.actor_id = self.Runner:GetServerId()
    posDirLerpLerpSyncReq.info = self.ServerInfo
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_WORLD_COMBAT_SKILL_POS_LERP_SYNC_REQ, posDirLerpLerpSyncReq, self, self.OnPosLerpSyncRsp, false, false)
    Log.Debug("WorldCombatActionPosDirLerp: not need lerp", self.Runner:DebugNPCNameAndID(), self.Runner.config.id, self.lerpDone, (self.targetPos - self.Runner:GetActorLocation()):Size(), self.posLerpThreshold, _G.LuaMathUtils.AngleBetweenVectors(self.Runner:GetForwardVector(), self.targetDir), self.dirLerpThreshold)
    self:Finish()
    return
  end
  _G.NRCModeManager:DoCmd(_G.WorldCombatModuleCmd.AddBossLerpAction, self.Runner, self.targetPos, self.targetDir, self.lerpDuration, self.posLerpThreshold, self.dirLerpThreshold, self.Finish, self)
  self.Runner:EnsureComponent(WorldCombatSkillComponent).inPosDirLerp = true
  if self.animComp then
    self.animComp:PlayAnimByName(self.lerpAnimation)
  end
  Log.Debug("WorldCombatActionPosDirLerp:InternalExecute Lerp boss pos and dir Start", self.Runner:DebugNPCNameAndID(), self.Runner.config.id, self.targetPos, self.Runner:GetActorLocation(), self.targetDir, self.Runner:GetForwardVector())
end

function WorldCombatActionPosDirLerp:Finish()
  if self.Runner then
    Log.Debug("WorldCombatActionPosDirLerp:Finish Lerp boss pos and dir Done", self.Runner:DebugNPCNameAndID(), self.Runner.config.id, self.targetPos, self.Runner:GetActorLocation(), self.targetDir, self.Runner:GetForwardVector())
    if self.animComp and UE.UObject.IsValid(self.animComp) then
      self.animComp:StopAnimByName(self.lerpAnimation)
    end
    self.lerpDone = true
    self.Runner:EnsureComponent(WorldCombatSkillComponent).inPosDirLerp = false
    self.Runner:EnsureComponent(OverlapAwareVisibilityComponent):CheckInBoundAndMarkHidden(true, true, false, -5, true)
  end
  self.animComp = nil
  Base.Finish(self)
end

function WorldCombatActionPosDirLerp:CheckBossPosNeedLerp()
  return (self.targetPos - self.Runner:GetActorLocation()):Size() > self.posLerpThreshold
end

function WorldCombatActionPosDirLerp:CheckBossDirNeedLerp()
  return _G.LuaMathUtils.AngleBetweenVectors(self.Runner:GetForwardVector(), self.targetDir) > self.dirLerpThreshold
end

function WorldCombatActionPosDirLerp:CheckBossPosDirNeedLerp()
  return self:CheckBossPosNeedLerp() or self:CheckBossDirNeedLerp()
end

function WorldCombatActionPosDirLerp:OnPosLerpSyncRsp(rsp)
  Log.Debug("WorldCombatActionPosDirLerp:OnPosLerpSyncRsp")
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("WorldCombatActionPosDirLerp:OnPosLerpSyncRsp", rsp.ret_info.ret_code)
  end
end

return WorldCombatActionPosDirLerp
