local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattlePreloadPrepareResAction = Base:Extend("BattlePreloadPrepareResAction")

function BattlePreloadPrepareResAction:Ctor()
  Base.Ctor(self)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattlePreloadPrepareResAction:OnEnter()
  Log.Debug("BattlePreloadPrepareRes:OnEnter")
  self.timeout = 100.0
  self.IsPrepare = false
  self:StartPrepare()
  self:Finish()
end

function BattlePreloadPrepareResAction:StartPrepare()
  if not self.IsPrepare then
    Log.Error("BattlePreloadPrepareResAction StartPrepare")
    self.IsPrepare = true
    self.BattleManager:PrepareBattle()
  end
end

return BattlePreloadPrepareResAction
