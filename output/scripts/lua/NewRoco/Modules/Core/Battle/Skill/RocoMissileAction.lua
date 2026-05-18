local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local MissileUtils = require("NewRoco.Modules.Core.Missile.MissileUtils")
local SkillDebugNpc = require("NewRoco.Modules.Core.Scene.Actor.SkillDebugNpc")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = RocoSkillAction
local RocoMissileAction = Base:Extend("RocoMissileAction")

function RocoMissileAction:Ctor()
  Base.Ctor(self)
  if _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  self.MissileData = MissileUtils:NewMissileData()
  _G.NRCModuleManager:RegisterModule("MissileModule", "Type_Core", "NewRoco.Modules.Core.Missile.MissileModuleHead", "NewRoco.Modules.Core.Missile.MissileModule")
  _G.NRCModuleManager:ActiveModule("MissileModule")
  self.missileModule = _G.NRCModuleManager:GetModule("MissileModule")
  self.missileModule.isDebug = true
end

function RocoMissileAction:OnActionStart()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  if not self.CreateParam then
    return
  end
  self:SetActionData()
  local skillObj = self:GetSkill()
  self.caster = SkillDebugNpc(self)
  self.caster.viewObj = skillObj:GetCaster()
  self.target = SkillDebugNpc(self)
  self.target.viewObj = skillObj:GetTargets()[1] or self.caster.viewObj
  self.skillId = skillObj:GetSkillID()
  if self.target.viewObj then
    local hitComps = self.target.viewObj:GetComponentsByTag(UE4.UPrimitiveComponent, "HitedComponent")
    for idx = 1, hitComps:Length() do
      local hitComp = hitComps:Get(idx)
      hitComp:SetCollisionProfileName("SkillHited")
      hitComp:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
      hitComp:SetGenerateOverlapEvents(true)
    end
  end
  local performData = {
    performType = SkillDebugNpc.PerformType.Missile,
    skillPath = nil,
    missileData = {}
  }
  local npcConf = _G.DataConfigManager:GetNpcConf(self.MissileData.NpcId)
  local CreateTransform = UE.FTransform()
  UE.RocoSkillUtils.GetTransformByAttachSetting(self, self.MissileData.CasterInfo, CreateTransform)
  local createPos = CreateTransform.Translation
  if not self:IsSkillEditor() then
    CreateTransform.Translation = createPos + UE.FVector(math.rand(-300, 300), math.rand(-300, 300), math.rand(0, 200))
  end
  if _G.RocoEnv and _G.RocoEnv.IS_EDITOR and self:IsSkillEditor() then
    CreateTransform.Rotation = UE.FRotator(CreateTransform.Rotation:ToRotator().Pitch, CreateTransform.Rotation:ToRotator().Yaw + 90, CreateTransform.Rotation:ToRotator().Roll):ToQuat()
  end
  local TargetTransform = UE.FTransform()
  local socketPos, socketRot
  UE.RocoSkillUtils.GetTransformByAttachSetting(self, self.MissileData.TargetInfo, TargetTransform)
  if TargetTransform == UE.FTransform() then
    local socket = self.MissileData.TargetInfo.FXAttachPointName
    if "None" == socket then
      socket = BattleUtils.GetAttachPointNameByType(self.MissileData.TargetInfo.FXAttachPointType)
    end
    socketPos, socketRot = self.missileModule:GetSocketLocAndDir(self.target.viewObj, socket, self.MissileData.TargetInfo.OffsetTransform)
  end
  self.modelPath = UE.UNRCStatics.GetSoftObjPath(self.NpcClass)
  if not self.modelPath or self.modelPath == "" then
    self.modelPath = _G.DataConfigManager:GetModelConf(npcConf.model_conf).path
  end
  self.missile = SkillDebugNpc.CreateNpc(self, self.caster.viewObj, npcConf, performData, CreateTransform, nil, self.modelPath)
  if self.MissileData.MissileType == Enum.MissileType.AIM_AT_TARGET_POS and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    self.target = nil
  end
  self.missileId = self.missileModule:GetMissileId()
  self.missileModule:CreateMissile(self.missileId, self.caster, self.target, socketPos, self.skillId, self.actionIdx, self.MissileData, nil, nil, self.missile)
end

function RocoMissileAction:OnActionEnd()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  if self.MissileData.MissileType ~= _G.Enum.MissileType.FLY_WITH_CURVE then
    self.missileModule:LaunchMissileByData(nil, self.missileId, self.caster, self.target, nil, self.SkillId, self.MissileData)
  else
    self.missileModule:LaunchCurveMissile(nil, self.missileId, self.caster, self.target, nil, self.SkillId, self, self.MissileData)
  end
end

function RocoMissileAction:OnMissileCreate(missileId)
  local skillObj = self:GetSkill()
  local caster = skillObj:GetCaster().sceneCharacter
  local skillId = skillObj:GetSkillID()
  self.missileModule:RequestLaunchMissile(caster, skillId, missileId)
end

function RocoMissileAction:SetActionData()
  self.MissileData.MissileType = self.MissileType
  local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(self.CreateParam.NpcContentId, true)
  self.MissileData.NpcId = refreshConf.npc_id
  self.MissileData.CasterInfo = self.CasterInfo
  self.MissileData.TargetInfo = self.TargetInfo
  self.MissileData.LandHeight = self.KeepLandFixHeight
  self.MissileData.LifeTime = self.LaunchParam.LifeTime or 5
  self.MissileData.InitSpeed = self.LaunchParam.InitSpeed
  self.MissileData.AccelerateSpeed = self.LaunchParam.AccelerateSpeed
  self.MissileData.MaxSpeed = self.LaunchParam.MaxSpeed
  self.MissileData.AngleSpeed = self.LaunchParam.AngleSpeed
  self.MissileData.TraceTime = self.LaunchParam.TraceTime
  self.MissileData.CancelTraceDist = self.LaunchParam.CancelTraceDist
  self.MissileData.IsKeepLandHeight = self.LaunchParam.IsKeepLandHeight
  self.MissileData.IsHitDestroy = self.LaunchParam.IsHitDestroy
  self.MissileData.HitFxDuration = self.CollisionProperties.CollisionPlayer.HitPlayerFxDuration
  self.MissileData.IsHeavyAttack = self.CollisionProperties.CollisionPlayer.IsHeavyAttack
  self.MissileData.AttackPerformType = self.CollisionProperties.CollisionPlayer.AttackPerformType
  self.MissileData.HitFXScale = self.CollisionProperties.CollisionPlayer.HitPlayerFxScale
  self.MissileData.HitCD = self.CollisionProperties.CollisionCD
  self.MissileData.EffectRadius = self.DestroyParam.EffectRadius
  self.MissileData.ExplodeFX = self.DestroyParam.ExplodeFX
  if self.MissileData.ExplodeFX then
    self.MissileData.ExplodeFX = self.MissileData.ExplodeFX:GetLongPackageName()
  end
  self.MissileData.ExplodeFXScale = self.DestroyParam.ExplodeFXScale
  self.MissileData.ExplodeFxDuration = self.DestroyParam.ExplodeFxDuration
  if self.AudioParams then
    self.MissileData.CreateConfigID = self.AudioParams.CreateConfigID
    self.MissileData.LaunchConfigID = self.AudioParams.LaunchConfigID
    self.MissileData.FlyConfigID = self.AudioParams.FlyConfigID
    self.MissileData.HitEnemyConfigID = self.AudioParams.HitEnemyConfigID
    self.MissileData.HitObstacleConfigID = self.AudioParams.HitObstacleConfigID
  end
  self.MissileData.HitFX = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx
  if self.MissileData.HitFX then
    self.MissileData.HitFX = self.MissileData.HitFX:GetLongPackageName()
  end
  self.MissileData.ImpactForce = self.CollisionProperties.ImpactForce
end

function RocoMissileAction:PreLoadUObjects()
  self.modelPath = UE.UNRCStatics.GetSoftObjPath(self.NpcClass)
  if (not self.modelPath or self.modelPath == "") and self.CreateParam then
    local refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(self.CreateParam.NpcContentId, true)
    if refreshConf then
      local npcConf = _G.DataConfigManager:GetNpcConf(refreshConf.npc_id)
      self.modelPath = _G.DataConfigManager:GetModelConf(npcConf.model_conf).path
    end
  end
  self:AddStringPathToAsyncList(self.modelPath)
  local FxPath
  if not self.CollisionProperties then
    if self.HitParam then
      FxPath = self.HitParam.HitFX:GetLongPackageName()
    end
  elseif self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx then
    FxPath = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx:GetLongPackageName()
  end
  if FxPath then
    self:AddStringPathToAsyncList(FxPath)
  end
end

function RocoMissileAction:PreLoadActionResAsync()
  if not self then
    return
  end
  local FxPath
  if not self.CollisionProperties then
    if self.HitParam then
      FxPath = self.HitParam.HitFX:GetLongPackageName()
    end
  elseif self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx then
    FxPath = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx:GetLongPackageName()
  end
  if not FxPath or "" == FxPath then
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
  local Res = _G.NRCResourceManager:LoadResAsync(self, FxPath, PriorityEnum.Active_World_Combat_Boss, 10, self.OnResLoadedSuccess, self.OnResLoadedFailed)
end

function RocoMissileAction:OnResLoadedSuccess(req, asset)
  if not asset then
    Log.Error("RocoMissileAction:OnResLoadedSuccess Not asset!!!")
    return
  end
  Log.Debug("RocoMissileAction:OnResLoaded", asset)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule then
    return
  end
  collisionModule:AddHitResCache(req.assetPath, asset)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnSkillResLoaded, req.assetPath, asset)
end

function RocoMissileAction:OnResLoadedFailed(req, msg)
  Log.Error("RocoMissileAction:OnResLoadedFailed: ", msg, req.assetPath)
end

return RocoMissileAction
