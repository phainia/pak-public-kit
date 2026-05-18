local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattlePlaySeqBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlaySeqBaseAction")
local FinalBattleOverPlaySeq1Action = BattlePlaySeqBaseAction:Extend("FinalBattleOverPlaySeq1Action")
FsmUtils.MergeMembers(BattlePlaySeqBaseAction, FinalBattleOverPlaySeq1Action, {})

function FinalBattleOverPlaySeq1Action:OnEnter()
  self:Play(BattleConst.FinalBattleOverSeq1, function(levelSequenceActor)
    local player = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
    levelSequenceActor:SetBindingByTag("Player1", {
      player.model
    }, false)
    levelSequenceActor:SetBindingByTag("Player2", {
      player.model
    }, false)
  end)
  self:FadeOutBlackScreen()
end

function FinalBattleOverPlaySeq1Action:FadeOutBlackScreen()
  if UE4.UObject.IsValid(_G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObject) then
    _G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObject.Blackboard:SetValueAsBool("End", false)
  end
  _G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObject = nil
  _G.BattleManager.battleRuntimeData.finalBattleInfo.bossDeadBlackScreenSkillObjectRef = nil
end

return FinalBattleOverPlaySeq1Action
