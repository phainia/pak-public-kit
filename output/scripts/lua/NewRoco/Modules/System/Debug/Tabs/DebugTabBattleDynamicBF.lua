local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = DebugTabBase
local DebugTabBattleDynamicBF = Base:Extend("DebugTabBattleDynamicBF")

function DebugTabBattleDynamicBFCtor()
  Base.Ctor(self)
end

function DebugTabBattleDynamicBF:SetupTabs()
  self:Add("\230\137\147\229\188\128\232\161\128\232\132\137\229\155\162\228\189\147\230\136\152\231\188\169\230\148\190\232\174\161\231\174\151", self.OpenBloodTeamScaleCompute, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenBloodTeamScaleCompute")
  self:Add("\229\133\179\233\151\173\232\161\128\232\132\137\229\155\162\228\189\147\230\136\152\231\188\169\230\148\190\232\174\161\231\174\151", self.CloseBloodTeamScaleCompute, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseBloodTeamScaleCompute")
  self:Add("\230\137\147\229\188\128B1\230\156\128\231\187\136\230\136\152P1\230\146\173\231\137\135", self.OpenB1FBP1Seq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenB1FBP1Seq")
  self:Add("\229\133\179\233\151\173B1\230\156\128\231\187\136\230\136\152P1\230\146\173\231\137\135", self.CloseB1FBP1Seq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseB1FBP1Seq")
  self:Add("\230\137\147\229\188\128B1\230\156\128\231\187\136\230\136\152P2\230\146\173\231\137\135", self.OpenB1FBP2Seq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenB1FBP2Seq")
  self:Add("\229\133\179\233\151\173B1\230\156\128\231\187\136\230\136\152P2\230\146\173\231\137\135", self.CloseB1FBP2Seq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseB1FBP2Seq")
  self:Add("\230\137\147\229\188\128B1\230\156\128\231\187\136\230\136\152P3MP4", self.OpenB1FBP3MP4, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenB1FBP3MP4")
  self:Add("\229\133\179\233\151\173B1\230\156\128\231\187\136\230\136\152P3MP4", self.CloseB1FBP3MP4, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseB1FBP3MP4")
  self:Add("\230\137\147\229\188\128B1\230\156\128\231\187\136\230\136\152\229\175\185\232\175\157", self.OpenB1FBDialogue, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenB1FBDialogue")
  self:Add("\229\133\179\233\151\173B1\230\156\128\231\187\136\230\136\152\229\175\185\232\175\157", self.CloseB1FBDialogue, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseB1FBDialogue")
  self:Add("\230\137\147\229\188\128A1\230\156\128\231\187\136\230\136\152\230\146\173\231\137\135", self.OpenA1FBSeq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenA1FBSeq")
  self:Add("\229\133\179\233\151\173A1\230\156\128\231\187\136\230\136\152\230\146\173\231\137\135", self.CloseA1FBSeq, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseA1FBSeq")
  self:Add("\230\137\147\229\188\128A1\230\156\128\231\187\136\230\136\152\229\175\185\232\175\157", self.OpenA1FBDialogue, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenA1FBDialogue")
  self:Add("\229\133\179\233\151\173A1\230\156\128\231\187\136\230\136\152\229\175\185\232\175\157", self.CloseA1FBDialogue, self, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CloseA1FBDialogue")
end

function DebugTabBattleDynamicBF:TestMoveToValidPos()
  BattleAIManager:TestMoveToValidPos1()
  self:ClosePanel()
end

function DebugTabBattleDynamicBF:TestEnemyMoveToValidPos()
  BattleAIManager:TestMoveToValidPos()
  self:ClosePanel()
end

function DebugTabBattleDynamicBF:OnUnlockNonStandingBattle(Name, Panel)
  BattleConst.CanBattleEverywhere = true
end

function DebugTabBattleDynamicBF:OnLockNonStandingBattle(Name, Panel)
  BattleConst.CanBattleEverywhere = false
  BattleConst.MoveToLegalLocationWhenBlock = false
  BattleConst.DonntHideTree = true
end

function DebugTabBattleDynamicBF:EnableMoveableBattleDebug()
  UE4.UNRCStatics.EnableMoveableBattleDebug(true)
end

function DebugTabBattleDynamicBF:EnableDebugLine()
  UE4.UNRCStatics.EnableEQSDebug(true)
end

function DebugTabBattleDynamicBF:DisableMoveableBattleDebug()
  UE4.UNRCStatics.EnableMoveableBattleDebug(false)
end

function DebugTabBattleDynamicBF:DisableDebugLine()
  UE4.UNRCStatics.EnableEQSDebug(false)
end

function DebugTabBattleDynamicBF:TestMoveLeft()
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local battlePet = BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_TEAM)
  BattleAIManager:JumpToLeftPos(battlePet, 200)
end

function DebugTabBattleDynamicBF:TestMoveRight()
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local battlePet = BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_TEAM)
  BattleAIManager:JumpToRightPos(battlePet, 200)
end

function DebugTabBattleDynamicBF:OpenBloodTeamScaleCompute()
  _G.BattleManager.debugEnv.closeBloodTeamScaleCompute = false
end

function DebugTabBattleDynamicBF:CloseBloodTeamScaleCompute()
  _G.BattleManager.debugEnv.closeBloodTeamScaleCompute = true
end

function DebugTabBattleDynamicBF:OpenB1FBP1Seq()
  _G.BattleManager.debugEnv.closeB1FBP1Seq = false
end

function DebugTabBattleDynamicBF:CloseB1FBP1Seq()
  _G.BattleManager.debugEnv.closeB1FBP1Seq = true
end

function DebugTabBattleDynamicBF:OpenB1FBP2Seq()
  _G.BattleManager.debugEnv.closeB1FBP2Seq = false
end

function DebugTabBattleDynamicBF:CloseB1FBP2Seq()
  _G.BattleManager.debugEnv.closeB1FBP2Seq = true
end

function DebugTabBattleDynamicBF:OpenB1FBP3MP4()
  _G.BattleManager.debugEnv.closeB1FBP3MP4 = false
end

function DebugTabBattleDynamicBF:CloseB1FBP3MP4()
  _G.BattleManager.debugEnv.closeB1FBP3MP4 = true
end

function DebugTabBattleDynamicBF:OpenB1FBDialogue()
  _G.BattleManager.debugEnv.closeB1FBDialogue = false
end

function DebugTabBattleDynamicBF:CloseB1FBDialogue()
  _G.BattleManager.debugEnv.closeB1FBDialogue = true
end

function DebugTabBattleDynamicBF:OpenA1FBSeq()
  _G.BattleManager.debugEnv.closeA1FBSeq = false
end

function DebugTabBattleDynamicBF:CloseA1FBSeq()
  _G.BattleManager.debugEnv.closeA1FBSeq = true
end

function DebugTabBattleDynamicBF:OpenA1FBDialogue()
  _G.BattleManager.debugEnv.closeA1FBDialogue = false
end

function DebugTabBattleDynamicBF:CloseA1FBDialogue()
  _G.BattleManager.debugEnv.closeA1FBDialogue = true
end

return DebugTabBattleDynamicBF
