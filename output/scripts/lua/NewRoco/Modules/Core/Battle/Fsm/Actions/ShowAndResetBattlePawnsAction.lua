local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local ShowAndResetBattlePawnsAction = Base:Extend("ShowAndResetBattlePawnsAction")
FsmUtils.MergeMembers(Base, ShowAndResetBattlePawnsAction, {})

function ShowAndResetBattlePawnsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function ShowAndResetBattlePawnsAction:OnEnter()
  BattleUtils.ShowAndResetBattlePawns()
  self:Finish()
end

function ShowAndResetBattlePawnsAction:OnFinish()
end

function ShowAndResetBattlePawnsAction:OnExit()
end

return ShowAndResetBattlePawnsAction
