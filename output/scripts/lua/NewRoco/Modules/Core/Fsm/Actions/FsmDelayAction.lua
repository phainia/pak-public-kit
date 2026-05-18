local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local FsmDelayAction = Base:Extend("FsmDelayAction")
FsmUtils.MergeMembers(Base, FsmDelayAction, {
  {
    name = "PlayTime",
    type = "number",
    desc = "bla bla bla"
  }
})

function FsmDelayAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function FsmDelayAction:OnEnter()
  if self:InTimeline() then
    return
  end
  _G.DelayManager:CancelDelayByIdEx(self.d_Finish)
  self.d_Finish = _G.DelayManager:DelaySeconds(self:GetProperty("PlayTime", 1.0), self.Finish, self)
end

function FsmDelayAction:OnTick(DeltaTime)
end

function FsmDelayAction:OnFinish()
  Log.DebugFormat("FsmDelayAction:OnFinish %d", self.index)
  self.d_Finish = _G.DelayManager:CancelDelayByIdEx(self.d_Finish)
end

function FsmDelayAction:OnExit()
  Log.Debug("FsmDelayAction:OnExit")
  self.d_Finish = _G.DelayManager:CancelDelayByIdEx(self.d_Finish)
end

function FsmDelayAction:OnFinalize()
  Log.Debug("FsmDelayAction:OnFinalize")
  self.d_Finish = _G.DelayManager:CancelDelayByIdEx(self.d_Finish)
end

return FsmDelayAction
