local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FinalBattleOverAction = BattleActionBase:Extend("FinalBattleOverAction")
FsmUtils.MergeMembers(BattleActionBase, FinalBattleOverAction, {})

function FinalBattleOverAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function FinalBattleOverAction:OnEnter()
  local filePath = "/Game/ArtRes/AnimSequence/Sequence/Plot/JQ/JQ08/JQ08_CS05_a/JQ08_CS05_a_Master.JQ08_CS05_a_Master"
  Log.Debug("BattlePiecesNpcAIPerform:Play ", filePath)
  _G.BattleResourceManager:LoadResAsync(self, filePath, self.OnLoadSequence, self.OnLoadSequenceFailed)
end

function FinalBattleOverAction:OnLoadSequence(leveSequenceRes)
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  NRCModeManager:DoCmd(BattleUIModuleCmd.MainHideAll, false)
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseWishPowerPanel)
  local Settings = UE4.FMovieSceneSequencePlaybackSettings()
  local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
  self.levelSequenceActor = {}
  local levelSequenceActor, levelSequencePlayer = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(battleFieldActor, leveSequenceRes, Settings, self.levelSequenceActor)
  levelSequenceActor:SetBindingByTag("Player1", {
    self.ActorHolder.Player1
  }, false)
  levelSequenceActor:SetBindingByTag("Player2", {
    self.ActorHolder.Player2
  }, false)
  levelSequenceActor:SetBindingByTag("PlayerCenter", {
    self.ActorHolder.PlayerCenter
  }, false)
  levelSequenceActor:SetBindingByTag("PlayerPet", {
    self.playerActor
  }, false)
  self.levelSequence = levelSequencePlayer
  if self.levelSequence then
    battleFieldActor:SetCacheLSCall(self, self.Complete)
    self.levelSequence.OnFinished:Add(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
    local EnableRebasing = UE4.UNRCStatics.IsEnabledWorldRebasing(CurrentWorld)
    if true == EnableRebasing then
      levelSequenceActor:ApplyWorldOffsetToSequence()
    end
    self.levelSequence:Play()
    _G.BattleManager:ModifySceneSpotLight(false)
  end
end

function FinalBattleOverAction:OnSeq1Finish()
end

function FinalBattleOverAction:OnFinish()
  _G.BattleManager:ModifySceneSpotLight(true)
end

return FinalBattleOverAction
