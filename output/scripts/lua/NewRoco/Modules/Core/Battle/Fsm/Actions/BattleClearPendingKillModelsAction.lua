local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleClearPendingKillModelsAction = Base:Extend("BattleClearPendingKillModelsAction")
FsmUtils.MergeMembers(Base, BattleClearPendingKillModelsAction, {})

function BattleClearPendingKillModelsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleClearPendingKillModelsAction:OnEnter()
  local pawnManager = _G.BattleManager.battlePawnManager
  pawnManager:ClearPendingKillModels()
  self:Finish()
end

return BattleClearPendingKillModelsAction
