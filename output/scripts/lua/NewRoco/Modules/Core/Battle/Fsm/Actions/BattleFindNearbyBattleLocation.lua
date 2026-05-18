local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local SkillAutoPerform = require("Common.LocalServer.SkillPerformAutoBattle")
local CopingSkillAutoPerform = require("Common.LocalServer.CopingSkillPerformAutoBattle")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleFindNearbyBattleLocation = Base:Extend("BattleFindNearbyBattleLocation")

function BattleFindNearbyBattleLocation:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleFindNearbyBattleLocation:DebugLocalFindPoint()
  if RocoEnv.IS_SHIPPING then
    return
  end
  local nearbyEnemyLocation = BattleManager.battleRuntimeData.battleDebugEnemyPos
  if nearbyEnemyLocation then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
    local PlayerTransform = player.viewObj:Abs_GetTransform()
    PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
    if not BattleConst.CanBattleEverywhere then
      BattleField.FindNearestBattlePoint(nearbyEnemyLocation, PlayerTransform, self:IsNeedFull() or false)
    else
      BattleField.FindNearestBattlePoint(PlayerLocation, PlayerTransform, self:IsNeedFull() or false)
    end
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_SET_BATTLE_POS)
  end
end

function BattleFindNearbyBattleLocation.CalculateBattleRotation()
  local Rotation = BattleManager.battleRuntimeData.ServerBattleRotate or 0
  if BattleUtils.IsPvp() then
    local playerdata = BattleManager.battleRuntimeData.battleStartParam.battleInitInfo.player_team
    if playerdata and #playerdata > 0 then
      local petData = playerdata[1].pets
      if petData and #petData > 0 and petData[1].battle_inside_pet_info.pet_id >= 400 then
        Rotation = Rotation + 180
      end
    end
  end
  return Rotation
end

function BattleFindNearbyBattleLocation:FindNearbyNavPoint(QueryExtent)
  if not _G.BattleAutoTest.IsAutoBattle and BattleManager.battleRuntimeData.TeleportBattleCenter then
    local Rotation = BattleFindNearbyBattleLocation.CalculateBattleRotation()
    self:SaveWaterInfo(BattleManager.battleRuntimeData.TeleportBattleCenter)
    self:SaveTransform(BattleManager.battleRuntimeData.TeleportBattleCenter, Rotation)
    self:MoveBattleDepthCam()
    self:RecordHideRange()
    self:DebugLocalFindPoint()
    return
  end
  local localBattlePos
  local localBattleRotation = 0
  if ServerData.values.battleMode == "auto" then
    localBattlePos = SkillAutoPerform:GetBattlePosition()
  elseif ServerData.values.battleMode == "auto_coping" then
    localBattlePos = ServerData.values.CopingSkillAutoPerform:GetBattlePosition()
  elseif ServerData.values.battleMode == "auto_replay" then
    localBattlePos = BattleManager.battleRuntimeData.TeleportBattleCenter
    localBattleRotation = BattleFindNearbyBattleLocation.CalculateBattleRotation()
  end
  Log.Debug("BattleFindNearbyBattleLocation:FindNearbyNavPoint2 ", localBattlePos, ServerData.values.battleMode)
  if localBattlePos then
    self:SaveWaterInfo(localBattlePos)
    self:SaveTransform(localBattlePos, 0)
    self:MoveBattleDepthCam()
    self:RecordHideRange()
    return
  end
  local BattlePos, Rotation = self:DebugLocalFindPoint()
  if BattlePos then
    if BattleUtils.IsDeepWater() then
      BattlePos = LineTraceUtils.GetPointValidLocationByLine(BattlePos)
    end
    self:SaveWaterInfo(BattlePos)
    self:SaveTransform(BattlePos, Rotation)
    self:MoveBattleDepthCam()
    self:RecordHideRange()
    return true
  else
    self:Finish()
  end
end

function BattleFindNearbyBattleLocation:IsNeedFull()
  return BattleUtils.IsCrowdBattle() or BattleUtils.HasEnemyPlayer() or self:GetEnemyCapsuleRadius() > 100
end

function BattleFindNearbyBattleLocation:GetEnemyCapsuleRadius()
  local initInfo = BattleUtils.GetBattleInitInfo()
  if initInfo and initInfo.enemy_team then
    for _, v in ipairs(initInfo.enemy_team) do
      for i, pet in ipairs(v.pets or {}) do
        if BattleUtils.GetInBattle(pet.battle_inside_pet_info) then
          local petBaseConf = _G.DataConfigManager:GetPetbaseConf(pet.battle_common_pet_info.base_conf_id)
          if petBaseConf then
            local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
            if modelConf then
              local resourceScale = (modelConf.model_scale or 100) / 100
              local radius = (modelConf.capsule_radius or 1000) / 1000
              return radius * resourceScale
            end
          end
        end
      end
    end
  end
  return 0
end

function BattleFindNearbyBattleLocation:SaveWaterInfo(battlePos)
  if not BattleUtils.IsDeepWater() then
    return
  end
  local waterPos = LineTraceUtils.GetPointValidLocationByLine(battlePos)
  BattleManager.vBattleField.WaterHeight = waterPos.Z
  if BattleManager.vBattleField.battleFieldActor then
    BattleManager.vBattleField.battleFieldActor:SetWaterFight(1, waterPos.Z)
  end
end

function BattleFindNearbyBattleLocation:SaveTransform(location, rotation)
  BattleManager.battleRuntimeData.NearbyValidBattleLocation = location
  BattleManager.battleRuntimeData.NearbyValidBattleRotation = rotation
end

function BattleFindNearbyBattleLocation:MoveBattleDepthCam()
  if BattleManager.vBattleField.BattleDepthCam then
    BattleManager.vBattleField.BattleDepthCam:MoveToBattleCenterPos()
  end
end

function BattleFindNearbyBattleLocation:RecordHideRange()
  BattleManager.vBattleField:RecordNpcHideRange()
end

function BattleFindNearbyBattleLocation:OnEnter()
  local QueryExtent = UE4.FVector(1000, 1000, 4000)
  self:FindNearbyNavPoint(QueryExtent)
  self:Finish()
end

function BattleFindNearbyBattleLocation:OnExit()
end

return BattleFindNearbyBattleLocation
