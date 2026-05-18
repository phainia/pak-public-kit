local WorldCombatActionBase = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local WorldCombatActionUtils = require("NewRoco.Modules.Core.NPC.Actions.WorldCombatActions.WorldCombatActionUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = WorldCombatActionBase
local WorldCombatActionHit = Base:Extend("WorldCombatActionHit")

function WorldCombatActionHit:Ctor(Runner, SkillId, ActionType, ServerInfo)
  Base.Ctor(self, Runner, SkillId, ActionType, ServerInfo)
end

function WorldCombatActionHit:PreExecute()
  Base.PreExecute(self)
  local fxPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos, 1)
  if UE.UKismetMathLibrary.Vector_IsNearlyZero(fxPos) then
    self.enable = false
    return
  end
  self.collisionAction = self:GetSkillActionByGuid(self.ServerInfo.GUID)
end

function WorldCombatActionHit:InternalExecute()
  Base.InternalExecute(self)
  if not (self.Runner and self.ServerInfo) or not self.ServerInfo.skill_id then
    Log.Debug("WorldCombatActionHit:InternalExecute failed!!!", self.Runner, self.ServerInfo, self.ServerInfo.skill_id, self.SkillId, self.ServerInfo.target_id, SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos), self.ServerInfo.GUID, self.ServerInfo.hit_type, self.ServerInfo.block_type, self.ServerInfo.hit_perform_type)
    self:Finish()
    return
  end
  if not self.collisionAction then
    Log.Debug("WorldCombatActionHit:InternalExecute failed, cannot get valid collisionAction from G6Skill by server guid!!!", self.ServerInfo.skill_id)
    self:Finish()
    return
  end
  if not self.enable then
    self:Finish()
    return
  end
  local target = self:GetTargetByServerInfo()
  local hitDir = UE.FRotator(0, self.ServerInfo.hit_point.dir.z / 10, 0):ToVector()
  self.Runner:SendEvent(WorldCombatSkillEvent.SKILL_HIT, target)
  self:PlayHitFx(target, hitDir)
  hitDir:Normalize()
  Log.Debug("WorldCombatActionHit:InternalExecute Success", self.ServerInfo.skill_id, self.ServerInfo.target_id, SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos), SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos), self.ServerInfo.GUID, self.ServerInfo.hit_type, self.ServerInfo.block_type, self.ServerInfo.hit_perform_type)
  local HitType = WorldCombatActionUtils.ResolveHitResult(target)
  local isHeavyAttack = false
  local attackPerformType
  if self.collisionAction.CollisionProperties.CollisionPlayer then
    isHeavyAttack = self.collisionAction.CollisionProperties.CollisionPlayer.IsHeavyAttack
    attackPerformType = self.collisionAction.CollisionProperties.CollisionPlayer.AttackPerformType
  elseif self.collisionAction.CollisionProperties.HitParam then
    isHeavyAttack = self.collisionAction.CollisionProperties.HitParam.IsHeavyAttack
    attackPerformType = self.collisionAction.CollisionProperties.HitParam.AttackPerformType
  end
  local Player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player and Player:IsInTogetherMove() then
    isHeavyAttack = false
    attackPerformType = ProtoEnum.PlayerAttackPerformType.PAPT_Light
  end
  if HitType == WorldCombatActionUtils.DotsHitActorType.None or Player:IsTogetherMove2P() then
    return
  elseif HitType == WorldCombatActionUtils.DotsHitActorType.Player then
    target:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, -hitDir, isHeavyAttack, false, attackPerformType)
  elseif HitType == WorldCombatActionUtils.DotsHitActorType.Thrown_PET then
    target:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, -hitDir, isHeavyAttack, false, attackPerformType)
  end
  if _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.GetCanDrawDebug) then
    local hitPoint = SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos)
    hitDir = SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.dir)
    hitDir:Normalize()
    UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), hitPoint, hitPoint + hitDir * 100.0, 10, UE.FLinearColor(1, 0, 1, 1), 10.0, 2)
    local debugInfo = string.format("%d--%s--%u--%s--%s--%s--%d", self.ServerInfo.skill_id, self.ServerInfo.GUID, target.serverData.base.actor_id, target.serverData.base.name, table.getKeyName(WorldCombatActionUtils.DotsHitActorType, HitType), tostring(isHeavyAttack), attackPerformType)
    UE.UKismetSystemLibrary.Abs_DrawDebugString(_G.UE4Helper.GetCurrentWorld(), hitPoint, debugInfo, nil, UE.FLinearColor(1, 0, 0.5, 1), 10.0)
    Log.Debug("WorldCombatActionHit:InternalExecute", debugInfo)
  end
end

function WorldCombatActionHit:ReleaseDataBeforeRecycle()
  Base.ReleaseDataBeforeRecycle()
end

function WorldCombatActionHit:Finish()
  self.collisionAction = nil
  Base.Finish(self)
end

function WorldCombatActionHit:LoadResource(target)
  if not self.collisionAction then
    Log.Error("WorldCombatActionHit:LoadResource: Cannot get valid collisionAction!!!")
    return
  end
  if not self.collisionAction.CollisionProperties then
    return
  end
  if not self.collisionAction.CollisionProperties.CollisionPlayer then
    return
  end
  local performSkillId = self.collisionAction.CollisionProperties.CollisionPlayer.HitPlayerPerformSkill
  if not target then
    performSkillId = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstaclePerformSkill
  end
  local skillConf = _G.DataConfigManager:GetWorldCombatSkillConf(performSkillId, true)
  if not skillConf or not skillConf.skill_ref then
    return
  end
  local hitPerformSkillPath = NRCUtils.FormatBlueprintAssetPath(skillConf.skill_ref)
  self.hitSkillRequest = NRCResourceManager:LoadResAsync(self, hitPerformSkillPath, PriorityEnum.Active_World_Combat_Boss, 10, self.hitSkillLoadSuccess, self.Finish)
end

function WorldCombatActionHit:hitSkillLoadSuccess(req, asset)
  self:PlayPerformSkill(asset)
end

function WorldCombatActionHit:PlayHitFx(target, hitDir)
  if not (self.collisionAction and self.collisionAction:IsValid()) or not self.collisionAction:IsValidLowLevel() then
    Log.Error("WorldCombatActionHit:PlayHitFx: Cannot get valid collisionAction!!!")
    return
  end
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  local fxPath = self.collisionAction.CollisionProperties.CollisionPlayer.HitPlayerPlayFx
  local fxScale = self.collisionAction.CollisionProperties.CollisionPlayer.HitPlayerFxScale
  local fxDuration = self.collisionAction.CollisionProperties.CollisionPlayer.HitPlayerFxDuration
  if not target then
    fxPath = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstaclePlayFx
    fxScale = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstacleFxScale
    fxDuration = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstacleFxDuration
  end
  if fxPath:IsNull() then
    return
  end
  fxPath = fxPath:GetLongPackageName()
  local fxPos = SceneUtils.ServerPos2ClientPos(self.ServerInfo.hit_point.pos, 1)
  hitDir:Normalize()
  Log.Debug("WorldCombatActionHit:PlayHitFx", self.Runner, target, fxPath, fxPos, hitDir, fxDuration)
  collisionModule:PlayHitFx(self.Runner, target, fxPath, fxPos, hitDir, fxScale, true, fxDuration)
end

function WorldCombatActionHit:PlayPerformSkill(SkillClass)
  if not SkillClass then
    return
  end
  if self.Owner then
    self.Owner:PlayPerformSkill(SkillClass)
  end
  self:Finish()
end

return WorldCombatActionHit
