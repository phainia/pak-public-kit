local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleStopBattleStandAnimation = Base:Extend("BattlePlayBattleStandAnimAction")
FsmUtils.MergeMembers(Base, BattleStopBattleStandAnimation, {})

function BattleStopBattleStandAnimation:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleStopBattleStandAnimation:OnEnter()
  self:OnTick()
end

function BattleStopBattleStandAnimation:OnTick(DeltaTime)
  if not BattleManager:IsFocusingPet() then
    BattleManager:StopFocus()
    self:Finish()
  end
end

return BattleStopBattleStandAnimation
