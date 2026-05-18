local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local BattleShowMechanismValidationAction = Base:Extend("BattleShowMechanismValidationAction")
FsmUtils.MergeMembers(Base, BattleShowMechanismValidationAction, {})

function BattleShowMechanismValidationAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  _G.BattleEventCenter:Bind(self, BattleEvent.MechanismValidationClosed)
  self.BattleManager = _G.BattleManager
end

function BattleShowMechanismValidationAction:OnEnter()
  if not BattleUtils.IsNpcChallenge() and not BattleUtils.IsLeaderChallenge() then
    self:Finish()
    return
  end
  self:SetTimeoutValue(20000)
  local NpcChallengeInfo = _G.BattleManager:GetBattleNpcChallengeInfo()
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenMechanismValidation, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT, NpcChallengeInfo)
end

function BattleShowMechanismValidationAction:ShowUIPanel()
end

function BattleShowMechanismValidationAction:HideUIPanel()
end

function BattleShowMechanismValidationAction:OnFinish()
  _G.BattleEventCenter:UnBind(self)
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.CloseMechanismValidation)
end

function BattleShowMechanismValidationAction:OnExit()
end

function BattleShowMechanismValidationAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.MechanismValidationClosed then
    self:Finish()
  end
end

return BattleShowMechanismValidationAction
