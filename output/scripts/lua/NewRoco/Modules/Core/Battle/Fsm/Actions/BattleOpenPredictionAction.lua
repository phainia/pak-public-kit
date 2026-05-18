local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleOpenPredictionAction = Base:Extend("BattleOpenPredictionAction")
FsmUtils.MergeMembers(Base, BattleOpenPredictionAction, {})

function BattleOpenPredictionAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleOpenPredictionAction:OnEnter()
  self.delayId = _G.DelayManager:DelaySeconds(1, self.ShowPrediction, self)
  self:Finish()
end

function BattleOpenPredictionAction:ShowPrediction()
  BattleUtils.EnableSkillPrediction()
end

function BattleOpenPredictionAction:OnExit()
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

return BattleOpenPredictionAction
