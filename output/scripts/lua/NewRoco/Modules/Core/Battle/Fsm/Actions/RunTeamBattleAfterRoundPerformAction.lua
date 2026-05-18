local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local RunTeamBattleAfterRoundPerformAction = BattleActionBase:Extend("RunTeamBattleAfterRoundPerformAction")
FsmUtils.MergeMembers(BattleActionBase, RunTeamBattleAfterRoundPerformAction, {
  {name = "Flows", type = "table"}
})

function RunTeamBattleAfterRoundPerformAction:OnEnter()
  if BattleUtils.IsTeam() then
    local Flows = self:GetProperty("Flows")
    BattleManager:TeamBattlePerformFinish(Flows)
  end
  self:Finish()
end

return RunTeamBattleAfterRoundPerformAction
