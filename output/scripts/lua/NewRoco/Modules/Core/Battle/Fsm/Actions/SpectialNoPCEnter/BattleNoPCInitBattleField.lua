local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local BattleNoPCInitBattleField = Base:Extend("BattleNoPCInitBattleField")
FsmUtils.MergeMembers(Base, BattleNoPCInitBattleField, {})

function BattleNoPCInitBattleField:OnEnter()
  _G.BattleManager:InitBattleField()
  self:Finish()
end

return BattleNoPCInitBattleField
