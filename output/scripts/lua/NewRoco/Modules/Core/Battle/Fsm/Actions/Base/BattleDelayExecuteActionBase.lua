local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleDelayExecuteActionBase = Base:Extend("BattleDelayExecuteActionBase")
FsmUtils.MergeMembers(Base, BattleDelayExecuteActionBase, {})

function BattleDelayExecuteActionBase:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.StartDelegate = self:GetProperty("StartDelegate")
  self.CompleteDelegate = self:GetProperty("CompleteDelegate")
end

function BattleDelayExecuteActionBase:DoEnter()
  self.needDelayExecute = false
  if self.StartDelegate then
    self.needDelayExecute = true
  end
  Base.DoEnter(self)
end

function BattleDelayExecuteActionBase:OnEnter()
  if self.StartDelegate then
    self.StartDelegate:Add(self, self.DelayRun)
  else
    self:DelayRun()
  end
end

function BattleDelayExecuteActionBase:DelayRun()
  if self.StartDelegate then
    self.StartDelegate:Clear()
  end
end

function BattleDelayExecuteActionBase:DelayComplete()
  if self.needDelayExecute and self.CompleteDelegate then
    self.CompleteDelegate:Invoke()
    self.CompleteDelegate:Clear()
  end
end

function BattleDelayExecuteActionBase:Finish()
  Base.Finish(self)
  if self.needDelayExecute then
  end
end

function BattleDelayExecuteActionBase:OnExit()
end

return BattleDelayExecuteActionBase
