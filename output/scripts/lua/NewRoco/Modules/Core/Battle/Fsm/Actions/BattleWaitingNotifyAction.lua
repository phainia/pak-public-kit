local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleWaitingNotifyAction = Base:Extend("BattleWaitingNotifyAction")
FsmUtils.MergeMembers(Base, BattleWaitingNotifyAction, {
  {
    name = "PlayTime",
    type = "number",
    desc = "bla bla bla"
  }
})

function BattleWaitingNotifyAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.delayID = nil
  self:SetActionType(BattleActionBase.ActionType.ClientLimmitedPlayerSelectAction)
end

function BattleWaitingNotifyAction:OnEnter()
  if self:InTimeline() then
    return
  end
  Log.Debug("self:GetProperty(PlayTime, 1.0)", self:GetProperty("PlayTime", 1.0))
  self.delayID = _G.DelayManager:DelaySeconds(self:GetProperty("PlayTime", 1.0), self.Finish, self)
end

function BattleWaitingNotifyAction:OnFinish()
  Log.DebugFormat("BattleWaitingNotifyAction:OnFinish %d", self.index)
  if self.delayID then
    DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

function BattleWaitingNotifyAction:OnExit()
  Log.Debug("BattleWaitingNotifyAction:OnExit")
  if self.delayID then
    DelayManager:CancelDelayById(self.delayID)
    self.delayID = nil
  end
end

function BattleWaitingNotifyAction:OnFinalize()
  Log.Debug("BattleWaitingNotifyAction:OnFinalize")
end

return BattleWaitingNotifyAction
