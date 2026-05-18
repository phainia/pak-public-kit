local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleRecycleBattleFieldAction = Base:Extend("BattleRecycleBattleFieldAction")
FsmUtils.MergeMembers(Base, BattleRecycleBattleFieldAction, {})

function BattleRecycleBattleFieldAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRecycleBattleFieldAction:OnEnter()
  self.battleRuntimeData:Reset()
  self.battleRuntimeData.battleSettleData:Reset()
  self.battlePawnManager:LeaveBattle()
  self.vBattleField:LeaveBattle()
  self.battleObjectManager:LeaveBattle()
  self:Finish()
end

function BattleRecycleBattleFieldAction:OnExit()
end

return BattleRecycleBattleFieldAction
