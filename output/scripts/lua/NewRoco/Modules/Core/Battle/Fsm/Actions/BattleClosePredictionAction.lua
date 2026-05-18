local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleClosePredictionAction = Base:Extend("BattleClosePredictionAction")
FsmUtils.MergeMembers(Base, BattleClosePredictionAction, {})

function BattleClosePredictionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleClosePredictionAction:OnEnter()
  BattleUtils.DisableSkillPrediction()
  self:Finish()
end

function BattleClosePredictionAction:OnExit()
end

return BattleClosePredictionAction
