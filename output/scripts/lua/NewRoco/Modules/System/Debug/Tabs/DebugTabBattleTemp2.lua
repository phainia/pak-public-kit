local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleCraneCameraDefine = require("NewRoco.Modules.Core.Battle.CraneCamera.BattleCraneCameraDefine")
local Base = DebugTabBase
local DebugTabBattleTemp2 = Base:Extend("DebugTabBattleTemp2")

function DebugTabBattleTemp2:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleTemp2:SetupTabs()
  self:Add("\230\137\147\229\188\128NPC\232\191\155\230\136\152\229\138\160\233\128\159", self.EnableSpeedUpNpcBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173NPC\232\191\155\230\136\152\229\138\160\233\128\159", self.DisableSpeedUpNpcBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpBattleLoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpBattleLoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128PVP\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpPVPBattleLoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173PVP\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpPVPBattleLoad, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\230\138\149\230\142\183\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpNearbyEnterBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\230\138\149\230\142\183\230\136\152\230\150\151\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpNearbyEnterBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\230\138\149\230\142\183\230\136\152\230\150\151\233\162\132\232\161\168\230\188\148\229\138\160\233\128\159", self.EnableSpeedUpNearbyEnterPreivewBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\230\138\149\230\142\183\230\136\152\230\150\151\233\162\132\232\161\168\230\188\148\229\138\160\233\128\159", self.DisableSpeedUpNearbyEnterPreviewBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\232\161\128\232\132\137\229\155\162\228\189\147\230\136\152\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpEnterBloodTeamBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\232\161\128\232\132\137\229\155\162\228\189\147\230\136\152\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpEnterBloodTeamBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128beast\229\155\162\228\189\147\230\136\152\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpEnterBeastTeamBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173beast\229\155\162\228\189\147\230\136\152\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpEnterBeastTeamBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\188\128\230\152\159\229\133\137\229\175\185\229\134\179\229\138\160\232\189\189\229\138\160\233\128\159", self.EnableSpeedUpWeeklyChallengeBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\233\151\173\230\152\159\229\133\137\229\175\185\229\134\179\229\138\160\232\189\189\229\138\160\233\128\159", self.DisableSpeedUpWeeklyChallengeBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\181\139\232\175\149\232\161\128\232\132\137\229\155\162\230\136\152\229\156\186\230\153\175\229\138\160\232\189\189\230\151\182\233\151\180", self.TestPreloadBloodLevel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\186\229\136\182\232\167\166\229\143\145RoundStartNotify", self.OnRoundStartNotify, self, nil, nil, nil, nil, "", "", "OnRoundStartNotify")
end

function DebugTabBattleTemp2:EnableSpeedUpNpcBattle()
  _G.EnableSpeedUpEnterBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpNpcBattle()
  _G.EnableSpeedUpEnterBattle = false
end

function DebugTabBattleTemp2:DisableSpeedUpBattleLoad()
  _G.DisableSpeedUpBattleLoad = true
end

function DebugTabBattleTemp2:EnableSpeedUpBattleLoad()
  _G.DisableSpeedUpBattleLoad = false
end

function DebugTabBattleTemp2:EnableSpeedUpPVPBattleLoad()
  _G.EnableSpeedUpEnterPVPBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpPVPBattleLoad()
  _G.EnableSpeedUpEnterPVPBattle = false
end

function DebugTabBattleTemp2:EnableSpeedUpNearbyEnterBattle()
  _G.EnableSpeedUpNearbyEnterBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpNearbyEnterBattle()
  _G.EnableSpeedUpNearbyEnterBattle = false
end

function DebugTabBattleTemp2:EnableSpeedUpNearbyEnterPreivewBattle()
  _G.EnableSpeedUpNearbyEnterPreview = true
end

function DebugTabBattleTemp2:DisableSpeedUpNearbyEnterPreviewBattle()
  _G.EnableSpeedUpNearbyEnterPreview = false
end

function DebugTabBattleTemp2:EnableSpeedUpEnterBloodTeamBattle()
  _G.EnableSpeedUpEnterBloodTeamBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpEnterBloodTeamBattle()
  _G.EnableSpeedUpEnterBloodTeamBattle = false
end

function DebugTabBattleTemp2:EnableSpeedUpEnterBeastTeamBattle()
  _G.EnableSpeedUpEnterBeastTeamBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpEnterBeastTeamBattle()
  _G.EnableSpeedUpEnterBeastTeamBattle = false
end

function DebugTabBattleTemp2:EnableSpeedUpWeeklyChallengeBattle()
  _G.EnableSpeedUpWeekChallengeBattle = true
end

function DebugTabBattleTemp2:DisableSpeedUpWeeklyChallengeBattle()
  _G.EnableSpeedUpWeekChallengeBattle = false
end

function DebugTabBattleTemp2:TestPreloadBloodLevel()
  Log.Debug("DebugTabBattleTemp2:TestPreloadBloodLevel Start")
  local scenePath = "/Game/ArtRes/Level/Game/TeamBattle/TeamBattle_XMTZ/TeamBattle_XMTZ_Release"
  local IsSuccess, LevelStreaming = UE.ULevelStreamingDynamic.LoadLevelInstance(_G.UE4Helper.GetCurrentWorld(), scenePath, _G.FVectorZero, UE.FRotator())
  if IsSuccess and LevelStreaming then
    LevelStreaming.OnLevelLoaded:Add(LevelStreaming, function(level)
      Log.Debug("DebugTabBattleTemp2:TestPreloadBloodLevel Onload")
      LevelStreaming:SetShouldBeLoaded(false)
    end)
  end
end

function DebugTabBattleTemp2:OnRoundStartNotify(name, panel)
  local t = {}
  t.ai_extur_data = {has_npc_delay = false}
  t.perform_cmd = {seq_num = 11}
  t.state_info = {
    battle_id = BattleManager.battleRuntimeData.battle_id,
    battle_start_time = BattleManager.battleRuntimeData.battle_start_time,
    is_enemy_dishonesty = false,
    is_player_dishonesty = true,
    last_change_pet_round = 0,
    round = 2,
    round_time = 0,
    series_index = 0
  }
  t.state_type = 1
  t.test = true
  BattleNetManager:ZoneBattleRoundStartNotify(t)
end

return DebugTabBattleTemp2
