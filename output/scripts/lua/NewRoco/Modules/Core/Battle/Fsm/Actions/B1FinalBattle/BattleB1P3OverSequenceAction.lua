local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleB1P3OverSequenceAction = Base:Extend("BattleB1P3OverSequenceAction")
FsmUtils.MergeMembers(Base, BattleB1P3OverSequenceAction, {})

function BattleB1P3OverSequenceAction:OnEnter()
  self:Play(BattleConst.B1P3OverSequence, function(levelSequenceActor)
    Log.Warning("BattleB1P2EnterSequenceAction:OnEnter")
  end)
end

function BattleB1P3OverSequenceAction:OnFinish()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenLoading)
end

return BattleB1P3OverSequenceAction
