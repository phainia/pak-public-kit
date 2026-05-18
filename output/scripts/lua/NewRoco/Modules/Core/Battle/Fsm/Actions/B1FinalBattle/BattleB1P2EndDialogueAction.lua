local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local Base = BattleShowDialogueAction
local BattleB1P2EndDialogueAction = Base:Extend("BattleB1P2EndDialogueAction")

function BattleB1P2EndDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P2_END_DIALOGUE").num
end

function BattleB1P2EndDialogueAction:OnDialogueEnd()
  Log.Debug("BattleB1P2EndDialogueAction:OnDialogueEnd")
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, false, self, self.Finish)
end

function BattleB1P2EndDialogueAction:OnFinish()
  if self.fsm and self.fsm.Resume then
    self.fsm:Resume()
  end
end

return BattleB1P2EndDialogueAction
