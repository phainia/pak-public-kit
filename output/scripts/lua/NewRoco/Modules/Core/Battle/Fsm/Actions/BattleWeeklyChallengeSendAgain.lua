local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleWeeklyChallengeSendAgain = BattleActionBase:Extend("BattleWeeklyChallengeSendAgain")
FsmUtils.MergeMembers(BattleActionBase, BattleWeeklyChallengeSendAgain, {})

function BattleWeeklyChallengeSendAgain:OnEnter()
  _G.NRCModeManager:DoCmd(WeeklyChallengeBattleModuleCmd.SendWeeklyChallengeBattleAgain)
  self:Finish()
end

return BattleWeeklyChallengeSendAgain
