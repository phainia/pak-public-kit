local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local WorldCombatSkillEvent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillEvent")
local ResObject = require("NewRoco.Utils.ResObject")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = RocoSkillAction
local HitActorType = {
  None = 0,
  Obstacle = 1,
  Player = 2,
  NPC = 3,
  Thrown_PET = 4
}
local RocoCollisionDetectAction = Base:Extend("RocoCollisionDetectAction")

function RocoCollisionDetectAction:OnActionStart()
  if self:IsSkillEditor() then
    return
  end
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  if not _G.NRCModuleManager:IsModuleActive("CollisionModule") then
    _G.NRCModuleManager:ActiveModule("CollisionModule")
  end
  local caster = self:GetSkill():GetCaster().sceneCharacter
  if not caster or not UE.UObject.IsValid(caster.viewObj) then
    return
  end
  local hitComps = caster.viewObj:GetComponentsByTag(UE4.UPrimitiveComponent, "SkillHit")
  for idx = 1, hitComps:Length() do
    local hitComp = hitComps:Get(idx)
    if self.CollisionProperties.CollisionCompName ~= "None" and hitComp:GetName() ~= self.CollisionProperties.CollisionCompName then
    else
      local finalTransform = UE.UKismetMathLibrary.ComposeTransforms(self.OffsetTransform, hitComp:GetRelativeTransform())
      hitComp:K2_SetRelativeTransform(finalTransform, false, nil, false)
      local collisionComp = NRCModuleManager:DoCmd(CollisionModuleCmd.GetCollisionComp, caster, hitComp)
      if not collisionComp then
        return
      end
      if self.CollisionProperties.FanAngle > 0 then
        collisionComp:BindCollisionEvent(self, self.CollisionProperties.CollisionListenType, self.OnCollision, self.CollisionProperties.CollisionCD, true, {
          FanAngle = self.CollisionProperties.FanAngle
        })
      else
        collisionComp:BindCollisionEvent(self, self.CollisionProperties.CollisionListenType, self.OnCollision, self.CollisionProperties.CollisionCD, true)
      end
    end
  end
  self.HitActors = {}
  self.actionIdx = caster:EnsureComponent(WorldCombatSkillComponent):GetActionIdx()
  caster:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_SUCCESS, self.SkillComplete)
  caster:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.SkillComplete)
  caster:AddEventListener(self, WorldCombatSkillEvent.SKILL_CAST_FAIL, self.SkillComplete)
end

function RocoCollisionDetectAction:SkillComplete(skillId)
  if not self:GetSkill():GetCaster() or skillId ~= self:GetSkill():GetSkillID() then
    return
  end
  if not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local caster = self:GetSkill():GetCaster().sceneCharacter
  caster:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_SUCCESS, self.SkillComplete)
  caster:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_END, self.SkillComplete)
  caster:RemoveEventListener(self, WorldCombatSkillEvent.SKILL_CAST_FAIL, self.SkillComplete)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  collisionModule:RemoveAllCollisionComp(true)
end

function RocoCollisionDetectAction:OnActionEnd()
  if self:IsSkillEditor() then
    return
  end
  if self.ResRequest then
    _G.NRCResourceManager:UnLoadRes(self.ResRequest)
  end
  local skill = self:GetSkill()
  if not skill then
    return
  end
  local ct = skill:GetCaster()
  if not ct then
    return
  end
  local caster = ct.sceneCharacter
  if not caster.collisionComps or #caster.collisionComps <= 0 then
    return
  end
  self:SkillComplete(self:GetSkill():GetSkillID())
  caster.collisionComps = {}
end

function RocoCollisionDetectAction:PreLoadActionResAsync()
  if not self.CollisionProperties then
    return
  end
  local FxPath = ""
  if self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx then
    FxPath = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx:GetLongPackageName()
  end
  if "" == FxPath then
    return
  end
  FxPath = _G.NRCUtils.FormatResPackageNameToFullPath(FxPath)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule then
    return
  end
  local FxRes = collisionModule.HitFxList[FxPath]
  if FxRes then
    return
  end
  self.ResRequest = _G.NRCResourceManager:LoadResAsync(self, FxPath, PriorityEnum.Active_World_Combat_Boss, 10, self.OnResLoadedSuccess, self.OnResLoadedFailed)
end

function RocoCollisionDetectAction:OnResLoadedSuccess(req, asset)
  if not asset then
    Log.Error("RocoCollisionDetectAction:OnResLoadedSuccess Not asset!!!")
    return
  end
  Log.Debug("RocoCollisionDetectAction:OnResLoaded", asset)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule then
    return
  end
  collisionModule:AddHitResCache(req.assetPath, asset)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnSkillResLoaded, req.assetPath, asset)
end

function RocoCollisionDetectAction:OnResLoadedFailed(req, msg)
  Log.Error("RocoCollisionDetectAction:OnResLoadedFailed: ", msg, req.assetPath)
end

function RocoCollisionDetectAction:OnCollision(otherActor, hitResult, lastHitDir)
  local skillObj = self:GetSkill()
  local skillID = skillObj:GetSkillID()
  if not skillObj:GetCaster() then
    return
  end
  local caster = skillObj:GetCaster().sceneCharacter
  local HitType, SceneCharacter = self:ResolveHitResult(otherActor)
  if SceneCharacter == caster then
    Log.Error("caster cast skill collision Detect caster himself!!!")
    return
  end
  if nil == hitResult then
    Log.Error("hitResult is nil!")
    return
  end
  if otherActor then
    Log.Debug(string.format("RocoCollisionDetectAction:OnCollision: otherActor=%s, hitType=%d", otherActor:GetName(), HitType))
  end
  if SceneCharacter then
    if not self.HitActors[SceneCharacter] then
      self.HitActors[SceneCharacter] = 1
    else
      self.HitActors[SceneCharacter] = self.HitActors[SceneCharacter] + 1
    end
    if self.HitActors[SceneCharacter] > self.CollisionProperties.MaxHitCount then
      return
    end
  end
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  local fxPath = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx
  local fxScale = self.CollisionProperties.CollisionPlayer.HitPlayerFxScale
  local fxDuration = self.CollisionProperties.CollisionPlayer.HitPlayerFxDuration
  if HitType == HitActorType.None then
    return
  elseif HitType == HitActorType.Player then
    local skillComp = caster:EnsureComponent(WorldCombatSkillComponent)
    skillComp:OnSkillCollisionAction(caster, SceneCharacter, skillID, self.actionIdx, SceneUtils.ConvertVectorToPoint(lastHitDir), self.CollisionProperties.ImpactForce)
    skillComp:PlayPerformSkill(self:GetHitPlayerPerformSkillClass())
    fxPath = fxPath:GetLongPackageName()
    collisionModule:PlayHitFx(nil, SceneCharacter, fxPath, hitResult.ImpactPoint, lastHitDir, fxScale, true, fxDuration)
    SceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, lastHitDir, self.CollisionProperties.CollisionPlayer.IsHeavyAttack, false, self.CollisionProperties.CollisionPlayer.AttackPerformType)
  elseif HitType == HitActorType.Obstacle then
    fxPath = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstaclePlayFx
    fxScale = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstacleFxScale
    fxDuration = self.collisionAction.CollisionProperties.CollisionObstacle.HitObstacleFxDuration
    local skillComp = caster:EnsureComponent(WorldCombatSkillComponent)
    skillComp:PlayPerformSkill(self:GetHitObstaclePerformSkillClass())
    fxPath = fxPath:GetLongPackageName()
    collisionModule:PlayHitFx(nil, SceneCharacter, fxPath, hitResult.ImpactPoint, lastHitDir, fxScale, true, fxDuration)
  elseif HitType == HitActorType.Thrown_PET then
    local skillComp = caster:EnsureComponent(WorldCombatSkillComponent)
    skillComp:OnSkillCollisionAction(caster, SceneCharacter, skillID, self.actionIdx, SceneUtils.ConvertVectorToPoint(lastHitDir), self.CollisionProperties.ImpactForce)
    skillComp:PlayPerformSkill(self:GetHitPlayerPerformSkillClass())
    fxPath = fxPath:GetLongPackageName()
    collisionModule:PlayHitFx(nil, SceneCharacter, fxPath, hitResult.ImpactPoint, lastHitDir, fxScale, true, fxDuration)
    SceneCharacter:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, lastHitDir, self.CollisionProperties.CollisionPlayer.IsHeavyAttack, false, self.CollisionProperties.CollisionPlayer.AttackPerformType)
  end
end

function RocoCollisionDetectAction:ResolveHitResult(HitActor)
  if not HitActor then
    return HitActorType.None, nil
  end
  local SceneCharacter = HitActor.sceneCharacter
  if not SceneCharacter then
    return HitActorType.Obstacle, nil
  end
  if SceneCharacter.name == "SceneLocalPlayer" then
    return HitActorType.Player, SceneCharacter
  elseif SceneCharacter.IsAThrownPet and SceneCharacter:IsAThrownPet() then
    return HitActorType.Thrown_PET, SceneCharacter
  else
    return HitActorType.NPC, SceneCharacter
  end
end

return RocoCollisionDetectAction
