local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattlePureBlackOutSendReqAction = Base:Extend("BattlePureBlackOutSendReqAction")
FsmUtils.MergeMembers(Base, BattlePureBlackOutSendReqAction, nil)

function BattlePureBlackOutSendReqAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.SkillFinished = false
  self.ServerResponded = false
  self:SetActionType(BattleActionBase.ActionType.ServerReqAction)
end

function BattlePureBlackOutSendReqAction:OnEnter()
  self:SendRoundFlowFinish()
end

function BattlePureBlackOutSendReqAction:SendRoundFlowFinish()
  local Flows = self:GetProperty("Flows")
  local Req
  if Flows then
    Req = BattleNetManager:CreateBattleRoundFlowFinishReq(Flows.seq_num)
  else
    Log.Error("zgx \228\184\165\233\135\141\233\148\153\232\175\175\239\188\129\239\188\129\239\188\129  RoundFlowFinish \230\178\161\230\156\137 \229\186\143\229\136\151\229\143\183")
    Req = ProtoMessage:newZoneBattleRoundFlowFinishReq()
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_FLOW_FINISH_REQ, Req, self, self.OnNetRsp, false, true)
end

function BattlePureBlackOutSendReqAction:OnNetRsp()
  self.ServerResponded = true
  if BattleExitHelper.IsFinishHandleSeamless() then
    self:Finish()
  else
    self:CheckFinish()
  end
end

function BattlePureBlackOutSendReqAction:CheckFinish()
  if not self.ServerResponded then
    return
  end
  Log.Debug("All Finished, Leave!")
  self.ServerResponded = false
  self.fsm:SendEvent(BattleEvent.DirectOverBattle)
end

function BattlePureBlackOutSendReqAction:OnExit()
end

return BattlePureBlackOutSendReqAction
