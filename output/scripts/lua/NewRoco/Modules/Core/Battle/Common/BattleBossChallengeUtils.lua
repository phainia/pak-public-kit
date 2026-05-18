local BattleBossChallengeUtils = {}

function BattleBossChallengeUtils.GetBossChallengeData()
  local BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if BossChallengeEventActivityObject and BossChallengeEventActivityObject[1] then
    return BossChallengeEventActivityObject[1]:GetBossChallengeData()
  else
    return nil
  end
end

function BattleBossChallengeUtils.GetBossChallengeActivityId()
  local BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if BossChallengeEventActivityObject and BossChallengeEventActivityObject[1] then
    return BossChallengeEventActivityObject[1]:GetBossActivityId()
  else
    return 0
  end
end

function BattleBossChallengeUtils.GetCurBossChallengeLevelId()
  local bossChallengeData = BattleBossChallengeUtils.GetBossChallengeData()
  if not bossChallengeData.last_level_id then
    Log.Error("last_level_id\230\149\176\230\141\174\228\184\162\229\164\177\239\188\140\232\174\169\229\144\142\229\143\176\229\142\187\230\163\128\230\159\165\228\184\128\228\184\139\230\180\187\229\138\168\230\149\176\230\141\174\228\184\173\231\154\132\229\173\151\230\174\181ActivityBossChallengeData.last_level_id\230\152\175\229\144\166\229\144\140\230\173\165\231\187\153\229\174\162\230\136\183\231\171\175")
  end
  return bossChallengeData.last_level_id
end

function BattleBossChallengeUtils.CheckCurMapIsLeaderChallengeDungeon(SceneId)
  local leaderDungeonId = _G.DataConfigManager:GetChallengeGlobalConf(1).num
  local Conf = _G.DataConfigManager:GetDungeonConf(leaderDungeonId)
  return Conf.scene_id == SceneId
end

function BattleBossChallengeUtils.IsLeaderChallengeDungeon(dungeonId)
  if not dungeonId or 0 == dungeonId then
    return false
  end
  local leaderDungeonId = _G.DataConfigManager:GetChallengeGlobalConf(1).num
  return dungeonId == leaderDungeonId
end

function BattleBossChallengeUtils.IsInLeaderChallengeDungeon()
  if _G.DataModelMgr.PlayerDataModel:IsInDungeon() then
    local ID = _G.DataModelMgr.PlayerDataModel:GetDungeonID()
    if _G.BattleBossChallengeUtils.IsLeaderChallengeDungeon(ID) then
      return true
    end
  end
  return false
end

function BattleBossChallengeUtils.GetBossChallengeCurLevel()
  local bossChallengeData = BattleBossChallengeUtils.GetBossChallengeData()
  local curLevel = BattleBossChallengeUtils.GetCurBossChallengeLevelId()
  for _, oneLevel in pairs(bossChallengeData.levels) do
    if oneLevel.challenge_id == curLevel then
      return oneLevel
    end
  end
  Log.Error("\230\156\170\230\137\190\229\136\176\233\166\150\233\162\134\232\167\146\230\150\151\231\155\184\229\133\179\230\149\176\230\141\174curLevel=", curLevel)
  return nil
end

function BattleBossChallengeUtils.GetBossChallengeTaskInfo()
  local curLevel = BattleBossChallengeUtils.GetBossChallengeCurLevel()
  local answer = {}
  if curLevel then
    for _, oneTarget in pairs(curLevel.targets) do
      table.insert(answer, {
        task_id = oneTarget.target_id,
        task_state = oneTarget.temp_state
      })
    end
  end
  return answer
end

function BattleBossChallengeUtils.GetBossChallengeCurBuff()
  local bossChallengeData = BattleBossChallengeUtils.GetBossChallengeData()
  return bossChallengeData.buff_rule_id
end

function BattleBossChallengeUtils.GetBossChallengeId()
  local curLevel = BattleBossChallengeUtils.GetBossChallengeCurLevel()
  return curLevel.challenge_id
end

function BattleBossChallengeUtils.GetBossChallengeRules()
  local challenge_level_id = BattleBossChallengeUtils.GetCurBossChallengeLevelId()
  local ChallengeConf = _G.DataConfigManager:GetBossChallengeConf(challenge_level_id)
  return ChallengeConf.rule
end

function BattleBossChallengeUtils.MergeBossChallengeInfo()
  local BossChallengeInfo
  local bossChallengeData = BattleBossChallengeUtils.GetBossChallengeData()
  if bossChallengeData then
    BossChallengeInfo = {}
    BossChallengeInfo.event_id = bossChallengeData.event_id
    BossChallengeInfo.buff_id = BattleBossChallengeUtils.GetBossChallengeCurBuff()
    BossChallengeInfo.activity_id = BattleBossChallengeUtils.GetBossChallengeActivityId()
    BossChallengeInfo.challenge_level_id = BattleBossChallengeUtils.GetBossChallengeId()
    return BossChallengeInfo
  else
    return BossChallengeInfo
  end
end

function BattleBossChallengeUtils.ShowMechanismValidationTiming()
  if BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
    local BossChallengeInfo = BattleBossChallengeUtils.MergeBossChallengeInfo()
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenMechanismValidation, nil, BossChallengeInfo, BattleBossChallengeUtils, BattleBossChallengeUtils.ShowMechanismValidationFinish)
  end
end

function BattleBossChallengeUtils.ShowMechanismValidationFinish()
end

function BattleBossChallengeUtils.ShowAdditionalTarget()
  if not NRCModuleManager:DoCmd(MainUIModuleCmd.GetLobbyMainEnableState) then
    return
  end
  if not NRCModuleManager:DoCmd(MainUIModuleCmd.GetLobbyMainPanelOpen) then
    return
  end
  local bossChallengeData = BattleBossChallengeUtils.GetBossChallengeData()
  if bossChallengeData and BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
    local state = BattleBossChallengeUtils.IsInLeaderChallengeDungeon()
    local BossChallengeInfo = BattleBossChallengeUtils.MergeBossChallengeInfo()
    local taskInfo = BattleBossChallengeUtils.GetBossChallengeTaskInfo()
    if taskInfo then
      _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleAdditionalTarget, taskInfo, BossChallengeInfo, true)
    end
  end
end

function BattleBossChallengeUtils.HideAdditionalTarget()
  if BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseBattleAdditionalTarget)
  end
end

function BattleBossChallengeUtils.ShowUmgMechanismClick()
  if _G.BattleUtils.IsNpcChallenge() then
    local NpcChallengeInfo = _G.BattleManager:GetBattleNpcChallengeInfo()
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenMechanismValidation, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT, NpcChallengeInfo)
  elseif _G.BattleUtils.IsLeaderChallenge() then
    local BossChallengeInfo = BattleBossChallengeUtils.MergeBossChallengeInfo()
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenMechanismValidation, nil, BossChallengeInfo)
  end
end

function BattleBossChallengeUtils.RefreshData()
  if BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
    local req = _G.ProtoMessage:newZoneGetPlayerActivityDataReq()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_REQ, req, BattleBossChallengeUtils, BattleBossChallengeUtils.OnGetBossChallengeData)
  end
end

function BattleBossChallengeUtils.RefreshBossChallengeData()
  if BattleBossChallengeUtils.IsInLeaderChallengeDungeon() then
    local req = _G.ProtoMessage:newZoneGetPlayerActivityDataReq()
    req.activity_id = BattleBossChallengeUtils.GetBossChallengeActivityId()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_REQ, req, BattleBossChallengeUtils, BattleBossChallengeUtils.OnGetBossChallengeData)
  end
end

function BattleBossChallengeUtils.CheckHasBossData()
  local BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  local bossChallengeData = BossChallengeEventActivityObject[1]:GetBossChallengeData()
  if bossChallengeData then
    return true
  else
    return false
  end
end

function BattleBossChallengeUtils.OnGetBossChallengeData(event, rsp)
  if BattleBossChallengeUtils.CheckHasBossData() then
    BattleBossChallengeUtils.ShowMechanismValidationTiming()
  else
    _G.DelayManager:DelaySeconds(1, BattleBossChallengeUtils.OnGetBossChallengeData, BattleBossChallengeUtils)
  end
end

return BattleBossChallengeUtils
