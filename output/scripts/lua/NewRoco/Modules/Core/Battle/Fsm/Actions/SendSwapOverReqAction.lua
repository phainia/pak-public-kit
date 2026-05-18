local ProtoMessage = require("Data.PB.ProtoMessage")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local SendSwapOverReqAction = Base:Extend("SendSwapOverReqAction")
FsmUtils.MergeMembers(Base, SendSwapOverReqAction, {})

function SendSwapOverReqAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ServerReqAction)
end

function SendSwapOverReqAction:OnEnter()
  ProtoMessage:newBattleObserveLeaveNotify()
  self:Finish()
end

function SendSwapOverReqAction:OnExit()
end

return SendSwapOverReqAction
