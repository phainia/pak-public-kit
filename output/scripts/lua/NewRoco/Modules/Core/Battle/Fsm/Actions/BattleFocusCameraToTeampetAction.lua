local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleFocusCameraToTeampetAction = Base:Extend("BattleFocusCameraToTeampetAction")
FsmUtils.MergeMembers(Base, BattleFocusCameraToTeampetAction, {})

function BattleFocusCameraToTeampetAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleFocusCameraToTeampetAction:OnEnter()
  if not BattleManager.battlePawnManager.playerTeam or not BattleManager.battlePawnManager.enemyTeam then
    self:Finish()
    return
  end
  local cameraManager = _G.BattleManager.vBattleField.battleCameraManager
  if cameraManager then
    cameraManager:ChangeToPlayerPet(0)
  end
  self:Finish()
end

function BattleFocusCameraToTeampetAction:OnExit()
end

return BattleFocusCameraToTeampetAction
