local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattleShowRuleTipsAction = Base:Extend("BattleShowRuleTipsAction")
FsmUtils.MergeMembers(Base, BattleShowRuleTipsAction, {})

function BattleShowRuleTipsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
end

function BattleShowRuleTipsAction:OnEnter()
  if BattleUtils.IsNpcChallenge() or BattleUtils.IsLeaderChallenge() then
    self:Finish()
    return
  end
  self:SetTimeoutValue(20000)
  local battleRules = BattleUtils.GetBattleRuleIds()
  if #battleRules > 0 then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenWarningPrompt, battleRules, self, self.Finish)
    self:ClearDelay()
    self.delayID = _G.DelayManager:DelaySeconds(1.5, self.Finish, self)
  else
    self:Finish()
  end
end

function BattleShowRuleTipsAction:ShowUIPanel()
end

function BattleShowRuleTipsAction:HideUIPanel()
end

function BattleShowRuleTipsAction:ClearDelay()
  if self.delayID then
    _G.DelayManager:CancelDelay(self.delayID)
    self.delayID = nil
  end
end

function BattleShowRuleTipsAction:OnFinish()
  self:ClearDelay()
  _G.BattleEventCenter:UnBind(self)
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseWarningPrompt)
end

function BattleShowRuleTipsAction:OnExit()
end

function BattleShowRuleTipsAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.MechanismValidationClosed then
    self:Finish()
  end
end

return BattleShowRuleTipsAction
