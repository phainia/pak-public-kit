local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitEvolutionAnimationAction = Base:Extend("BattleWaitEvolutionAnimationAction")
FsmUtils.MergeMembers(Base, BattleWaitEvolutionAnimationAction, {})

function BattleWaitEvolutionAnimationAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitEvolutionAnimationAction:OnEnter()
  self.timeout = 60
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PROCESS_EVOLUTION_END)
  if not _G.BattleManager.battleRuntimeData.isEvolutionWaiting then
    self:Finish()
  end
end

function BattleWaitEvolutionAnimationAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  Base.OnExit(self)
end

function BattleWaitEvolutionAnimationAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  Base.OnFinish(self)
end

function BattleWaitEvolutionAnimationAction:OnWaitEvolutionComplete()
  if not _G.BattleManager.battleRuntimeData.isEvolutionWaiting then
    self:Finish()
  end
end

function BattleWaitEvolutionAnimationAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PROCESS_EVOLUTION_END then
    self:OnWaitEvolutionComplete()
    return true
  end
end

return BattleWaitEvolutionAnimationAction
