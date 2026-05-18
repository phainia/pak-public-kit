local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattlePVPShowFailPlayer = BattleActionBase:Extend("BattlePVPShowFailPlayer")

function BattlePVPShowFailPlayer:OnEnter()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, true)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  self.battleManager = _G.BattleManager
  if self.battleManager.battleRuntimeData.battleSettleData:BattleIsWin() then
    self.player = self.battleManager.battlePawnManager.EnemyPlayer
  else
    self.player = self.battleManager.battlePawnManager.TeamatePlayer
  end
  if self.player and not self.player.destroyed and self.player.model then
    if self.player.teamEnm == BattleEnum.Team.ENUM_TEAM then
      self.battleManager.vBattleField.battleCameraManager:ChangeToPlayerChangePet(0.5, nil, nil, true)
    else
      self.battleManager.vBattleField.battleCameraManager:ChangeToSkill(0.5, nil, nil, true)
    end
    self.player.model:PlayAnimByName("Sad1", 1, -1, 0, 0, 1, -1)
    self:SafeDelaySeconds("d_Finish", 2, self.Finish, self)
  else
    self:Finish()
  end
end

function BattlePVPShowFailPlayer:OnFinish()
  self.battleManager = nil
end

return BattlePVPShowFailPlayer
