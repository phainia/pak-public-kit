local SkillPlayer = require("NewRoco.Modules.Core.Battle.Common.SkillPlayer")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BP_BattleDepthCam_C = NRCClass()

function BP_BattleDepthCam_C:MoveToBattleCenterPos()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  local camPos = UE4.FVector(BattleManager.battleRuntimeData.NearbyValidBattleLocation.X, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Y, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Z + 800)
  local lineBegin = UE4.FVector(BattleManager.battleRuntimeData.NearbyValidBattleLocation.X, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Y, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Z + 1)
  local lineEnd = camPos
  local hitResult = LineTraceUtils.HitWorldStatic(lineBegin, lineEnd)
  if hitResult and hitResult.Distance <= 800 and hitResult.Distance - 200 > 0 then
    camPos = UE4.FVector(BattleManager.battleRuntimeData.NearbyValidBattleLocation.X, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Y, BattleManager.battleRuntimeData.NearbyValidBattleLocation.Z + hitResult.Distance - 50)
  end
  Log.Debug("BP_BattleDepthCam_C:MoveToBattleCenterPos:", camPos)
  self:Abs_K2_SetActorLocation_WithoutHit(camPos)
end

function BP_BattleDepthCam_C:SetHiddenActor()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  local playerMy = BattleManager.battlePawnManager:GetPlayerMyTeam()
  local playerEnemy = BattleManager.battlePawnManager:GetPlayerEnemyTeam()
  local playerPets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  local enemyPets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local actors = {}
  for i = 1, #playerPets do
    table.insert(actors, playerPets[i].model)
  end
  for i = 1, #enemyPets do
    table.insert(actors, enemyPets[i].model)
  end
  if playerMy then
    table.insert(actors, playerMy.model)
  end
  if playerEnemy then
    table.insert(actors, playerEnemy.model)
  end
  if localPlayer then
    table.insert(actors, localPlayer.viewObj)
  end
  self.HiddenActors = actors
end

function BP_BattleDepthCam_C:SetActorList(actors)
  self.ShowOnlyActors = actors
end

function BP_BattleDepthCam_C:Update()
  if self.IsValid and not self:IsValid() then
    Log.Error("BP_BattleDepthCam_C:Update  execute Update when BP_BattleDepthCam_C was gced by UE")
    return
  end
  self:UpdateSceneCapture()
  self:SetHiddenActor()
  self:UpdateRT()
end

function BP_BattleDepthCam_C:UpdateClearHiddenActor()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:ClearRvtHiddenActors()
  self:UpdateSceneCapture()
  self:UpdateRT()
end

function BP_BattleDepthCam_C:EditorMoveToBattleCenterPos(pos)
  Log.Debug("EditorMoveToBattleCenterPos:", pos)
  local newPos = UE4.FVector(pos.X, pos.Y, pos.Z + 1000)
  Log.Debug("show loc:", self:K2_GetActorLocation(), self:Abs_K2_GetActorLocation(), newPos)
  self:Abs_K2_SetActorLocation_WithoutHit(newPos)
end

function BP_BattleDepthCam_C:EditorSetHiddenActor(actors)
  self.HiddenActors = actors
end

function BP_BattleDepthCam_C:EditorUpdate()
  Log.Debug("BP_BattleDepthCam_C EditorUpdate")
  self:UpdateSceneCapture()
  self:UpdateRT()
end

return BP_BattleDepthCam_C
