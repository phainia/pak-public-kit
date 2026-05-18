local BattleTrainCloseDialogueAction = BattleActionBase:Extend("BattleTrainCloseDialogueAction")

function BattleTrainCloseDialogueAction:OnEnter()
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.CloseDialogueInBattle)
  self:Finish()
end

function BattleTrainCloseDialogueAction:OnFinish()
end

return BattleTrainCloseDialogueAction
