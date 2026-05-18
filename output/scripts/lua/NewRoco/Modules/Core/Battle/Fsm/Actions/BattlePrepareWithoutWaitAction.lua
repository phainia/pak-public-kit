local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattlePrepareWithoutWaitAction = Base:Extend("BattlePrepareWithoutWaitAction")

function BattlePrepareWithoutWaitAction:Ctor()
  Base.Ctor(self)
  self:SetActionType(BattleActionBase.ActionType.ClientSkipableAction)
end

function BattlePrepareWithoutWaitAction:OnEnter()
  Log.Debug("BattlePreloadPrepareRes:OnEnter")
  self.timeout = 100.0
  self.IsPrepare = false
  self:StartPrepare()
  self:Finish()
end

function BattlePrepareWithoutWaitAction:StartPrepare()
  if not self.IsPrepare then
    Log.Warning("BattlePrepareWithoutWaitAction StartPrepare")
    self.IsPrepare = true
    BattleManager:PrepareBattle()
  end
end

return BattlePrepareWithoutWaitAction
