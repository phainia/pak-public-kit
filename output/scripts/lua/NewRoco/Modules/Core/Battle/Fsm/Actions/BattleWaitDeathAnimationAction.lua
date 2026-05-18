local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitDeathAnimationAction = Base:Extend("BattleWaitDeathAnimationAction")
FsmUtils.MergeMembers(Base, BattleWaitDeathAnimationAction, {})

function BattleWaitDeathAnimationAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitDeathAnimationAction:OnEnter()
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PET_DEATH_PENDING_ANIMATION_FINISH)
  if BattleUtils.CheckPetDeathPendingCntClear() then
    self:Finish()
  end
end

function BattleWaitDeathAnimationAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  Base.OnExit(self)
end

function BattleWaitDeathAnimationAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  Base.OnFinish(self)
end

function BattleWaitDeathAnimationAction:OnDeathAnimationComplete()
  self:Finish()
end

function BattleWaitDeathAnimationAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PET_DEATH_PENDING_ANIMATION_FINISH then
    self:OnDeathAnimationComplete()
    return true
  end
end

return BattleWaitDeathAnimationAction
