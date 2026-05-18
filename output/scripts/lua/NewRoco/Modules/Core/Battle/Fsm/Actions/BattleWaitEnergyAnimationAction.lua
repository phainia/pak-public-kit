local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitEnergyAnimationAction = Base:Extend("BattleWaitEnergyAnimationAction")
FsmUtils.MergeMembers(Base, BattleWaitEnergyAnimationAction, {})

function BattleWaitEnergyAnimationAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitEnergyAnimationAction:OnEnter()
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PROCESS_ENERGY_TRACK_END)
  local BattleMain = BattleUtils.GetMainWindow()
  if not BattleMain then
    self:Finish()
    return
  end
  if not BattleMain.needProcessEnergyTrack then
    self:Finish()
  end
end

function BattleWaitEnergyAnimationAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  Base.OnExit(self)
end

function BattleWaitEnergyAnimationAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  Base.OnFinish(self)
end

function BattleWaitEnergyAnimationAction:OnWaitEnergyComplete()
  local BattleMain = BattleUtils.GetMainWindow()
  if not BattleMain.needProcessEnergyTrack then
    self:Finish()
  end
end

function BattleWaitEnergyAnimationAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PROCESS_ENERGY_TRACK_END then
    self:OnWaitEnergyComplete()
    return true
  end
end

return BattleWaitEnergyAnimationAction
