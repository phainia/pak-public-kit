local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattlePlaySeqBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlaySeqBaseAction")
local FinalBattlePlayP1OverSeqAction = BattlePlaySeqBaseAction:Extend("FinalBattlePlayP1OverSeqAction")
FsmUtils.MergeMembers(BattlePlaySeqBaseAction, FinalBattlePlayP1OverSeqAction, {})

function FinalBattlePlayP1OverSeqAction:Ctor(name, properties)
  BattlePlaySeqBaseAction.Ctor(self, name, properties)
end

function FinalBattlePlayP1OverSeqAction:OnEnter()
  self:Play(BattleConst.FinalBattleP1ToP2Seq, function(levelSequenceActor)
    local player = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
    levelSequenceActor:SetBindingByTag("Player1", {
      player.model
    }, false)
    levelSequenceActor:SetBindingByTag("Player2", {
      player.model
    }, false)
  end)
end

function FinalBattlePlayP1OverSeqAction:Play(path, bindingFunc)
  local leveSequenceRes = _G.BattleResourceManager:GetCacheAssetDirect(path)
  if leveSequenceRes then
    local Settings = UE4.FMovieSceneSequencePlaybackSettings()
    Settings.bPauseAtEnd = true
    local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
    self.levelSequenceActor = {}
    local levelSequenceActor, levelSequencePlayer = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(battleFieldActor, leveSequenceRes, Settings, self.levelSequenceActor)
    if bindingFunc then
      bindingFunc(levelSequenceActor)
    end
    self.levelSequence = levelSequencePlayer
    if self.levelSequence then
      self.levelSequence:SetTimeRange(0, 61.15)
      battleFieldActor:SetCacheLSCall(self, self.ToFinish)
      self.levelSequence.OnFinished:Add(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
      local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
      local EnableRebasing = UE4.UNRCStatics.IsEnabledWorldRebasing(CurrentWorld)
      if true == EnableRebasing then
        levelSequenceActor:ApplyWorldOffsetToSequence()
      end
      self.levelSequence:Play()
      _G.BattleManager:ModifySceneSpotLight(false)
    end
    return levelSequenceActor
  else
    self:Finish()
  end
end

function FinalBattlePlayP1OverSeqAction:ToFinish()
  BattleManager.CacheSequencer = self.levelSequence
  _G.BattleManager:ModifySceneSpotLight(true)
  self:Finish()
end

function FinalBattlePlayP1OverSeqAction:OnFinish()
  if self.DelayOver then
    _G.DelayManager:CancelDelayById(self.DelayOver)
    self.DelayOver = nil
  end
  if self.levelSequence then
    local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
    self.levelSequence.OnFinished:Remove(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    self.levelSequence = nil
  end
  self.fsm:Resume()
end

return FinalBattlePlayP1OverSeqAction
