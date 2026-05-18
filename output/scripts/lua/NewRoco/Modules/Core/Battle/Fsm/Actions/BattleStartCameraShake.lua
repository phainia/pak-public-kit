local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleStartCameraShake = Base:Extend("BattleStartCameraShake")
FsmUtils.MergeMembers(Base, BattleStartCameraShake, {})

function BattleStartCameraShake:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleStartCameraShake:OnEnter()
  BattleManager.vBattleField.battleCraneCamera:EnableShake()
  self:Finish()
end

return BattleStartCameraShake
