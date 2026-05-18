local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleIntroSelectAction = BattleActionBase:Extend("BattleIntroSelectAction")

function BattleIntroSelectAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleIntroSelectAction:OnEnter()
  if BattleUtils.IsPvp() then
  elseif BattleUtils.IsPve() then
    self.fsm:SendEvent(BattleEvent.PVEIntro, self)
  elseif BattleUtils.IsSpecialDelayPve() then
    self.fsm:SendEvent(BattleEvent.PVESpecialDelay, self)
  elseif BattleUtils.IsLeaderFight() then
    self.fsm:SendEvent(BattleEvent.LeaderIntro, self)
  elseif BattleUtils.IsWorldLeaderFight() then
    self.fsm:SendEvent(BattleEvent.WorldLeaderIntro, self)
  elseif BattleUtils.IsLeaderChallenge() then
    self.fsm:SendEvent(BattleEvent.WorldLeaderIntro, self)
  else
    self.fsm:SendEvent(BattleEvent.Intro, self)
  end
end

function BattleIntroSelectAction:OnExit()
end

return BattleIntroSelectAction
