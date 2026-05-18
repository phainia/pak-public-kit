local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local BattleStatusChecker = Base:Extend("BattleStatusChecker")

function BattleStatusChecker:Ctor()
  Base.Ctor(self)
end

function BattleStatusChecker:CheckPass()
  local Pass = true
  if _G.BattleManager.isSendWaiting then
    Pass = false
    self:Log("\230\173\163\229\156\168\232\175\183\230\177\130\232\191\155\229\133\165\230\136\152\230\150\151\228\184\173")
  end
  if _G.BattleManager:IsInBattle() then
    Pass = false
    self:Log("\230\156\172\230\172\161\230\136\152\230\150\151\229\176\154\230\156\170\231\187\147\230\157\159")
  end
  return Pass
end

function BattleStatusChecker:StartCheck()
  self:RegisterGlobalEvent(BattleEvent.BattleOver, self.OnBattleFinished)
  self:RegisterGlobalEvent(BattleEvent.BattleStateOver, self.OnBattleFinished)
end

function BattleStatusChecker:OnBattleFinished()
  self:FireCallback()
end

function BattleStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(BattleEvent.BattleOver, self.OnBattleFinished)
  self:UnregisterGlobalEvent(BattleEvent.BattleStateOver, self.OnBattleFinished)
end

return BattleStatusChecker
