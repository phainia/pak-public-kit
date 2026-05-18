local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local TrainBattleEnterPerformAction = Base:Extend("TrainBattleEnterPerformAction")
FsmUtils.MergeMembers(Base, TrainBattleEnterPerformAction, {})

function TrainBattleEnterPerformAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function TrainBattleEnterPerformAction:OnEnter()
  self:AdjustCamera()
  self:Finish()
end

function TrainBattleEnterPerformAction:AdjustCamera(Event, skill)
  BattleManager.vBattleField.battleCameraManager:CalcPosCache()
  BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0)
end

function TrainBattleEnterPerformAction:OnFinish()
end

function TrainBattleEnterPerformAction:OnExit()
end

return TrainBattleEnterPerformAction
