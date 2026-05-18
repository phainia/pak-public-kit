local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleWaitRoleHpAnimationAction = Base:Extend("BattleWaitRoleHpAnimationAction")
FsmUtils.MergeMembers(Base, BattleWaitRoleHpAnimationAction, {})

function BattleWaitRoleHpAnimationAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleWaitRoleHpAnimationAction:OnEnter()
  self.timeout = 10
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PROCESS_ROLE_HP_END)
  if not _G.BattleManager.battleRuntimeData.isWaitingRoleHP then
    self:Finish()
  end
end

function BattleWaitRoleHpAnimationAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  Base.OnExit(self)
end

function BattleWaitRoleHpAnimationAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  Base.OnFinish(self)
end

function BattleWaitRoleHpAnimationAction:OnWaitRoleHpComplete()
  if not _G.BattleManager.battleRuntimeData.isWaitingRoleHP then
    self:Finish()
  end
end

function BattleWaitRoleHpAnimationAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PROCESS_ROLE_HP_END then
    self:OnWaitRoleHpComplete()
    return true
  end
end

return BattleWaitRoleHpAnimationAction
