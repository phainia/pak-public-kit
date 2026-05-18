local BattleLevelHelper = NRCClass()
local CinematicModuleEvent = require("NewRoco.Modules.Core.Cinematic.CinematicModuleEvent")

function BattleLevelHelper:Init()
  _G.NRCEventCenter:RegisterEvent("BattleLevelHelper", self, CinematicModuleEvent.Started, self.PreloadB1level)
end

function BattleLevelHelper:LoadLevelStream(scenePath, battleStartPlayerPos, shouldBeVisible)
  battleStartPlayerPos = battleStartPlayerPos or FVectorZero
  local LevelStreaming = BattleManager.vBattleField:LoadBattleLevel(scenePath, battleStartPlayerPos, UE.FRotator())
  if LevelStreaming then
    LevelStreaming:SetShouldBeVisible(shouldBeVisible)
    self.levelStreaming = LevelStreaming
    LevelStreaming.OnLevelLoaded:Add(LevelStreaming, function(level)
      self.isLevelLoad = true
    end)
  end
end

function BattleLevelHelper:CancelLevelStream()
  if self.levelStreaming and UE4.UObject.IsValid(self.levelStreaming) then
    self.levelStreaming:SetShouldBeLoaded(false)
  end
  self:ClearWait()
  self.levelStreaming = nil
  self.isLevelLoad = false
end

function BattleLevelHelper:ResetLevelData()
  self:ClearWait()
  self.levelStreaming:SetShouldBeVisible(true)
  self.levelStreaming = nil
  self.isLevelLoad = false
end

function BattleLevelHelper:StartWait(waitTime)
  if not self.levelStreaming then
    return
  end
  if self.waitHandle then
    return
  end
  waitTime = waitTime or 60
  self.waitHandle = _G.DelayManager:DelaySeconds(waitTime, self.CancelLevelStream, self)
end

function BattleLevelHelper:ClearWait()
  if self.waitHandle then
    _G.DelayManager:CancelDelayById(self.waitHandle)
    self.waitHandle = nil
  end
end

function BattleLevelHelper:GetIsLevelLoad()
  return self.isLevelLoad and self.levelStreaming
end

function BattleLevelHelper:LoadB1LevelStream(pos, shouldBeVisible)
  if not self.levelStreaming then
    if nil == shouldBeVisible then
      shouldBeVisible = true
    end
    local scenePath = "/Game/ArtRes/Level/Game/Plot/B1/Plot_B1_FinalBattle/Plot_B1_FinalBattle_Release"
    self:LoadLevelStream(scenePath, pos, shouldBeVisible)
  end
end

function BattleLevelHelper:PreloadB1level(SeqConf)
  if SeqConf then
    local finalbattle_loadlevel_id = _G.DataConfigManager:GetBattleGlobalConfig("B1_finalbattle_loadlevel").num
    if finalbattle_loadlevel_id == SeqConf.id then
      BattleResourceManager:LoadResAsync(self, BattleConst.B1P1EnterSequence)
    end
  end
end

function BattleLevelHelper:LoadBloodTeamLevelStream()
  if self.levelStreaming then
    return
  end
  local scenePath = "/Game/ArtRes/Level/Game/TeamBattle/TeamBattle_XMTZ/TeamBattle_XMTZ_Release"
  self:LoadLevelStream(scenePath, FVectorZero, true)
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.TeamBloodPerEnterBattle, true)
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.BloodTeamEnterFarBattle, true)
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.TeamBloodBossEffect, true)
end

function BattleLevelHelper:CancelBloodTeamLevelStream()
  self:CancelLevelStream()
end

function BattleLevelHelper:ResetBloodTeamLevelData()
  if self.levelStreaming then
    self.levelStreaming:SetShouldBeVisible(true)
    self:ResetLevelData()
  end
end

return BattleLevelHelper
