local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BeastPreloadField = Base:Extend("BeastPreloadField")
FsmUtils.MergeMembers(Base, BeastPreloadField, {})

function BeastPreloadField:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BeastPreloadField:OnEnter()
  self:LoadBattleLevel()
  self:LoadSequence()
  if self:CheckIsAsync() then
    self:Finish()
  end
end

function BeastPreloadField:LoadBattleLevel()
  self.LoadLevelOver = false
  self.fsm:SetProperty("BeastLoadBattleLevel", false)
  local scenePath
  local battleCfg = _G.BattleManager.battleRuntimeData.battleConfig
  if battleCfg and not string.IsNilOrEmpty(battleCfg.background) then
    scenePath = battleCfg.background
  else
    scenePath = "/Game/ArtRes/Level/Editor/BigWorld/L_Bigworld_01/Arena_Levels/L_Arena_SSTZ_01"
  end
  local LevelStreaming = BattleManager.vBattleField:LoadBattleLevel(scenePath, BattleManager.battleRuntimeData.TeleportBattleCenter, UE.FRotator())
  if LevelStreaming then
    LevelStreaming:SetShouldBeVisible(false)
    self.fsm:SetProperty("BeastLevelStream", LevelStreaming)
    LevelStreaming.OnLevelLoaded:Add(LevelStreaming, function(level)
      self:LoadBattleLevelOver()
    end)
  else
    self:LoadBattleLevelOver()
  end
end

function BeastPreloadField:LoadBattleLevelOver()
  self.LoadLevelOver = true
  self.fsm:SetProperty("BeastLoadBattleLevel", true)
  self:CheckCanFinish()
end

function BeastPreloadField:LoadSequence()
  if BattleUtils.IsEnterCatchInTeamBattle() then
    self:OnLoadSequenceFailed()
    return
  end
  self.IsLoadSequenceOver = false
  self.fsm:SetProperty("BeastLoadSequence", nil)
  local sequencePath = BattleManager.battleRuntimeData.battleConfig.show_res
  if string.IsNilOrEmpty(sequencePath) then
    self:OnLoadSequenceFailed()
  else
    sequencePath = _G.NRCUtils.FormatResPackageNameToFullPath(sequencePath)
    BattleResourceManager:LoadResAsync(self, sequencePath, self.LoadSequenceOver, self.OnLoadSequenceFailed)
  end
end

function BeastPreloadField:OnLoadSequenceFailed()
  self.IsLoadSequenceOver = true
  self.fsm:SetProperty("BeastLoadSequence", false)
  self:CheckCanFinish()
end

function BeastPreloadField:LoadSequenceOver(leveSequenceRes)
  self.fsm:SetProperty("BeastLoadSequence", leveSequenceRes)
  self.IsLoadSequenceOver = true
  self:CheckCanFinish()
end

function BeastPreloadField:CheckCanFinish()
  if self:CheckIsAsync() then
    return
  end
  if self.IsLoadSequenceOver and self.LoadLevelOver then
    self:Finish()
  end
end

function BeastPreloadField:OnExit()
end

return BeastPreloadField
