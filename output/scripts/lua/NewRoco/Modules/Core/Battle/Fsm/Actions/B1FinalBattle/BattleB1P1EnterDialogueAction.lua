local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local Base = BattleShowDialogueAction
local BattleB1P1EnterDialogueAction = Base:Extend("BattleB1P1EnterDialogueAction")

function BattleB1P1EnterDialogueAction:OnEnter()
  NRCModuleManager:DoCmd(BlackScreenModuleCmd.OpenGlobalBlackScreenIfNeed, -100, false)
  _G.BattleManager.battleRuntimeData:RemoveB1P1LevelSequence()
  _G.BattleManager.vBattleField.battleCameraManager:ChangeToSkill(0)
  local BattleState = "Battle;Battle;Battle_Type;B1EndWar;Battle_Stage;Stage_1"
  _G.NRCAudioManager:BatchSetState(BattleState)
  local enemyPlayer = _G.BattleManager.battlePawnManager:GetPlayerEnemyTeam()
  if enemyPlayer then
    enemyPlayer:ShowPlayer()
  end
  Base.OnEnter(self)
end

function BattleB1P1EnterDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P1_ROUND1_DIALOGUE").num
end

return BattleB1P1EnterDialogueAction
