local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = FsmAction
local BattleServerBranchActionBase = Base:Extend("BattleServerBranchActionBase")
FsmUtils.MergeMembers(Base, BattleServerBranchActionBase, {})

function BattleServerBranchActionBase:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleServerBranchActionBase:OnEnter()
end

function BattleServerBranchActionBase:OnExit()
end

return BattleServerBranchActionBase
