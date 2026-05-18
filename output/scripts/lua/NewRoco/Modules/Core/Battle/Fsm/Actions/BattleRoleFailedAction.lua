local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleRoleFailedAction = Base:Extend("BattleRoleFailedAction")
FsmUtils.MergeMembers(Base, BattleRoleFailedAction, {})

function BattleRoleFailedAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRoleFailedAction:OnEnter()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  self:Finish()
end

function BattleRoleFailedAction:OnExit()
  self.Player = nil
end

return BattleRoleFailedAction
