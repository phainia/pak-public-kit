local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = DebugTabBase
local DebugTabBattleMem = Base:Extend("DebugTabBattleMem")

function DebugTabBattleMem:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleMem:SetupTabs()
  self:Add("\230\181\139\232\175\149\231\148\168", self.testBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "testBattle")
end

function DebugTabBattleMem:testBattle()
end

function DebugTabBattleMem:TestMoveToValidPos()
  BattleAIManager:TestMoveToValidPos1()
  self:ClosePanel()
end

function DebugTabBattleMem:TestEnemyMoveToValidPos()
  BattleAIManager:TestMoveToValidPos()
  self:ClosePanel()
end

function DebugTabBattleMem:OnUnlockNonStandingBattle(Name, Panel)
  BattleConst.CanBattleEverywhere = true
end

function DebugTabBattleMem:OnLockNonStandingBattle(Name, Panel)
  BattleConst.CanBattleEverywhere = false
  BattleConst.MoveToLegalLocationWhenBlock = false
  BattleConst.DonntHideTree = true
end

function DebugTabBattleMem:EnableMoveableBattleDebug()
  UE4.UNRCStatics.EnableMoveableBattleDebug(true)
end

function DebugTabBattleMem:EnableDebugLine()
  UE4.UNRCStatics.EnableEQSDebug(true)
end

function DebugTabBattleMem:DisableMoveableBattleDebug()
  UE4.UNRCStatics.EnableMoveableBattleDebug(false)
end

function DebugTabBattleMem:DisableDebugLine()
  UE4.UNRCStatics.EnableEQSDebug(false)
end

return DebugTabBattleMem
