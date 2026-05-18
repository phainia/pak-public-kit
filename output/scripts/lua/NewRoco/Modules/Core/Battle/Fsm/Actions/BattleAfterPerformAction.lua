local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePlayAnimBaseAction
local BattleAfterPerformAction = Base:Extend("BattleAfterPerformAction")
FsmUtils.MergeMembers(Base, BattleAfterPerformAction, {})

function BattleAfterPerformAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleAfterPerformAction:OnEnter()
  if _G.BattleManager.battleRuntimeData:GetEnterBattleType() == ProtoEnum.BattleEnterType.BET_CONTACT then
    self.fsm:SendEvent(BattleEvent.EnterNearbyEnter, self)
  else
    self.fsm:SendEvent(BattleEvent.EnterNearbyThrowBall, self)
  end
end

return BattleAfterPerformAction
