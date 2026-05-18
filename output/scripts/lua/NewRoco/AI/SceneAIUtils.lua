local SceneAIUtils = NRCClass()

function SceneAIUtils.DetermineStunDuration(charge_level, charge_percent, resistance)
  if charge_level - resistance <= 0 then
    return 0
  end
  local MagicBaseConf = _G.DataConfigManager:GetMagicBaseConf(1)
  if not MagicBaseConf then
    return 0
  end
  local rawStunTime = SceneAIUtils.ParseMagicParamByLevel(MagicBaseConf, charge_level - 1, charge_percent, 1, 2)
  local resistanceTime = 0
  if 0 ~= resistance then
    resistanceTime = SceneAIUtils.ParseMagicParamByLevel(MagicBaseConf, resistance - 1, 0, 1, 2)
  end
  local minTimeShouldStun = resistanceTime
  if 1 ~= resistance then
    minTimeShouldStun = SceneAIUtils.ParseMagicParamByLevel(MagicBaseConf, 0, 0, 1, 2)
  end
  local result = math.max(rawStunTime - resistanceTime, minTimeShouldStun)
  if RocoEnv.IS_EDITOR then
    Log.PrintScreenMsg("[\229\135\187\230\153\149\228\186\134\231\178\190\231\129\181! \230\151\182\233\149\191:%.2fms] \232\147\132\229\138\155\231\173\137\231\186\167=%d, \232\147\132\229\138\155\232\191\155\229\186\166=%.2f, \230\138\151\230\128\167=%d, \230\160\135\229\135\134\229\135\187\230\153\149\230\151\182\233\151\180=%.2f, \229\135\187\230\153\149\230\138\151\230\128\167\230\151\182\233\151\180=%.2f, 1\233\152\182\229\135\187\230\153\149\228\184\139\233\153\144=%.2f", result, charge_level, charge_percent, resistance, rawStunTime, resistanceTime, minTimeShouldStun)
  else
    Log.DebugFormat("[\229\135\187\230\153\149\228\186\134\231\178\190\231\129\181! \230\151\182\233\149\191:%.2fms] \232\147\132\229\138\155\231\173\137\231\186\167=%d, \232\147\132\229\138\155\232\191\155\229\186\166=%.2f, \230\138\151\230\128\167=%d, \230\160\135\229\135\134\229\135\187\230\153\149\230\151\182\233\151\180=%.2f, \229\135\187\230\153\149\230\138\151\230\128\167\230\151\182\233\151\180=%.2f, 1\233\152\182\229\135\187\230\153\149\228\184\139\233\153\144=%.2f", result, charge_level, charge_percent, resistance, rawStunTime, resistanceTime, minTimeShouldStun)
  end
  return result
end

function SceneAIUtils.ParseMagicParamByLevel(magicBaseConf, level, percent, paramOffset, step)
  paramOffset = paramOffset % step
  local max_level = math.floor(#magicBaseConf.charge_parameter / step)
  local min = magicBaseConf.charge_parameter[math.clamp(level, 0, max_level - 1) * step + paramOffset + 1] or 0
  local max = magicBaseConf.charge_parameter[(level + 1) * step + paramOffset + 1] or min
  return _G.LuaMathUtils.LerpWithAlpha(min, max, percent)
end

function SceneAIUtils.DetermineStunBattleStatus(charge_level, resistance)
  local offset = charge_level - resistance - 1
  if offset < 0 then
    return 0
  end
  if offset >= 0 and offset < 4 then
    local result = _G.Enum.BattleAIStatus.BAS_MAGIC_STUN_1 + offset
    return result
  end
  Log.Warning("DetermineStunBattleStatus, wrong parameters")
  return 0
end

function SceneAIUtils.ClearStunBattleStatus(AiComp)
  if not AiComp then
    return
  end
  local Bitset = 15 << _G.Enum.BattleAIStatus.BAS_MAGIC_STUN_1
  AiComp:UnsetBattleStateMulti(Bitset)
end

local _NRCModuleManager = _G.NRCModuleManager

function SceneAIUtils.CheckRandPosInAnyWorldCombatArea(x, y)
  local WorldCombatModule = _NRCModuleManager:GetModule("WorldCombatModule")
  if not WorldCombatModule or not WorldCombatModule:OnIsInWorldCombat() then
    return true
  end
  local pos2d = UE.FVector2D(x, y)
  if WorldCombatModule:IsPointInAnyWorldCombatArea(pos2d) then
    return true
  else
    return false
  end
end

function SceneAIUtils.CheckRandPosInPatrolArea(x, y, pawn)
  local npc = pawn.sceneCharacter
  if npc and npc.config then
    local area = npc:GetArea()
    if area then
      if area._inRegion and UE.UObject.IsValid(area._inRegion) then
        local pos2d = UE.FVector2D(x, y)
        return area._inRegion:ContainPoint2D(pos2d) or false
      else
        return false
      end
    else
      return true
    end
  else
    return true
  end
end

local RANGE_LIST

function SceneAIUtils.CheckFriendlinessInRange(val)
  if not RANGE_LIST then
    local low_range = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_low")
    local mid_range = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_middle")
    local high_range = _G.DataConfigManager:GetHomeGlobalConfig("home_steal_attack_high")
    RANGE_LIST = {
      {
        low_range.numList[1],
        low_range.numList[2]
      },
      {
        mid_range.numList[1],
        mid_range.numList[2]
      },
      {
        high_range.numList[1],
        high_range.numList[2]
      }
    }
  end
  for level, range in ipairs(RANGE_LIST) do
    if val >= range[1] and val <= range[2] then
      return level
    end
  end
end

function SceneAIUtils.DetermineRandInPeriod(period, time_offset, inspire)
  local time_stamp = _G.ZoneServer:GetServerTime()
  local period_index = math.floor(math.abs(time_stamp - time_offset) / period)
  
  local function generate_seed(a, b)
    local seed = (a * 2654435769 + b) % 4294967296
    seed = seed * 2246822519 % 4294967296
    return (seed + a + b) % 4294967296
  end
  
  local function deterministic_random(seed)
    local a = 1664525
    local c = 1013904223
    local new_seed = (a * seed + c) % 4294967296
    return new_seed / 4.294967296E9
  end
  
  local seed = generate_seed(inspire or time_offset, period_index)
  return deterministic_random(seed)
end

local P_HOME_INIT_BEH_FURN, P_HOME_INIT_BEH_RAND, P_HOME_INIT_BEH_HALLWAY

local function InitHomeInitiativeBehaviorConfig()
  if P_HOME_INIT_BEH_FURN then
    return
  end
  local conf = _G.DataConfigManager:GetHomeGlobalConfig("home_initiative_behavior_probabilities", true)
  if conf then
    P_HOME_INIT_BEH_FURN = conf.numList[1] or 0
    P_HOME_INIT_BEH_RAND = conf.numList[2] or 100
    P_HOME_INIT_BEH_HALLWAY = conf.numList[3] or 10
  else
    P_HOME_INIT_BEH_FURN = 0
    P_HOME_INIT_BEH_RAND = 100
    P_HOME_INIT_BEH_HALLWAY = 10
  end
end

SceneAIUtils.bHomeInitBehCheckEnterSceneTime = true

function SceneAIUtils.DetermineHomeInitiativeBehavior(actor_id)
  local PERIOD = 900000
  local time_period = math.floor(actor_id / PERIOD)
  local r = SceneAIUtils.DetermineRandInPeriod(PERIOD, time_period, actor_id)
  InitHomeInitiativeBehaviorConfig()
  local total_prob = P_HOME_INIT_BEH_FURN + P_HOME_INIT_BEH_HALLWAY + P_HOME_INIT_BEH_RAND
  local prob_value = r * total_prob
  if prob_value < P_HOME_INIT_BEH_FURN then
    return 1
  elseif prob_value < P_HOME_INIT_BEH_FURN + P_HOME_INIT_BEH_RAND then
    return 2
  else
    return 3
  end
end

SceneAIUtils.DEBUG_POI_POINTS = false
SceneAIUtils.SKIP_POI_POINTS_CHECK = false

function SceneAIUtils.CheckPrimaryPointValid(POIComp, PrimaryPoint)
  if SceneAIUtils.SKIP_POI_POINTS_CHECK then
    return true
  end
  local result = false
  do
    local Sandbox = _G.HomeIndoorSandbox
    if Sandbox and Sandbox:InHomeIndoor() and POIComp and PrimaryPoint then
      local ownerActor = POIComp:GetOwner()
      if ownerActor then
        local Plane = ownerActor.PropsData and ownerActor.PropsData.RealtimePlane
        if Plane then
          if Plane:IsWall() then
            local RoomId = Plane.RoomId
            if not RoomId then
              goto lbl_54
            end
            local Room = Sandbox.World:GetRoomById(RoomId)
            if not Room then
              goto lbl_54
            end
            Plane = Room:GetGroundPlane()
            if not Plane then
              goto lbl_54
            end
          end
          local CellType = Plane:IndicatePosToCell(PrimaryPoint)
          if 1 ~= CellType then
            result = true
          end
        end
      end
    end
  end
  ::lbl_54::
  if SceneAIUtils.DEBUG_POI_POINTS then
    UE.UKismetSystemLibrary.Abs_DrawDebugSphere(POIComp, PrimaryPoint, 40, 4, result and UE.FLinearColor(0, 1, 0, 1) or UE.FLinearColor(1, 0, 0, 1), 10, 2)
  end
  return result
end

SceneAIUtils.SkipBehaviorGroupCdAndRand = false
SceneAIUtils.SkipServerBehaviorGroupCdAndRand = false
SceneAIUtils.DisableAI = true
SceneAIUtils.DEBUG_BORN_TIME_OFFSET_SEC = 0
local localSceneAIManager

function SceneAIUtils.GetSceneAIManager()
  if not localSceneAIManager then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    if NPCModule then
      localSceneAIManager = NPCModule.SceneAIManager
    end
  end
  return localSceneAIManager
end

function SceneAIUtils.CalcLaunchFallPosOnNav(Character, agentRadius, from, vel, gravity)
  if not UE.UObject.IsValid(Character) then
    return false
  end
  if 0 == vel.X and 0 == vel.Y then
    return true
  end
  if 0 == gravity then
    gravity = 0.1
  end
  local t = math.abs(vel.Z / gravity) * 2
  local futureDistance = t * vel:Size2D()
  local futurePos = from + UE.FVector(t * vel.X, t * vel.Y, 0)
  local rad = agentRadius
  local Dir2D = UE.FVector(vel.X, vel.Y, 0)
  Dir2D:Normalize()
  local HitLocation, HitResult = UE.UNavigationSystemV1.Abs_NavigationRaycast(Character, from + Dir2D * rad, futurePos, nil, UE.UNRCNavFilter, Character:GetController())
  if HitResult then
    if _G.GlobalConfig.DebugLuaBTree then
      UE.UKismetSystemLibrary.Abs_DrawDebugSphere(Character, futurePos, 100, 7, UE.FLinearColor(1, 0, 0, 1), 10, 3)
      UE.UKismetSystemLibrary.Abs_DrawDebugSphere(Character, HitLocation, 100, 7, UE.FLinearColor(0, 1, 0, 1), 10, 3)
    end
    local newDistance = math.max(HitLocation:Dist2D(from) - rad, 0)
    local ratio = math.clamp(newDistance / futureDistance, 0, 1)
    vel.X = vel.X * ratio
    vel.Y = vel.Y * ratio
    return true
  end
  if _G.GlobalConfig.DebugLuaBTree then
    UE.UKismetSystemLibrary.Abs_DrawDebugSphere(Character, futurePos, 100, 7, UE.FLinearColor(1, 0, 0, 1), 10, 3)
  end
  return true
end

return SceneAIUtils
