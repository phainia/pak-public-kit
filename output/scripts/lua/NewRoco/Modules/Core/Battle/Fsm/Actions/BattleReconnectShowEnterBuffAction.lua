local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleReconnectShowEnterBuffAction = BattleActionBase:Extend("BattleReconnectShowEnterBuffAction")
FsmUtils.MergeMembers(BattleActionBase, BattleReconnectShowEnterBuffAction, {})

function BattleReconnectShowEnterBuffAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function BattleReconnectShowEnterBuffAction:OnEnter()
  self:Finish()
end

function BattleReconnectShowEnterBuffAction:OnExit()
end

return BattleReconnectShowEnterBuffAction
