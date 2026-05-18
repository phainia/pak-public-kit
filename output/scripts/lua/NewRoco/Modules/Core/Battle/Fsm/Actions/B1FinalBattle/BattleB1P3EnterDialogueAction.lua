local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local Base = BattleShowDialogueAction
local BattleB1P3EnterDialogueAction = Base:Extend("BattleB1P3EnterDialogueAction")

function BattleB1P3EnterDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P3_ROUND1_DIALOGUE").num
end

return BattleB1P3EnterDialogueAction
