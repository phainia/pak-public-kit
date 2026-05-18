local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattlePlaySeqBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlaySeqBaseAction")
local FinalBattleOverPlaySeq2Action = BattlePlaySeqBaseAction:Extend("FinalBattleOverPlaySeq2Action")
FsmUtils.MergeMembers(BattlePlaySeqBaseAction, FinalBattleOverPlaySeq2Action, {})

function FinalBattleOverPlaySeq2Action:OnEnter()
  self:Play(BattleConst.FinalBattleOverSeq2, function(levelSequenceActor)
    local player = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
    levelSequenceActor:SetBindingByTag("Player1", {
      player.model
    }, false)
    levelSequenceActor:SetBindingByTag("Player2", {
      player.model
    }, false)
  end)
end

return FinalBattleOverPlaySeq2Action
