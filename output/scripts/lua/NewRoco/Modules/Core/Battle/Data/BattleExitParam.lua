local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleExitParam = NRCClass()

function BattleExitParam:Ctor()
  self.IsBattleFinishSeamless = false
  self.IsBattleFinishByCatch = false
  self.IsPveSeamlessOver = false
  self.IsPlayerSkillEscape = false
  self.IsEnemyEscape = false
  self.IsCatchSuccess = false
  self.handleBattleExitBySeamlessType = false
  self.lastHitKiller = nil
  self.lastHitPets = nil
  self.lastTurnSettleResult = nil
end

function BattleExitParam:Clear()
  self:Reset()
end

function BattleExitParam:Reset()
  self.IsEnemyEscape = false
  self.IsBattleFinishSeamless = false
  self.IsBattleFinishByCatch = false
  self.handleBattleExitBySeamlessType = false
  self.IsPveSeamlessOver = false
  self.IsPlayerSkillEscape = false
  self.IsCatchSuccess = false
  self.lastHitKiller = nil
  self.lastHitPets = nil
  self.lastTurnSettleResult = nil
end

function BattleExitParam:SetLastTurnSettleResult(result)
  self.lastTurnSettleResult = result
end

function BattleExitParam:GetLastTurnSettleResult()
  return self.lastTurnSettleResult
end

return BattleExitParam
