local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleOnLookerBase = require("NewRoco.Modules.Core.Battle.Entity.BattleOnLookerBase")
local a = require("Common.Coroutine.async")
local Base = BattleActionBase
local BattleOnLookerSpawnAction = Base:Extend("BattleOnLookerSpawnAction")
FsmUtils.MergeMembers(Base, BattleOnLookerSpawnAction, {})

function BattleOnLookerSpawnAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleOnLookerSpawnAction:OnEnter()
  if _G.EnableFakePVPRecord then
    self:CreateOnlookerData()
  end
  local battleOnLookerInfo = _G.BattleManager.battleRuntimeData.battleOnLookerInfo
  local onLookersSpawnExecuted = battleOnLookerInfo and battleOnLookerInfo.onLookersSpawnExecuted or false
  if onLookersSpawnExecuted then
    Log.Error("BattleOnLookerSpawnAction:OnEnter \229\155\180\232\167\130 NPC \231\148\159\230\136\144\230\181\129\231\168\139\229\183\178\232\162\171\232\176\131\231\148\168\239\188\140\230\147\141\228\189\156\229\143\150\230\182\136")
    self:Finish()
    return
  end
  self:CheckFriendOnLookerPositionValid()
  if BattleUtils.IsWeeklyChallenge() then
    local resourcePath = BattleConst.BattleCrowdOnLookerPath
    _G.BattleResourceManager:LoadResAsyncThunk(nil, resourcePath, nil, nil, nil, _G.PriorityEnum.Passive_Battle_NPC, function(ok, messageOrResult)
      if ok then
        local res = messageOrResult
        self.npcClass = res
      end
      self:OnResLoaded()
    end)
  else
    self:OnResLoaded()
  end
  self:Finish()
end

function BattleOnLookerSpawnAction:OnResLoaded()
  local battlePawnManager = _G.BattleManager.battlePawnManager
  local initInfo = BattleUtils.GetBattleInitInfo()
  local battleOnLookerListA = initInfo and initInfo.onlooker_a or {}
  local battleOnLookerListB = initInfo and initInfo.onlooker_b or {}
  local observe_battle = initInfo and initInfo.observe_battle
  local fashionInfoList = observe_battle and observe_battle.observer_appearance_info or {}
  local npcModelList = {}
  local World = _G.UE4Helper.GetCurrentWorld()
  local UGameplayStatics = UE4.UGameplayStatics
  if UE.UObject.IsValid(self.npcClass) then
    npcModelList = UGameplayStatics.GetAllActorsOfClass(World, self.npcClass):ToTable()
  end
  self.npcClass = nil
  battlePawnManager:SpawnBattleNpcList(battleOnLookerListA, battleOnLookerListB, npcModelList, fashionInfoList, function(ok, errorOrMessage)
    if not ok then
      local battleOnLookerInfo = _G.BattleManager.battleRuntimeData.battleOnLookerInfo
      local context = battleOnLookerInfo and battleOnLookerInfo.spawnBattleOnLookerAsyncContext
      Log.Error("BattleOnLookerSpawnAction:OnEnter SpawnBattleNpcList error", errorOrMessage)
      if context then
        a.trace(context)
      end
    end
  end)
end

function BattleOnLookerSpawnAction:CreateOnlookerData()
  local onlooker_a = {
    {
      id = 1001,
      npc_conf_id = 62130,
      npc_obj_id = 0,
      pos = 1
    },
    {
      id = 1003,
      npc_conf_id = 62136,
      npc_obj_id = 0,
      pos = 2
    },
    {
      id = 1005,
      npc_conf_id = 62143,
      npc_obj_id = 0,
      pos = 3
    },
    {
      id = 1007,
      npc_conf_id = 62150,
      npc_obj_id = 0,
      pos = 4
    }
  }
  local onlooker_b = {
    {
      id = 1002,
      npc_conf_id = 62133,
      npc_obj_id = 0,
      pos = 1
    },
    {
      id = 1004,
      npc_conf_id = 62142,
      npc_obj_id = 0,
      pos = 2
    },
    {
      id = 1006,
      npc_conf_id = 62148,
      npc_obj_id = 0,
      pos = 3
    },
    {
      id = 1008,
      npc_conf_id = 62156,
      npc_obj_id = 0,
      pos = 4
    }
  }
  local battleStartParam = _G.BattleManager.battleRuntimeData.battleStartParam
  if battleStartParam then
    battleStartParam:SetOnlooker(onlooker_a, onlooker_b)
  end
end

function BattleOnLookerSpawnAction:CheckFriendOnLookerPositionValid()
  local battleOnLookerPlayerPointEnumList = {
    UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A1,
    UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A2,
    UE.EBattleFieldOnLookerAttachPoint.Pos_Round_A4
  }
  local vBattleField = _G.BattleManager.vBattleField
  local runtimeData = _G.BattleManager.battleRuntimeData
  local battleOnLookerInfo = runtimeData and runtimeData.battleOnLookerInfo
  local battleFieldConf = vBattleField and vBattleField.battleFieldConf
  local OnLookerPosMap = UE.UObject.IsValid(battleFieldConf) and battleFieldConf.OnLookerPosMap
  local validOnLookerPointEnumMap = {}
  if OnLookerPosMap then
    for i, pointEnum in ipairs(battleOnLookerPlayerPointEnumList) do
      local attachActor = OnLookerPosMap:Find(pointEnum)
      local location = UE.UObject.IsValid(attachActor) and attachActor:Abs_K2_GetActorLocation() or nil
      local checkValidLocationResult = location and BattleOnLookerBase.CheckValidPosition(location)
      local isValid = checkValidLocationResult and checkValidLocationResult.isValid
      if isValid then
        validOnLookerPointEnumMap[pointEnum] = true
      end
    end
  end
  if battleOnLookerInfo then
    battleOnLookerInfo.validOnLookerPointEnumMap = validOnLookerPointEnumMap
  end
end

return BattleOnLookerSpawnAction
