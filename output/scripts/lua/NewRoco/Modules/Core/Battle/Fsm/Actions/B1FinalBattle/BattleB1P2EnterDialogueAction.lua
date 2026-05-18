local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local Base = BattleShowDialogueAction
local BattleB1P2EnterDialogueAction = Base:Extend("BattleB1P2EnterDialogueAction")

function BattleB1P2EnterDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P2_ROUND1_DIALOGUE").num
end

return BattleB1P2EnterDialogueAction
