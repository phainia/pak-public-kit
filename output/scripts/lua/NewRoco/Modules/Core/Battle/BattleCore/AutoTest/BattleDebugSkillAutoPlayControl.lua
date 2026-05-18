local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local MainUIModuleCmd = require("NewRoco.Modules.System.MainUI.MainUIModuleCmd")
local PetUIModuleCmd = require("NewRoco.Modules.System.PetUI.PetUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local BattleDebugSkillAutoPlayControl = NRCClass:Extend()
BattleDebugSkillAutoPlayControl.BattleEnterState = {
  WaitingForStart = 1,
  AddTeamPet = 2,
  SetBattleTeam = 3,
  TeleportToBattleCenter = 4,
  InternalEnterBattle = 5,
  Finish = 6
}

function BattleDebugSkillAutoPlayControl:Ctor()
  Log.Debug("BattleDebugSkillAutoPlayControl:Ctor")
  self.battleDebugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.isInBattleTest = false
  self.isPaused = false
  self.isRoundPlaying = false
  self.requests = {}
  self.configData = nil
  self.isTestOver = false
  self.currentRoundIndex = 0
  self.currentPlaySpeed = 1
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.WaitingForStart
  self.battleDebugControl:SetTestData()
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_START, BattleEvent.PrepareBattleOver, BattleEvent.Replay_Exit, BattleEvent.Replay_Pause, BattleEvent.Replay_Resume, BattleEvent.Replay_Fast, BattleEvent.Replay_Slow, BattleEvent.Replay_Redo, BattleEvent.Replay_Undo)
  NRCEventCenter:RegisterEvent("BattleDebugSkillAutoPlayControl", self, TaskModuleEvent.BattleOver, self.OnLeaveBattle)
  NRCEventCenter:RegisterEvent("BattleDebugSkillAutoPlayControl", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnSceneLoaded)
end

function BattleDebugSkillAutoPlayControl:Dctor()
  Log.Debug("BattleDebugSkillAutoPlayControl:Dctor")
end

function BattleDebugSkillAutoPlayControl:EnterBattle(configData)
  self.configData = configData
  self:TeleportToBattlePosition()
end

function BattleDebugSkillAutoPlayControl:TeleportToBattlePosition()
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.TeleportToBattleCenter
  local battlePosition = self.configData.battleCenter
  local teleportDistance = self.configData.teleportDistance
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  
  local function GetPositionSize(x, y, z)
    return x * x + y * y + z * z
  end
  
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  if type(battlePosition) ~= "table" then
    battlePosition = {
      x = playerLocation.X,
      y = playerLocation.Y,
      z = playerLocation.Z
    }
  end
  if type(teleportDistance) ~= "number" then
    teleportDistance = 999
  end
  local battlePositionDistance = math.sqrt(GetPositionSize(battlePosition.x - playerLocation.X, battlePosition.y - playerLocation.Y, battlePosition.z - playerLocation.Z))
  if teleportDistance > battlePositionDistance then
    self:OnSceneLoaded()
    return
  end
  Log.Debug("BattleDebugSkillAutoPlayControl:TeleportToBattlePosition current position ", playerLocation, battlePosition.x, battlePosition.y, battlePosition.z)
  local teleportRequest = ProtoMessage.newZoneSceneGmTeleportReq()
  local bornSceneCfgId = DataConfigManager:GetGlobalConfigByKeyType("novice_pt", DataConfigManager.ConfigTableId.ROLE_GLOBAL_CONFIG).num
  if SceneUtils.GetSceneID() ~= bornSceneCfgId then
    teleportRequest.to_scene_cfg_id = bornSceneCfgId
  else
    teleportRequest.to_scene_cfg_id = SceneUtils.GetSceneID()
  end
  teleportRequest.to_point.pos = battlePosition
  teleportRequest.to_point.dir.x = 0
  teleportRequest.to_point.dir.y = 0
  teleportRequest.to_point.dir.z = 174
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleportRequest, self, self.OnTeleportRsp, true, true)
end

function BattleDebugSkillAutoPlayControl:OnTeleportRsp(retInfo)
end

function BattleDebugSkillAutoPlayControl:InternalEnterBattle()
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.InternalEnterBattle
  local battleID = 399005
  if type(self.configData.battleConfId) == "number" then
    battleID = self.configData.battleConfId
  end
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local PlayerTransform = player.viewObj:Abs_GetTransform()
  PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
  req.avatar_pt.pos.x = math.floor(PlayerLocation.X)
  req.avatar_pt.pos.y = math.floor(PlayerLocation.Y)
  req.avatar_pt.pos.z = math.floor(PlayerLocation.Z)
  req.battle_conf_id = battleID
  req.npc_level = 99
  req.disable_anti_cheat = true
  local enemyPetId = self.configData.enemyMonsterConfigId
  local battleNpc = ProtoMessage:newGmBattleNpc()
  local npc_cfg_id = 17015
  if "number" == type(self.configData.enemyNpcConfigId) then
    npc_cfg_id = self.configData.enemyNpcConfigId
  end
  battleNpc.npc_cfg_id = npc_cfg_id
  table.insert(battleNpc.monster_ids, enemyPetId)
  table.insert(req.dynamic_npcs, battleNpc)
  Log.Dump(req, 4, "EnterBattle")
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req, self, self.OnEnterBattleRsp)
end

function BattleDebugSkillAutoPlayControl:OnEnterBattleRsp(rsp)
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.Finish
  Log.Debug("BattleDebugSkillAutoPlayControl:OnEnterBattleRsp ", table.tostring(rsp))
  if 0 == rsp.ret_info.ret_code then
    self.isInBattleTest = true
  else
    local Context = DialogContext()
    Context:SetTitle("Oops"):SetContent(string.format("\232\191\155\229\133\165\230\138\128\232\131\189\232\135\170\229\138\168\230\146\173\230\148\190\230\136\152\230\150\151\229\164\177\232\180\165: %d", rsp.ret_info.ret_code)):SetMode(DialogContext.Mode.OK)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function BattleDebugSkillAutoPlayControl:PlayRound(roundParam)
  local tipString = string.format("\229\189\147\229\137\141\230\152\175\231\172\172 %d \229\155\158\229\144\136\239\188\140\230\173\163\229\156\168\230\181\139\232\175\149\230\138\128\232\131\189: \230\136\145\230\150\185 %d  \230\149\140\230\150\185 %d, \230\128\187\229\155\158\229\144\136\230\149\176\228\184\186: %d", self.currentRoundIndex, roundParam.teamCMDs[1][1].skillId, roundParam.enemyCMDs[1][1].skillId, #self.configData.roundData)
  Log.Debug(string.format("BattleDebugSkillAutoPlayControl:PlayRound %s", tipString))
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, tipString)
  self.battleDebugControl:RoundStart(roundParam)
end

function BattleDebugSkillAutoPlayControl:OnPlayRoundRsp()
end

function BattleDebugSkillAutoPlayControl:OnPrepareBattleOver()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.BattleMainSetOpacity, 0)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.Open_ReplayPanel)
end

function BattleDebugSkillAutoPlayControl:OnRoundStart()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.BattleMainSetOpacity, 0)
  if not self:IsTeamPetAlive() then
    if self.battleDebugControl:CheckCanAutoSupplyPet() then
      _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\229\174\160\231\137\169\230\136\152\232\180\165\239\188\140\232\135\170\229\138\168\232\161\165\229\174\160\228\184\173..."))
    else
      _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\229\174\160\231\137\169\230\136\152\232\180\165\239\188\140\229\183\178\230\151\160\229\143\175\228\187\165\232\161\165\229\133\133\231\154\132\229\174\160\231\137\169\239\188\140\231\130\185\229\135\187\229\143\179\228\184\138\232\167\146 x \233\128\128\229\135\186"))
    end
    return
  end
  self.isRoundPlaying = false
  local nextRoundDataIndex = self.currentRoundIndex + 1
  if nextRoundDataIndex > #self.configData.roundData then
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\230\138\128\232\131\189\229\183\178\229\133\168\233\131\168\230\146\173\230\148\190\229\174\140\230\136\144\239\188\140\229\141\179\229\176\134\233\128\128\229\135\186\239\188\140\230\136\150\231\155\180\230\142\165\231\130\185\229\135\187\229\143\179\228\184\138\232\167\146 x \233\128\128\229\135\186"))
    self.replayExitDelayId = _G.DelayManager:DelaySeconds(1, function()
      self:OnReplayExit()
    end)
  elseif self.isPaused then
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\229\183\178\230\154\130\229\129\156\239\188\140\228\184\139\228\184\128\229\155\158\229\144\136\230\152\175\231\172\172 %d \229\155\158\229\144\136, \230\128\187\229\155\158\229\144\136\230\149\176\228\184\186: %d", nextRoundDataIndex, #self.configData.roundData))
  else
    self.currentRoundIndex = nextRoundDataIndex
    local roundParam = self:PrepareRoundParam()
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\231\172\172 %d \229\155\158\229\144\136\229\141\179\229\176\134\229\188\128\229\167\139\239\188\140, \230\128\187\229\155\158\229\144\136\230\149\176\228\184\186: %d", self.currentRoundIndex, #self.configData.roundData))
    _G.DelayManager:DelaySeconds(1, function()
      self.isRoundPlaying = true
      _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshRoundIdxUI, self.currentRoundIndex)
      self:PlayRound(roundParam)
    end)
  end
end

function BattleDebugSkillAutoPlayControl:OnReplayExit()
  self:TestOver()
end

function BattleDebugSkillAutoPlayControl:OnReplayPause()
  if self.isTestOver then
    return
  end
  self.isPaused = true
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshPauseUi, self.isPaused)
end

function BattleDebugSkillAutoPlayControl:OnReplayResume()
  self.isPaused = false
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshPauseUi, self.isPaused)
  if not self.isRoundPlaying and not self.isTestOver then
    self:OnRoundStart()
  end
end

function BattleDebugSkillAutoPlayControl:OnLeaveBattle()
  Log.Debug("BattleDebugSkillAutoPlayControl:OnLeaveBattle")
  _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), 1.0)
  self.isInBattleTest = false
  _G.BattleEventCenter:UnBind(self)
  NRCEventCenter:UnRegisterEvent(self, TaskModuleEvent.BattleOver, self.OnLeaveBattle)
  NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnSceneLoaded)
end

function BattleDebugSkillAutoPlayControl:IsTeamPetAlive()
  local teamPet = BattleManager.battlePawnManager:GetPetByPos(BattleEnum.Team.ENUM_TEAM, 1)
  return nil ~= teamPet
end

function BattleDebugSkillAutoPlayControl:PrepareRoundParam()
  local roundDataItem = self.configData.roundData[self.currentRoundIndex]
  local teamPet = BattleManager.battlePawnManager:GetPetByPos(BattleEnum.Team.ENUM_TEAM, 1)
  local enemyPet = BattleManager.battlePawnManager:GetPetByPos(BattleEnum.Team.ENUM_ENEMY, 1)
  local petGuid = teamPet.guid
  local battlePlayer = BattleManager.battlePawnManager:GetPlayerMyTeam()
  for i, card in ipairs(battlePlayer.deck.cards) do
    if card.config.id == self.configData.teamPetConfigId then
      petGuid = card.guid
    end
  end
  local roundParam = {}
  roundParam.playerMagicCMDs = {}
  roundParam.teamCMDs = {}
  local teamSkillInfo = {}
  teamSkillInfo[1] = {
    team = BattleEnum.Team.ENUM_TEAM,
    pos = 1,
    petGuid = petGuid,
    skillTargetId = enemyPet.guid,
    playOrder = 1,
    skillId = roundDataItem.teamPlayer.skillId,
    attackCount = 1,
    isKill = false
  }
  table.insert(roundParam.teamCMDs, teamSkillInfo)
  roundParam.enemyCMDs = {}
  local enemySkillInfo = {}
  enemySkillInfo[1] = {
    team = BattleEnum.Team.ENUM_ENEMY,
    pos = 1,
    petGuid = enemyPet.guid,
    skillTargetId = petGuid,
    playOrder = 1,
    skillId = roundDataItem.enemyPlayer.skillId,
    attackCount = 1,
    isKill = false
  }
  table.insert(roundParam.enemyCMDs, enemySkillInfo)
  return roundParam
end

function BattleDebugSkillAutoPlayControl:AddTeamPet()
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.AddTeamPet
  self.curAddCount = 0
  if not self.battleDebugControl:GetPetGuidByConfId(self.configData.teamPetConfigId) then
    self:OperatePetReq(self.configData.teamPetConfigId)
  else
    self:OnOperatePetRsp({})
  end
end

function BattleDebugSkillAutoPlayControl:OperatePetReq(petId)
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  opItemReq.item_type = ProtoEnum.GoodsType.GT_PET
  opItemReq.item_id = petId
  opItemReq.item_num = 1
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self.OnOperatePetRsp)
end

function BattleDebugSkillAutoPlayControl:OnOperatePetRsp(retInfo)
  self:ReqSetTeamPet()
end

function BattleDebugSkillAutoPlayControl:ReqSetTeamPet()
  self.battleEnterState = BattleDebugSkillAutoPlayControl.BattleEnterState.SetBattleTeam
  local req = _G.ProtoMessage:newZonePetTeamChangeReq()
  req.team_type = _G.ProtoEnum.PlayerTeamType.PTT_BIG_WORLD
  table.insert(req.team_idxs, 0)
  local selectTeam = _G.ProtoMessage:newPetTeam()
  local teamPetGuid
  local backpackPetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  if backpackPetDatas then
    for i, data in ipairs(backpackPetDatas) do
      if data.conf_id == self.configData.teamPetConfigId then
        teamPetGuid = data.gid
      end
    end
  end
  if teamPetGuid then
    local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
    teamPetInfo.pet_gid = teamPetGuid
    teamPetInfo.equip_infos = {}
    table.insert(selectTeam.pet_infos, teamPetInfo)
  end
  selectTeam.team_name = "\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149"
  table.insert(req.teams, selectTeam)
  Log.Dump(req, 6, "BattleDebugSkillAutoPlayControl:newZonePetTeamChangeReq")
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_PET_TEAM_CHANGE_REQ, req, self, self.OnOperatePetTeamRsp)
end

function BattleDebugSkillAutoPlayControl:OnOperatePetTeamRsp(retInfo)
  Log.Dump(retInfo, 10, "BattleDebugSkillAutoPlayControl:OnOperatePetTeamRsp")
  self:InternalEnterBattle()
end

function BattleDebugSkillAutoPlayControl:TestOver()
  if self.replayExitDelayId then
    _G.DelayManager:CancelDelayById(self.replayExitDelayId)
    self.replayExitDelayId = nil
  end
  self.isTestOver = true
  local req = _G.ProtoMessage:newZoneGmBattleEndReq()
  req.battle_result = 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_BATTLE_END_REQ, req, self, self.OnBattleEndRsp)
end

function BattleDebugSkillAutoPlayControl:OnBattleEndRsp()
end

function BattleDebugSkillAutoPlayControl:OnSceneLoaded()
  if self.battleEnterState ~= BattleDebugSkillAutoPlayControl.BattleEnterState.TeleportToBattleCenter then
    return
  end
  _G.DelayManager:DelaySeconds(1, function()
    self:AddTeamPet()
  end)
end

function BattleDebugSkillAutoPlayControl:OnReplayFast()
  if self.currentPlaySpeed == BattleConst.Replay.ReplaySpeedFastNormal then
    self.currentPlaySpeed = BattleConst.Replay.ReplaySpeedFast
  elseif self.currentPlaySpeed == BattleConst.Replay.ReplaySpeedSlow then
    self.currentPlaySpeed = BattleConst.Replay.ReplaySpeedFastNormal
  end
  _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), self.currentPlaySpeed)
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshPlaySpeedUi, self.currentPlaySpeed)
end

function BattleDebugSkillAutoPlayControl:OnReplaySlow()
  if self.currentPlaySpeed == BattleConst.Replay.ReplaySpeedFastNormal then
    self.currentPlaySpeed = BattleConst.Replay.ReplaySpeedSlow
  elseif self.currentPlaySpeed == BattleConst.Replay.ReplaySpeedFast then
    self.currentPlaySpeed = BattleConst.Replay.ReplaySpeedFastNormal
  end
  _G.UE4.UGameplayStatics.SetGlobalTimeDilation(_G.UE4Helper.GetCurrentWorld(), self.currentPlaySpeed)
  _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshPlaySpeedUi, self.currentPlaySpeed)
end

function BattleDebugSkillAutoPlayControl:OnReplayRoundUndo()
  if self.isRoundPlaying and self.currentRoundIndex >= 1 then
    self.currentRoundIndex = self.currentRoundIndex - 1
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\230\173\163\229\156\168\232\189\172\232\183\179\239\188\140\228\184\139\228\184\128\229\155\158\229\144\136\230\152\175\231\172\172 %d \229\155\158\229\144\136", self.currentRoundIndex + 1))
  end
end

function BattleDebugSkillAutoPlayControl:OnReplayRoundRedo()
  if self.isRoundPlaying and self.currentRoundIndex <= #self.configData.roundData then
    self.currentRoundIndex = self.currentRoundIndex + 1
    _G.BattleEventCenter:Dispatch(BattleEvent.Replay_RefreshBottomSkillText, string.format("\230\173\163\229\156\168\232\189\172\232\183\179\239\188\140\228\184\139\228\184\128\229\155\158\229\144\136\230\152\175\231\172\172 %d \229\155\158\229\144\136", self.currentRoundIndex + 1))
  end
end

function BattleDebugSkillAutoPlayControl:OnBattleEvent(eventName, ...)
  if not self.isInBattleTest then
    return
  end
  if eventName == BattleEvent.ROUND_START then
    self:OnRoundStart()
  elseif eventName == BattleEvent.PrepareBattleOver then
    self:OnPrepareBattleOver()
  elseif eventName == BattleEvent.Replay_Exit then
    self:OnReplayExit()
  elseif eventName == BattleEvent.Replay_Pause then
    self:OnReplayPause()
  elseif eventName == BattleEvent.Replay_Resume then
    self:OnReplayResume()
  elseif eventName == BattleEvent.Replay_Fast then
    self:OnReplayFast()
  elseif eventName == BattleEvent.Replay_Slow then
    self:OnReplaySlow()
  elseif eventName == BattleEvent.Replay_Redo then
    self:OnReplayRoundRedo()
  elseif eventName == BattleEvent.Replay_Undo then
    self:OnReplayRoundUndo()
  end
end

return BattleDebugSkillAutoPlayControl
