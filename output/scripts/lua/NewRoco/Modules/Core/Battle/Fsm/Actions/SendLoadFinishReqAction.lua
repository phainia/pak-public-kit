local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoMessage = require("Data.PB.ProtoMessage")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local SendLoadFinishReqAction = BattleActionBase:Extend("SendLoadFinishReqAction")

function SendLoadFinishReqAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleNetManager = _G.BattleNetManager
  self:SetActionType(BattleActionBase.ActionType.ServerReqAction)
end

function SendLoadFinishReqAction:OnEnter()
  BattleUtils.CloseBattleAndTaskBlackLoading()
  local state = BattleUtils.GetBattleInitInfo().battle_state
  local seqNumber = BattleUtils.GetServerWaitRoundSeqByPlayer(BattleManager.battlePawnManager.TeamatePlayer) or 0
  if 0 == seqNumber then
    seqNumber = BattleManager:GetSeqNumber() or 0
  end
  Log.Debug("zgx SendLoadFinishReqAction state is ", state)
  if state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_PRE_PLAY then
    self.BattleNetManager:SendBattleRoundFlowFinishReq(seqNumber, state)
    self:Finish()
  elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PET or state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_CMD or state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_EVOLUTION or state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_SELECT_PET or state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_CATCH then
    local StartParam = self.BattleManager.battleRuntimeData.battleStartParam
    local RuntimeData = self.BattleManager.battleRuntimeData
    local fakeNotify = ProtoMessage:newZoneBattleRoundStartNotify()
    fakeNotify.state_info = ProtoMessage:newBattleStateInfo()
    if state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PET then
      fakeNotify.state_type = _G.ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_PET
    elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_EVOLUTION then
      fakeNotify.state_type = _G.ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_EVOLUTION
    elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_SELECT_PET then
      fakeNotify.state_type = _G.ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_ROUND_SELECT_PET
    elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_CATCH then
      fakeNotify.state_type = _G.ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_CATCH
    else
      fakeNotify.state_type = _G.ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_CMD
    end
    fakeNotify.state_info.round = RuntimeData.roundIndex
    fakeNotify.state_info.round_time = RuntimeData.roundTime
    fakeNotify.state_info.player_team = StartParam.battleInitInfo.player_team
    fakeNotify.state_info.enemy_team = StartParam.battleInitInfo.enemy_team
    fakeNotify.state_info.world_leader_fight_info = StartParam.battleInitInfo.world_leader_fight_info
    fakeNotify.state_info.final_battle_data = StartParam.battleInitInfo.final_battle
    fakeNotify.state_info.b1_final_battle_data = StartParam.battleInitInfo.b1_final_battle
    fakeNotify.state_info.evolution_data = StartParam.battleInitInfo.evolution_data
    self.BattleManager:OnBattleRoundStartNotify(fakeNotify)
  elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PETY then
    self.BattleNetManager:SendBattleRoundFlowFinishReq(seqNumber, state)
    self:Finish()
  elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_PLAY then
    local StartParam = self.BattleManager.battleRuntimeData.battleStartParam
    if not StartParam:CheckInitState(ProtoEnum.BATTLEFIELD_BIT_TYPE.BT_FINAL_BATTLE_SWITCH_TO_P2) then
      self.BattleNetManager:SendBattleRoundFlowFinishReq(seqNumber, state)
    end
    self:Finish()
  elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_NPC_AI then
    self.BattleNetManager:SendBattleRoundFlowFinishReq(seqNumber, state)
    self:Finish()
  elseif state == _G.ProtoEnum.BATTLEFIELD_STATE.BATTLEFIELD_STATE_ROUND_MONSTER_EX_MOVE then
    self.BattleNetManager:SendBattleRoundFlowFinishReq(seqNumber, state)
    self:Finish()
  else
    self.BattleNetManager:SendBattleLoadFinishReq(ProtoMessage:newZoneBattleLoadFinishReq(), self, self.OnRsp)
    if BattleUtils.IsBattleServeWaitingLoad() then
      self.fsm:SendEvent(BattleEvent.EnterWaitOtherLoad, nil, {
        self.state.name
      })
    end
    self:Finish()
  end
end

function SendLoadFinishReqAction:OnRsp(rsp)
end

function SendLoadFinishReqAction:OnFinish()
  self:DestroyProperty(BattleConst.BattleStand.CameraID1)
  self:DestroyProperty(BattleConst.BattleStand.CameraID1_SA)
  self:DestroyProperty(BattleConst.BattleStand.CameraID2)
  self:DestroyProperty(BattleConst.BattleStand.CameraID2_SA)
  self:DestroyProperty(BattleConst.BattleStand.CameraRoot)
  if not BattleUtils.IsTeam() then
    BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_TEAM, false)
    BattleUtils.SetTeamCollisionState(BattleEnum.Team.ENUM_ENEMY, false)
  end
  self:DestroyProperty(BattleConst.InPlace.Cam1)
  self:DestroyProperty(BattleConst.InPlace.Cam1_SA)
  self:DestroyProperty(BattleConst.InPlace.Cam3)
  self:DestroyProperty(BattleConst.InPlace.Cam3_SA)
  self:DestroyProperty(BattleConst.InPlace.BGFX)
end

function SendLoadFinishReqAction:DestroyProperty(name)
  FsmUtils.ClearProperty(self.fsm, name)
end

function SendLoadFinishReqAction:OnExit()
  self:OnFinish()
  _G.NRCSDKManager:PerfEndExclude("enter battle")
end

return SendLoadFinishReqAction
