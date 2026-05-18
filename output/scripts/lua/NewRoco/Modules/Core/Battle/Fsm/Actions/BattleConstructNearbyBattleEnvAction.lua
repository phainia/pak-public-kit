local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleConstructNearbyBattleEnvAction = Base:Extend("BattleConstructNearbyBattleEnvAction")

function BattleConstructNearbyBattleEnvAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleConstructNearbyBattleEnvAction:OnEnter(value)
  Log.Debug("BattleConstructNearbyBattleEnvAction OnEnter 1")
  self.vBattleField = self.BattleManager.vBattleField
  if not self.vBattleField:IsBattleFieldConfValid() then
    Log.Error("BattleConstructNearbyBattleEnvAction:OnEnter battleFieldConf is not valid \229\156\186\230\153\175\229\136\157\229\167\139\229\140\150\233\148\153\232\175\175\228\186\134")
    return
  end
  local location = BattleManager.battleRuntimeData.NearbyValidBattleLocation
  local rotateAngle = BattleManager.battleRuntimeData.NearbyValidBattleRotation
  self:MoveBattleFieldToLocation(location, rotateAngle)
  if BattleUtils.IsSky() then
    location.Z = location.Z + BattleConst.SkyPlatformHeight
  end
  local battleFieldType = 0
  if BattleUtils.IsDeepWater() then
    battleFieldType = 1
  elseif BattleUtils.IsSky() then
    battleFieldType = 2
  end
  BattleManager.vBattleField:SpawnBattleFieldPlatform(battleFieldType)
  local teamateTArr = self.vBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_TEAM)
  if teamateTArr then
    for i = 1, teamateTArr:Length() do
      local actorMyPet = teamateTArr:Get(i)
      local validPos = self:MoveSpawnPointToValidLocationByLine(actorMyPet, nil)
    end
  end
  local enemyTArr = self.vBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_ENEMY)
  if enemyTArr then
    for i = 1, enemyTArr:Length() do
      local actorEnemyPet = enemyTArr:Get(i)
      local validPos = self:MoveSpawnPointToValidLocationByLine(actorEnemyPet, nil)
    end
  end
  local myPlayerPos = self.vBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_TEAM, true)
  if myPlayerPos then
    for i = 1, myPlayerPos:Length() do
      local actorMyPlayer = myPlayerPos:Get(i)
      local validPos = self:MoveSpawnPointToValidLocationByLine(actorMyPlayer, nil)
    end
  end
  local enemyPlayerPos = self.vBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_ENEMY, true)
  if enemyPlayerPos then
    for i = 1, enemyPlayerPos:Length() do
      local actorEnemyPlayer = enemyPlayerPos:Get(i)
      local validPos = self:MoveSpawnPointToValidLocationByLine(actorEnemyPlayer, nil)
    end
  end
  self:Finish()
end

function BattleConstructNearbyBattleEnvAction:MoveBattleFieldToLocation(location, rotateAngle)
  Log.Debug("BattleConstructNearbyBattleEnvAction OnEnter:", location)
  BattleManager.vBattleField:MoveToLocation(location, rotateAngle)
end

function BattleConstructNearbyBattleEnvAction:MoveSpawnPointToValidLocation(actor)
  local NavMeshObj = BattleEnv.RecastNavMesh_Default
  Log.Debug("BattleConstructNearbyBattleEnvAction MoveSpawnPointToValidLocation NavMeshObj:", type(NavMeshObj), actor:GetName(), actor:Abs_K2_GetActorLocation())
  local QueryExtent = UE4.FVector(0, 0, 40000)
  local actorLocation = actor:Abs_K2_GetActorLocation()
  local HitLocation, HitResult = UE4.UNavigationSystemV1.Abs_K2_ProjectPointToNavigation(UE4Helper.GetCurrentWorld(), actorLocation, nil, NavMeshObj, nil, QueryExtent)
  if HitResult and HitLocation then
    actor:Abs_K2_SetActorLocation_WithoutHit(HitLocation)
    Log.DebugFormat("BattleConstructNearbyBattleEnvAction MoveSpawnPointToValidLocation: HitLocation %s, actorLocation %s, BattlePetCameraLocationZFix %s", HitLocation, actorLocation, BattleEnv.BattlePetCameraLocationZFix)
  else
    Log.Debug("BattleConstructNearbyBattleEnvAction MoveSpawnPointToValidLocation find fail 22:", HitResult, HitLocation, actorLocation, UE4Helper.GetCurrentWorld())
  end
end

function BattleConstructNearbyBattleEnvAction:MoveSpawnPointToValidLocationByLine(actor, ignoreActorLst)
  local actorLoc = actor:Abs_K2_GetActorLocation()
  if BattleUtils.IsSky() then
    actorLoc.Z = actorLoc.Z + BattleConst.SkyPlatformHeight
  end
  local validPos = LineTraceUtils.GetPointValidLocationByLine(actorLoc, nil, nil, BattleManager.battleRuntimeData.NearbyValidBattleLocation)
  Log.Debug("BattleConstructNearbyBattleEnvAction:MoveSpawnPointToValidLocationByLine :", actor:GetName(), BattleManager.battleRuntimeData.NearbyValidBattleLocation, actorLoc, validPos)
  if validPos then
    validPos.Z = validPos.Z + 0
    actor:Abs_K2_SetActorLocation_WithoutHit(validPos)
    return validPos
  end
  self:MoveSpawnPointToValidLocation(actor)
end

function BattleConstructNearbyBattleEnvAction:SpawnWaterPlatform(teamEnum, index, location)
  BattleManager.vBattleField:SpawnWaterPlatform(teamEnum, index, location)
end

function BattleConstructNearbyBattleEnvAction:SpawnSkyPlatform(location)
  BattleManager.vBattleField:SpawnSkyPlatform(location)
end

function BattleConstructNearbyBattleEnvAction:OnFinish()
  _G.NRCEventCenter:DispatchEvent(BattleEvent.UPDATE_BATTLEFIELD_POS, BattleManager.battleRuntimeData.NearbyValidBattleLocation)
end

function BattleConstructNearbyBattleEnvAction:OnExit()
end

return BattleConstructNearbyBattleEnvAction
