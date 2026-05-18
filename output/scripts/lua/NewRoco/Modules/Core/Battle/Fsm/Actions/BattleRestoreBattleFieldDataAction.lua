local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleRestoreBattleFieldDataAction = Base:Extend("BattleRestoreBattleFieldDataAction")
FsmUtils.MergeMembers(Base, BattleRestoreBattleFieldDataAction, {})

function BattleRestoreBattleFieldDataAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRestoreBattleFieldDataAction:OnEnter()
  self:Finish()
end

function BattleRestoreBattleFieldDataAction:OnExit()
end

return BattleRestoreBattleFieldDataAction
