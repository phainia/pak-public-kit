local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local Base = RocoSkillAction
local RocoWorldCombatRcdAction = Base:Extend("RocoWorldCombatRcdAction")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")

function RocoWorldCombatRcdAction:OnActionStart()
  Log.Debug("RocoWorldCombatRcdAction:OnActionStart")
  local IsInOfflineMode = false
  if _G.WorldCombatModuleCmd and _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    IsInOfflineMode = true
  end
  if self:IsSkillEditor() then
    return
  elseif _G.WorldCombatModuleCmd and not IsInOfflineMode then
    return
  end
  local target = self.Overridden.GetActorByActorInfo(self, self.TargetInfo.TargetActorInfo)
  target = target or self:GetDefaultTargetActor()
  if not target then
    return
  end
  self:ActionStartProcess(target:Abs_K2_GetActorLocation(), nil, false, IsInOfflineMode)
end

function RocoWorldCombatRcdAction:OnActionEnd()
  Log.Debug("RocoWorldCombatRcdAction:OnActionEnd")
  if self:IsSkillEditor() then
    return
  elseif _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  self:ActionEndProcess()
end

function RocoWorldCombatRcdAction:OnActionTick(DeltaTime)
  if self:IsSkillEditor() then
    return
  elseif _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local ignoreActors = UE.TArray(UE.AActor)
  self:ActionTickProcess(DeltaTime, ignoreActors)
end

function RocoWorldCombatRcdAction:OnRayBlocked(BlockActor, HitDir)
end

function RocoWorldCombatRcdAction:OnExplodeActor(InActor, HitCount)
  Log.Debug(string.format("RocoWorldCombatRcdAction:OnHitActor#0: %s, %d", InActor:GetName(), HitCount))
  if self:IsSkillEditor() or not InActor then
    return
  end
end

function RocoWorldCombatRcdAction:PreLoadActionResAsync()
  if not self.CollisionProperties then
    return
  end
  local FxPath = self.CollisionProperties.CollisionPlayer.HitPlayerPlayFx:GetLongPackageName()
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

function RocoWorldCombatRcdAction:OnResLoadedSuccess(req, asset)
  if not asset then
    Log.Error("RocoWorldCombatRcdAction:OnResLoadedSuccess Not asset!!!")
    return
  end
  Log.Debug("RocoWorldCombatRcdAction:OnResLoaded", asset)
  local collisionModule = NRCModuleManager:GetModule("CollisionModule")
  if not collisionModule then
    return
  end
  collisionModule:AddHitResCache(req.assetPath, asset)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.OnSkillResLoaded, req.assetPath, asset)
end

function RocoWorldCombatRcdAction:OnResLoadedFailed(req, msg)
  Log.Error("RocoWorldCombatRcdAction:OnResLoadedFailed: ", msg, req.assetPath)
end

return RocoWorldCombatRcdAction
