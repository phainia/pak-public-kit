local BattlePiecesPlaySkill = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesPlaySkill")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local Base = BattlePiecesPlaySkill
local BattleFinalP1EnterPerform = Base:Extend("BattleFinalP1EnterPerform")

function BattleFinalP1EnterPerform:Play(action, finishCallBack)
  self.TriggerAction = action
  self.FinishCallBack = finishCallBack
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  self.resList = {
    BattleConst.FinalBattleP1EnterSeq
  }
  Base.Play(self)
end

function BattleFinalP1EnterPerform:StartPreLoad()
  if self.resList and #self.resList > 0 then
    self.loadedResCount = 0
    for i = 1, #self.resList do
      _G.BattleResourceManager:LoadResAsync(self, self.resList[i], self.PreloadAssetCallBack, self.PreloadAssetCallBack)
    end
  else
    self:OnResLoadFinish()
  end
end

function BattleFinalP1EnterPerform:PreloadAssetCallBack(Resource)
  if not Resource then
    Log.Error("cannot preload assert", self.loadedResCount)
  end
  if not Resource.GetDefaultObject then
    Log.Error("loaded assert is not a uclass resource", Resource)
  end
  Log.Info("preload", self.loadedResCount, Resource)
  self.loadedResCount = self.loadedResCount + 1
  if self.loadedResCount == #self.resList then
    self:OnResLoadFinish()
  end
end

function BattleFinalP1EnterPerform:OnResLoadFinish()
  if not BattleManager:IsInBattle(true) then
    return
  end
  BattleEventCenter:UnBind(self)
  NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local leveSequenceRes = BattleResourceManager:GetCacheAssetDirect(self.resList[1])
  local Settings = UE4.FMovieSceneSequencePlaybackSettings()
  Settings.bPauseAtEnd = true
  local battleFieldActor = BattleManager.vBattleField.battleFieldActor
  BattleManager.vBattleField:MoveToLocation(BattleManager.battleRuntimeData.TeleportBattleCenter, 0)
  self.levelSequenceActor = {}
  local levelSequenceActor, levelSequencePlayer
  levelSequenceActor, levelSequencePlayer = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(battleFieldActor, leveSequenceRes, Settings, self.levelSequenceActor)
  if levelSequenceActor and localPlayer then
    levelSequenceActor:SetBindingByTag("Player1", {
      localPlayer.model
    }, false)
    levelSequenceActor:SetBindingByTag("Player2", {
      localPlayer.model
    }, false)
  end
  self.levelSequence = levelSequencePlayer
  if self.levelSequence then
    local EndTime = levelSequencePlayer:GetEndTime()
    local EndSeconds = EndTime.Time.FrameNumber.Value / (EndTime.Rate.Numerator / EndTime.Rate.Denominator)
    if self.TriggerAction then
      self.TriggerAction:SetTimeoutValue(self.TriggerAction:GetTimeoutValue() + EndSeconds * 1000)
    end
    battleFieldActor:SetCacheLSCall(self, self.OpenBlackLoading)
    self.levelSequence.OnFinished:Add(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
    local EnableRebasing = UE4.UNRCStatics.IsEnabledWorldRebasing(CurrentWorld)
    if true == EnableRebasing then
      levelSequenceActor:ApplyWorldOffsetToSequence()
    end
    self.levelSequence:Play()
    _G.BattleManager:ModifySceneSpotLight(false)
  else
    Log.Error("zgx error no levelSequenceActor")
    self:Complete()
  end
end

function BattleFinalP1EnterPerform:OpenBlackLoading()
  if not BattleManager:IsInBattle(true) then
    return
  end
  self:Complete()
end

function BattleFinalP1EnterPerform:OnComplete()
  if not BattleManager:IsInBattle(true) then
    return
  end
  if self.isOver then
    return
  end
  _G.BattleManager:ModifySceneSpotLight(true)
  if self.levelSequence then
    BattleManager.CacheSequencer = self.levelSequence
    local battleFieldActor = _G.BattleManager.vBattleField.battleFieldActor
    self.levelSequence.OnFinished:Remove(battleFieldActor, battleFieldActor.OnLevelSequenceEnd)
    self.levelSequence = nil
  end
  if self.TriggerAction then
    self.TriggerAction:Finish()
    self.FinishCallBack(self.TriggerAction)
  end
  self.TriggerAction = nil
  self.FinishCallBack = nil
end

return BattleFinalP1EnterPerform
