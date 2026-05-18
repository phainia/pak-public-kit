local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleStopCameraShake = Base:Extend("BattleStopCameraShake")
FsmUtils.MergeMembers(Base, BattleStopCameraShake, {})

function BattleStopCameraShake:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleStopCameraShake:OnEnter()
  if BattleManager.vBattleField and BattleManager.vBattleField.battleCraneCamera then
    BattleManager.vBattleField.battleCraneCamera:DisableShake()
  end
  self:Finish()
end

return BattleStopCameraShake
