local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleDestroyAction = BattleActionBase:Extend("BattleDestroyAction")
FsmUtils.MergeMembers(BattleActionBase, BattleDestroyAction, {})

function BattleDestroyAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function BattleDestroyAction:OnEnter()
  if BattleUtils.IsReplayMode() then
    BattleReplayCachePool:Reset()
  end
  self.BattleManager = _G.BattleManager
  FsmUtils.ClearAllProperties(self.fsm)
  BattleUtils.SetPlayerSkmTickable(true)
  self.BattleManager:LeaveBattle()
  self:Finish()
end

function BattleDestroyAction:OnExit()
  self.BattleManager = nil
end

return BattleDestroyAction
