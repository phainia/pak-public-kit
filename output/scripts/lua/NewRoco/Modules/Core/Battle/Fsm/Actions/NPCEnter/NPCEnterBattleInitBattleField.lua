local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local NPCEnterBattleInitBattleField = Base:Extend("NPCEnterBattleInitBattleField")
FsmUtils.MergeMembers(Base, NPCEnterBattleInitBattleField, {})

function NPCEnterBattleInitBattleField:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientAnimAction)
end

function NPCEnterBattleInitBattleField:OnEnter()
  _G.BattleManager:InitBattleField()
  self:Finish()
end

return NPCEnterBattleInitBattleField
